<?php

namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saisie\LigneEcriture;
use App\Models\Saisie\MouvementEcriture;
use App\Models\Saisie\Journal;
use App\Models\PlanCompte\SousCompte;
use App\Models\Saisie\ModePaiement;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class LigneEcritureController extends Controller
{
    // ========== Mouvements ==========

    public function getMouvementsComplets(Request $request)
    {
        $limit = $request->query('limit', 50);

        try {
            $mouvements = MouvementEcriture::with([
                'lignes.sousCompte',
                'lignes.modePaiement',
                'journal'
            ])
                ->whereHas('lignes', function ($query) {
                    $query->where('statut', '!=', 'valide')
                        ->orWhereNull('statut');
                })
                ->orderBy('Date_mouvement', 'desc')
                ->paginate($limit);

            $mouvements->getCollection()->transform(function ($mouvement) {
                $totalDebit = $mouvement->lignes->sum('Debit');
                $totalCredit = $mouvement->lignes->sum('Credit');
                $difference = abs($totalDebit - $totalCredit);

                $mouvement->totals = [
                    'debit' => $totalDebit,
                    'credit' => $totalCredit,
                    'difference' => $difference,
                ];
                $mouvement->journal_libelle = $mouvement->journal
                    ? "{$mouvement->journal->Code} - {$mouvement->journal->Libelle}"
                    : "Journal #{$mouvement->Id_Journal}";
                $mouvement->date_formatted = $mouvement->Date_mouvement
                    ? \Carbon\Carbon::parse($mouvement->Date_mouvement)->format('D j M Y')
                    : null;
                $mouvement->is_equilibre = $difference < 0.01 && $totalDebit > 0;
                $mouvement->is_valide = $this->isMouvementValide($mouvement);

                foreach ($mouvement->lignes as $ligne) {
                    $ligne->debit_formatted = $this->formatMontant($ligne->Debit);
                    $ligne->credit_formatted = $this->formatMontant($ligne->Credit);
                    $ligne->sousCompteSearch = $ligne->sousCompte
                        ? "{$ligne->sousCompte->Code_sous_compte} - {$ligne->sousCompte->Libelle}"
                        : '';
                }

                return $mouvement;
            });

            return response()->json($mouvements);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erreur lors du chargement des mouvements',
                'message' => config('app.debug') ? $e->getMessage() : 'Erreur serveur'
            ], 500);
        }
    }

    public function createMouvement(Request $request)
    {
        $request->validate([
            'Date_mouvement' => 'required|date',
            'Id_Journal'     => 'required|exists:journals,Id_Journal',
        ]);

        DB::beginTransaction();
        try {
            $mouvement = MouvementEcriture::create([
                'Date_mouvement' => $request->Date_mouvement,
                'Id_Journal'     => $request->Id_Journal,
                'created_by'     => Auth::id(),
            ]);
            DB::commit();
            return response()->json([
                'message' => 'Mouvement créé avec succès',
                'data'    => $mouvement
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'error' => 'Erreur lors de la création du mouvement',
                'message' => config('app.debug') ? $e->getMessage() : 'Erreur serveur'
            ], 500);
        }
    }

    public function deleteMouvement($mouvementId)
    {
        DB::beginTransaction();
        try {
            $mouvement = MouvementEcriture::with('lignes')->findOrFail($mouvementId);

            if ($this->isMouvementValide($mouvement)) {
                return response()->json([
                    'error' => 'Impossible de supprimer un mouvement validé'
                ], 400);
            }

            $mouvement->lignes()->delete();
            $mouvement->delete();

            DB::commit();
            return response()->json([
                'message' => 'Mouvement et ses lignes supprimés avec succès'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'error' => 'Erreur lors de la suppression du mouvement',
                'message' => config('app.debug') ? $e->getMessage() : 'Erreur serveur'
            ], 500);
        }
    }

    public function validerMouvementComplet($mouvementId)
    {
        DB::beginTransaction();

        try {
            $mouvement = MouvementEcriture::with('lignes')->findOrFail($mouvementId);
            $totalDebit = $mouvement->lignes->sum('Debit');
            $totalCredit = $mouvement->lignes->sum('Credit');

            if (!(abs($totalDebit - $totalCredit) < 0.01 && $totalDebit > 0)) {
                return response()->json([
                    'error' => 'Le mouvement doit être équilibré pour être validé'
                ], 400);
            }
            if ($this->isMouvementValide($mouvement)) {
                return response()->json([
                    'error' => 'Le mouvement est déjà validé'
                ], 400);
            }

            foreach ($mouvement->lignes as $ligne) {
                $ligne->update([
                    'statut'         => 'valide',
                    'date_validation'=> now(),
                    'valide_par'     => Auth::id(),
                ]);
            }

            DB::commit();
            return response()->json([
                'message' => 'Mouvement validé avec succès'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'error' => 'Erreur lors de la validation du mouvement',
                'message' => config('app.debug') ? $e->getMessage() : 'Erreur serveur'
            ], 500);
        }
    }

    // ========== Lignes ==========

    public function index()
    {
        return LigneEcriture::with('journal', 'sousCompte', 'mouvement', 'modePaiement')->get();
    }

    public function show($id)
    {
        return LigneEcriture::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Libelle'              => 'required|string|max:255',
            'Debit'                => 'required|numeric',
            'Credit'               => 'required|numeric',
            'Reference'            => 'nullable|string|max:50',
            'Quantite'             => 'nullable|integer',
            'Id_Mode_paiement'     => 'nullable|exists:mode_paiements,Id_Mode_paiement',
            'Id_Mouvement_ecriture'=> 'required|exists:mouvement_ecritures,Id_Mouvement_ecriture',
            'Id_Journal'           => 'required|exists:journals,Id_Journal',
            'Id_Sous_compte'       => 'required|exists:sous_comptes,Id_Sous_compte',
        ]);

        $ligne = LigneEcriture::create($request->all());
        return response()->json([
            'message' => 'Ligne créée avec succès',
            'data'    => $ligne
        ]);
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'Libelle'          => 'required|string|max:255',
            'Debit'            => 'required|numeric',
            'Credit'           => 'required|numeric',
            'Reference'        => 'nullable|string|max:50',
            'Quantite'         => 'nullable|integer',
            'Id_Mode_paiement' => 'nullable|exists:mode_paiements,Id_Mode_paiement',
            'Id_Mouvement_ecriture' => 'required|exists:mouvement_ecritures,Id_Mouvement_ecriture',
            'Id_Journal'       => 'required|exists:journals,Id_Journal',
            'Id_Sous_compte'   => 'required|exists:sous_comptes,Id_Sous_compte',
        ]);
        $ligne = LigneEcriture::findOrFail($id);
        $ligne->update($request->all());

        return response()->json([
            'message' => 'Ligne mise à jour avec succès',
            'data'    => $ligne
        ]);
    }

    public function destroy($id)
    {
        $ligne = LigneEcriture::findOrFail($id);
        $ligne->delete();

        return response()->json(['message' => 'Ligne supprimée avec succès']);
    }

    public function valider($id)
    {
        $ecriture = LigneEcriture::findOrFail($id);

        if ($ecriture->statut === 'valide') {
            return response()->json(['error' => 'Cette écriture est déjà validée'], 400);
        }

        $ecriture->update([
            'statut'         => 'valide',
            'date_validation'=> now(),
            'valide_par'     => Auth::id(),
        ]);

        return response()->json([
            'message' => 'Écriture validée avec succès',
            'data'    => $ecriture
        ]);
    }

    public function saveLignesBatch(Request $request)
    {
        DB::beginTransaction();
        try {
            $lignes = $request->input('lignes', []);
            $results = [];
            foreach ($lignes as $ligneData) {
                $validateData = [
                    'Libelle'              => 'required|string|max:255',
                    'Debit'                => 'required|numeric',
                    'Credit'               => 'required|numeric',
                    'Reference'            => 'nullable|string|max:50',
                    'Quantite'             => 'nullable|integer',
                    'Id_Mode_paiement'     => 'nullable|exists:mode_paiements,Id_Mode_paiement',
                    'Id_Mouvement_ecriture'=> 'required|exists:mouvement_ecritures,Id_Mouvement_ecriture',
                    'Id_Journal'           => 'required|exists:journals,Id_Journal',
                    'Id_Sous_compte'       => 'required|exists:sous_comptes,Id_Sous_compte',
                ];
                validator($ligneData, $validateData)->validate();

                if (isset($ligneData['Id_Ligne_ecriture'])) {
                    $ligne = LigneEcriture::find($ligneData['Id_Ligne_ecriture']);
                    if ($ligne) {
                        $ligne->update($ligneData);
                        $results[] = $ligne;
                    }
                } else {
                    $results[] = LigneEcriture::create($ligneData);
                }
            }
            DB::commit();
            return response()->json([
                'message' => 'Lignes sauvegardées avec succès',
                'lignes'  => $results
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'error'   => 'Erreur lors de la sauvegarde des lignes',
                'message' => config('app.debug') ? $e->getMessage() : 'Erreur serveur'
            ], 500);
        }
    }

    public function getOptions()
    {
        try {
            $journals = Journal::select('Id_Journal', 'Code', 'Libelle')->get()
                ->map(fn($j) => [
                    'Id_Journal' => $j->Id_Journal,
                    'Code' => $j->Code,
                    'Libelle' => $j->Libelle,
                    'display_text' => "{$j->Code} - {$j->Libelle}"
                ]);
            $sousComptes = SousCompte::select('Id_Sous_compte', 'Code_sous_compte', 'Libelle')
                ->get()
                ->map(fn($c) => [
                    'Id_Sous_compte' => $c->Id_Sous_compte,
                    'Code_sous_compte' => $c->Code_sous_compte,
                    'Libelle' => $c->Libelle,
                    'display_text' => "{$c->Code_sous_compte} - {$c->Libelle}"
                ]);
            $modesPaiement = ModePaiement::select('Id_Mode_paiement', 'Libelle')->get();
            return response()->json([
                'journals'      => $journals,
                'sousComptes'   => $sousComptes,
                'modesPaiement' => $modesPaiement
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erreur lors du chargement des options',
                'message' => config('app.debug') ? $e->getMessage() : 'Erreur serveur'
            ], 500);
        }
    }

    public function searchSousComptes(Request $request)
    {
        $searchTerm = $request->get('q', '');
        if (strlen($searchTerm) < 2) return response()->json([]);
        $sousComptes = SousCompte::where('Code_sous_compte', 'LIKE', "%{$searchTerm}%")
            ->orWhere('Libelle', 'LIKE', "%{$searchTerm}%")
            ->limit(10)
            ->get()
            ->map(fn($c) => [
                'Id_Sous_compte' => $c->Id_Sous_compte,
                'Code_sous_compte' => $c->Code_sous_compte,
                'Libelle' => $c->Libelle,
                'display_text' => "{$c->Code_sous_compte} - {$c->Libelle}"
            ]);
        return response()->json($sousComptes);
    }

    // ========== Utilitaires internes ==========
    private function formatMontant($montant)
    {
        return number_format(floatval($montant), 2, ',', ' ');
    }
    private function isMouvementValide($mouvement)
    {
        return $mouvement->lignes && $mouvement->lignes->count() > 0 &&
            $mouvement->lignes->every(fn($l) => $l->statut === 'valide');
    }
}
