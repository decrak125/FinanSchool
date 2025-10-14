<?php

namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saisie\LigneEcriture;
use App\Models\Saisie\MouvementEcriture;
use App\Models\Saisie\Journal;
use App\Models\PlanCompte\SousCompte;
use App\Models\Saisie\ModePaiement;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class LigneEcritureController extends Controller
{
    /**
     * Récupère toutes les lignes d'écriture avec leurs relations
     */
    public function index()
    {
        return LigneEcriture::with('journal', 'sousCompte', 'mouvement', 'modePaiement')->get();
    }

    /**
     * Affiche une ligne d'écriture spécifique
     */
    public function show($id)
    {
        return LigneEcriture::findOrFail($id);
    }

    /**
     * Crée une nouvelle ligne d'écriture
     */
    public function store(Request $request)
    {
        $request->validate([
            'Libelle' => 'required|string|max:255',
            'Debit' => 'required|numeric',
            'Credit' => 'required|numeric',
            'Reference' => 'nullable|string|max:50',
            'Quantite' => 'nullable|integer',
            'Id_Mode_paiement' => 'nullable|exists:mode_paiements,Id_Mode_paiement',
            'Id_Mouvement_ecriture' => 'required|exists:mouvement_ecritures,Id_Mouvement_ecriture',
            'Id_Journal' => 'required|exists:journals,Id_Journal',
            'Id_Sous_compte' => 'required|exists:sous_comptes,Id_Sous_compte',
        ]);

        $ligne = LigneEcriture::create($request->all());
        return response()->json([
            'message' => 'Ligne créée avec succès',
            'data' => $ligne
        ]);
    }

    /**
     * Met à jour une ligne d'écriture
     */
    public function update(Request $request, $id)
    {
        $request->validate([
            'Libelle' => 'required|string|max:255',
            'Debit' => 'required|numeric',
            'Credit' => 'required|numeric',
            'Reference' => 'nullable|string|max:50',
            'Quantite' => 'nullable|integer',
            'Id_Mode_paiement' => 'nullable|exists:mode_paiements,Id_Mode_paiement',
            'Id_Mouvement_ecriture' => 'required|exists:mouvement_ecritures,Id_Mouvement_ecriture',
            'Id_Journal' => 'required|exists:journals,Id_Journal',
            'Id_Sous_compte' => 'required|exists:sous_comptes,Id_Sous_compte',
        ]);

        $ligne = LigneEcriture::findOrFail($id);
        $ligne->update($request->all());

        return response()->json([
            'message' => 'Ligne mise à jour avec succès',
            'data' => $ligne
        ]);
    }

    /**
     * Supprime une ligne d'écriture
     */
    public function destroy($id)
    {
        $ligne = LigneEcriture::findOrFail($id);
        $ligne->delete();

        return response()->json(['message' => 'Ligne supprimée avec succès']);
    }

    /**
     * Valide une ligne d'écriture
     */
    public function valider($id)
    {
        $ecriture = LigneEcriture::findOrFail($id);

        if ($ecriture->statut === 'valide') {
            return response()->json(['error' => 'Cette écriture est déjà validée'], 400);
        }

        $ecriture->update([
            'statut' => 'valide',
            'date_validation' => now(),
            'valide_par' => Auth::user()->id,
        ]);

        return response()->json([
            'message' => 'Écriture validée avec succès',
            'data' => $ecriture
        ]);
    }

    /**
     * Crée un nouveau mouvement
     */
    public function createMouvement(Request $request)
    {
        $request->validate([
            'Date_mouvement' => 'required|date',
            'Id_Journal' => 'required|exists:journals,Id_Journal',
        ]);

        DB::beginTransaction();
        try {
            $mouvement = MouvementEcriture::create([
                'Date_mouvement' => $request->Date_mouvement,
                'Id_Journal' => $request->Id_Journal,
                'created_by' => Auth::user()->id,
            ]);

            DB::commit();
            return response()->json([
                'message' => 'Mouvement créé avec succès',
                'data' => $mouvement
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'error' => 'Erreur lors de la création du mouvement',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Supprime un mouvement et ses lignes associées
     */
    public function deleteMouvement($mouvementId)
    {
        DB::beginTransaction();
        try {
            $mouvement = MouvementEcriture::with('lignes')->findOrFail($mouvementId);

            // Vérifier si le mouvement est validé
            if ($this->isMouvementValide($mouvement)) {
                return response()->json([
                    'error' => 'Impossible de supprimer un mouvement validé'
                ], 400);
            }

            // Supprimer les lignes associées
            $mouvement->lignes()->delete();
            // Supprimer le mouvement
            $mouvement->delete();

            DB::commit();
            return response()->json([
                'message' => 'Mouvement et ses lignes supprimés avec succès'
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'error' => 'Erreur lors de la suppression du mouvement',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupère tous les mouvements avec leurs lignes et calculs
     */
    public function getMouvementsComplets()
    {
        try {
            // Charger tous les mouvements non validés avec leurs relations
            $mouvements = MouvementEcriture::with([
                'lignes.sousCompte',
                'lignes.modePaiement',
                'journal'
            ])
            ->whereHas('lignes', function($query) {
                $query->where('statut', '!=', 'valide')
                      ->orWhereNull('statut');
            })
            ->orderBy('Date_mouvement', 'desc')
            ->get()
            ->map(function($mouvement) {
                // Calculer les totaux pour chaque mouvement
                $totals = $this->calculateMouvementTotals($mouvement);
                $mouvement->journal_libelle = $this->getJournalLibelle($mouvement->Id_Journal);
                $mouvement->date_formatted = $this->formatDate($mouvement->Date_mouvement);
                
                foreach ($mouvement->lignes as $ligne) {
                    $ligne->debit_formatted = $this->formatMontant($ligne->Debit);
                    $ligne->credit_formatted = $this->formatMontant($ligne->Credit);
                    $ligne->sousCompteSearch = $ligne->sousCompte ? 
                        "{$ligne->sousCompte->Code_sous_compte} - {$ligne->sousCompte->Libelle}" : '';
                }
                
                return [
                    'mouvement' => $mouvement,
                    'lignes' => $mouvement-> lagen,
                    'totals' => $totals,
                    'is_equilibre' => $this->isMouvementEquilibre($totals),
                    'is_valide' => $this->isMouvementValide($mouvement)
                ];
            });

            return response()->json([
                'mouvements' => $mouvements,
                'totals_generaux' => $this->calculateTotalsGeneraux($mouvements)
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erreur lors du chargement des mouvements',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Recherche de sous-comptes avec suggestions
     */
    public function searchSousComptes(Request $request)
    {
        $searchTerm = $request->get('q', '');
        
        if (strlen($searchTerm) < 2) {
            return response()->json([]);
        }

        $sousComptes = SousCompte::where('Code_sous_compte', 'LIKE', "%{$searchTerm}%")
            ->orWhere('Libelle', 'LIKE', "%{$searchTerm}%")
            ->limit(10)
            ->get()
            ->map(function($compte) {
                return [
                    'Id_Sous_compte' => $compte->Id_Sous_compte,
                    'Code_sous_compte' => $compte->Code_sous_compte,
                    'Libelle' => $compte->Libelle,
                    'display_text' => "{$compte->Code_sous_compte} - {$compte->Libelle}"
                ];
            });

        return response()->json($sousComptes);
    }

    /**
     * Sauvegarde en lot des lignes d'écriture
     */
    public function saveLignesBatch(Request $request)
    {
        DB::beginTransaction();
        
        try {
            $lignes = $request->input('lignes', []);
            $results = [];
            
            foreach ($lignes as $ligneData) {
                $request->validate([
                    'Libelle' => 'required|string|max:255',
                    'Debit' => 'required|numeric',
                    'Credit' => 'required|numeric',
                    'Reference' => 'nullable|string|max:50',
                    'Quantite' => 'nullable|integer',
                    'Id_Mode_paiement' => 'nullable|exists:mode_paiements,Id_Mode_paiement',
                    'Id_Mouvement_ecriture' => 'required|exists:mouvement_ecritures,Id_Mouvement_ecriture',
                    'Id_Journal' => 'required|exists:journals,Id_Journal',
                    'Id_Sous_compte' => 'required|exists:sous_comptes,Id_Sous_compte',
                ], [], ['lignes.*' => 'Ligne']);

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
                'lignes' => $results
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'error' => 'Erreur lors de la sauvegarde des lignes',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Validation d'un mouvement complet
     */
    public function validerMouvementComplet($mouvementId)
    {
        DB::beginTransaction();
        
        try {
            $mouvement = MouvementEcriture::with('lignes')->findOrFail($mouvementId);
            $totals = $this->calculateMouvementTotals($mouvement);
            
            if (!$this->isMouvementEquilibre($totals)) {
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
                    'statut' => 'valide',
                    'date_validation' => now(),
                    'valide_par' => Auth::user()->id,
                ]);
            }
            
            DB::commit();
            
            return response()->json([
                'message' => 'Mouvement validé avec succès',
                'mouvement' => $mouvement->load('lignes.sousCompte')
            ]);
            
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'error' => 'Erreur lors de la validation du mouvement',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Récupère les options pour les formulaires
     */
    public function getOptions()
    {
        try {
            $journals = Journal::select('Id_Journal', 'Code', 'Libelle')
                ->get()
                ->map(function($journal) {
                    return [
                        'Id_Journal' => $journal->Id_Journal,
                        'Code' => $journal->Code,
                        'Libelle' => $journal->Libelle,
                        'display_text' => "{$journal->Code} - {$journal->Libelle}"
                    ];
                });

            $sousComptes = SousCompte::select('Id_Sous_compte', 'Code_sous_compte', 'Libelle')
                ->get()
                ->map(function($compte) {
                    return [
                        'Id_Sous_compte' => $compte->Id_Sous_compte,
                        'Code_sous_compte' => $compte->Code_sous_compte,
                        'Libelle' => $compte->Libelle,
                        'display_text' => "{$compte->Code_sous_compte} - {$compte->Libelle}"
                    ];
                });

            $modesPaiement = ModePaiement::select('Id_Mode_paiement', 'Libelle')->get();
            
            return response()->json([
                'journals' => $journals,
                'sousComptes' => $sousComptes,
                'modesPaiement' => $modesPaiement
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erreur lors du chargement des options',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Formate le libellé du journal
     */
    private function getJournalLibelle($journalId)
    {
        $journal = Journal::find($journalId);
        return $journal ? "{$journal->Code} - {$journal->Libelle}" : "Journal #{$journalId}";
    }

    /**
     * Formate une date
     */
    private function formatDate($dateStr)
    {
        if (!$dateStr) {
            return 'Date invalide';
        }
        try {
            return \Carbon\Carbon::parse($dateStr)->format('D j M Y');
        } catch (\Exception $e) {
            return $dateStr;
        }
    }

    /**
     * Formate un montant
     */
    private function formatMontant($montant)
    {
        if ($montant === null || $montant === '' || is_nan($montant)) {
            return '0,00';
        }
        return number_format($montant, 2, ',', ' ');
    }

    /**
     * Calcule les totaux d'un mouvement
     */
    private function calculateMouvementTotals($mouvement)
    {
        $totalDebit = $mouvement->lignes->sum('Debit');
        $totalCredit = $mouvement->lignes->sum('Credit');
        $difference = abs($totalDebit - $totalCredit);
        
        return [
            'debit' => $this->formatMontant($totalDebit),
            'credit' => $this->formatMontant($totalCredit),
            'difference' => $this->formatMontant($difference)
        ];
    }

    /**
     * Vérifie si un mouvement est équilibré
     */
    private function isMouvementEquilibre($totals)
    {
        return abs($totals['debit'] - $totals['credit']) < 0.01 && $totals['debit'] > 0;
    }

    /**
     * Vérifie si un mouvement est validé
     */
    private function isMouvementValide($mouvement)
    {
        return $mouvement->lignes->count() > 0 && 
               $mouvement->lignes->every(function($ligne) {
                   return $ligne->statut === 'valide';
               });
    }

    /**
     * Calcule les totaux généraux
     */
    private function calculateTotalsGeneraux($mouvements)
    {
        $totalDebit = 0;
        $totalCredit = 0;
        
        foreach ($mouvements as $mouvementData) {
            $totalDebit += floatval($mouvementData['totals']['debit']);
            $totalCredit += floatval($mouvementData['totals']['credit']);
        }
        
        return [
            'debit' => $this->formatMontant($totalDebit),
            'credit' => $this->formatMontant($totalCredit)
        ];
    }
}