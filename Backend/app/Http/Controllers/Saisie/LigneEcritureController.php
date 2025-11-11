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


    public function indexWithRelations(Request $request)
{
    $query = LigneEcriture::with([
        'sousCompte.compte.rubrique.classe',
        'modePaiement',
        'mouvement',
        'journal'
    ]);

    // Filtre recherche globale
    if ($request->q)
        $query->where('Libelle', 'LIKE', '%'.$request->q.'%')
              ->orWhere('Reference', 'LIKE', '%'.$request->q.'%');

    // Filtre par date
    if ($request->date_debut)
        $query->whereHas('mouvement', fn($q) => $q->where('Date_mouvement', '>=', $request->date_debut));
    if ($request->date_fin)
        $query->whereHas('mouvement', fn($q) => $q->where('Date_mouvement', '<=', $request->date_fin));

    // Paginer
    $results = $query->orderByDesc('Id_Ligne_ecriture')->paginate(50);
    return response()->json($results);
}

public function batchUpdate(Request $request)
{
    $request->validate([
        'ids' => 'required|array|min:1',
        'ids.*' => 'integer|exists:ligne_ecritures,Id_Ligne_ecriture',
        'data.Libelle' => 'nullable|string|max:255',
        'data.Debit' => 'nullable|numeric',
        'data.Credit' => 'nullable|numeric',
        'data.Reference' => 'nullable|string|max:50',
    ]);
    // On ne modifie que les écritures non validées
    $query = LigneEcriture::whereIn('Id_Ligne_ecriture', $request->ids)
        ->where('statut', '!=', 'valide');
    $query->update(array_filter($request->data));
    return response()->json(['message' => 'Écritures modifiées']);
}

    
    // ========== Mouvements ==========

    public function getMouvementsComplets(Request $request)
    {
        $limit = $request->query('limit', 50);

        try {
            $mouvements = MouvementEcriture::with([
    'lignes.sousCompte.compte.rubrique.classe', // chaîne imbriquée complète
    'lignes.modePaiement',
    'journal'
])

        
        // ✅ CORRECTION : Inclure les mouvements sans lignes OU avec lignes non validées
        ->where(function ($query) {
            $query->whereHas('lignes', function ($q) {
                $q->where('statut', '!=', 'valide')
                  ->orWhereNull('statut');
            })
            ->orWhereDoesntHave('lignes'); // ✅ Ajoute les mouvements sans lignes
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

    // Dans app/Http/Controllers/MouvementController.php
public function index()
{
    $mouvements = MouvementEcriture::with([
        'lignes.sousCompte.compte.rubrique.classe', // toute la hiérarchie !
        'lignes.modePaiement',
        'journal'
    ])
    ->orderBy('Date_mouvement', 'desc')
    ->get();
    
    return response()->json($mouvements);
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

   public function solderMouvement($mouvementId)
{
    DB::beginTransaction();
    try {
        $mouvement = MouvementEcriture::with(['lignes', 'journal'])->findOrFail($mouvementId);
        $totalDebit = $mouvement->lignes->sum('Debit');
        $totalCredit = $mouvement->lignes->sum('Credit');
        $solde = $totalDebit - $totalCredit;

        // S'il est déjà équilibré, on arrête.
        if (abs($solde) < 0.01) {
            return response()->json([
                'error' => 'Le mouvement est déjà équilibré.'
            ], 400);
        }

        // Compte de contrepartie du journal
        $Id_Sous_compte_contra = $mouvement->journal?->Id_Sous_compte;
        if (!$Id_Sous_compte_contra) {
            return response()->json([
                'error' => 'Aucun compte de contrepartie défini pour le journal.'
            ], 400);
        }

        // Création de la ligne de contrepartie
        $dataLigneContra = [
            'Libelle' => $mouvement->lignes->count() > 0 ? $mouvement->lignes[0]->Libelle : 'Soldé',
            'Debit' => $solde < 0 ? abs($solde) : 0,
            'Credit' => $solde > 0 ? abs($solde) : 0,
            'Reference' => null,
            'Quantite' => 1,
            'Id_Mode_paiement' => null,
            'Id_Mouvement_ecriture' => $mouvement->Id_Mouvement_ecriture,
            'Id_Journal' => $mouvement->Id_Journal,
            'Id_Sous_compte' => $Id_Sous_compte_contra,
        ];

        $ligne = LigneEcriture::create($dataLigneContra);

        DB::commit();
        return response()->json([
            'message' => 'Mouvement soldé avec contrepartie.',
            'ligne' => $ligne
        ]);
    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json([
            'error' => 'Erreur lors du solder.',
            'message' => config('app.debug') ? $e->getMessage() : 'Erreur serveur'
        ], 500);
    }
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

    /**
 * Valide TOUTES les écritures non validées en une seule action
 * Recommandé pour validation globale/périodique
 */
public function validerToutesLesEcritures()
{
    DB::beginTransaction();
    
    try {
        $userId = Auth::id();
        $dateValidation = now();
        
        // 📊 Comptage des écritures à valider
        $countNonValidees = LigneEcriture::where(function($query) {
                $query->where('statut', '!=', 'valide')
                      ->orWhereNull('statut');
            })
            ->where(function($query) {
                // Exclure les lignes invalides (sans montant ou avec débit ET crédit)
                $query->where(function($q) {
                    $q->where('Debit', '>', 0)->where('Credit', '=', 0);
                })
                ->orWhere(function($q) {
                    $q->where('Credit', '>', 0)->where('Debit', '=', 0);
                });
            })
            ->count();
        
        if ($countNonValidees === 0) {
            return response()->json([
                'message' => 'Aucune écriture à valider',
                'validated' => 0
            ]);
        }
        
        // ✅ Validation en masse (optimisée pour < 10 000 lignes)
        if ($countNonValidees < 10000) {
            $affected = LigneEcriture::where(function($query) {
                    $query->where('statut', '!=', 'valide')
                          ->orWhereNull('statut');
                })
                ->where(function($query) {
                    $query->where(function($q) {
                        $q->where('Debit', '>', 0)->where('Credit', '=', 0);
                    })
                    ->orWhere(function($q) {
                        $q->where('Credit', '>', 0)->where('Debit', '=', 0);
                    });
                })
                ->update([
                    'statut'          => 'valide',
                    'date_validation' => $dateValidation,
                    'valide_par'      => $userId,
                ]);
            
            DB::commit();
            
            return response()->json([
                'message' => "{$affected} écriture(s) validée(s) avec succès",
                'validated' => $affected,
                'method' => 'bulk_update'
            ]);
        }
        
        // 🔄 Validation par lots (pour > 10 000 lignes)
        $totalValidated = 0;
        $chunkSize = 500;
        
        LigneEcriture::where(function($query) {
                $query->where('statut', '!=', 'valide')
                      ->orWhereNull('statut');
            })
            ->where(function($query) {
                $query->where(function($q) {
                    $q->where('Debit', '>', 0)->where('Credit', '=', 0);
                })
                ->orWhere(function($q) {
                    $q->where('Credit', '>', 0)->where('Debit', '=', 0);
                });
            })
            ->chunkById($chunkSize, function ($lignes) use ($userId, $dateValidation, &$totalValidated) {
                foreach ($lignes as $ligne) {
                    $ligne->update([
                        'statut'          => 'valide',
                        'date_validation' => $dateValidation,
                        'valide_par'      => $userId,
                    ]);
                    $totalValidated++;
                }
            });
        
        DB::commit();
        
        return response()->json([
            'message' => "{$totalValidated} écriture(s) validée(s) avec succès",
            'validated' => $totalValidated,
            'method' => 'chunked_update'
        ]);
        
    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json([
            'error'   => 'Erreur lors de la validation globale des écritures',
            'message' => config('app.debug') ? $e->getMessage() : 'Erreur serveur'
        ], 500);
    }
}

/**
 * Valide toutes les écritures d'une période donnée
 * Utile pour clôture mensuelle/annuelle
 */
public function validerEcrituresPeriode(Request $request)
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin'   => 'required|date|after_or_equal:date_debut',
        'journal_id' => 'nullable|exists:journals,Id_Journal'
    ]);
    
    DB::beginTransaction();
    
    try {
        $query = LigneEcriture::with('mouvementEcriture')
            ->where(function($q) {
                $q->where('statut', '!=', 'valide')
                  ->orWhereNull('statut');
            })
            ->whereHas('mouvementEcriture', function($q) use ($request) {
                $q->whereBetween('Date_mouvement', [
                    $request->date_debut,
                    $request->date_fin
                ]);
            });
        
        // Filtre optionnel par journal
        if ($request->has('journal_id')) {
            $query->where('Id_Journal', $request->journal_id);
        }
        
        // Exclure lignes invalides
        $query->where(function($q) {
            $q->where(function($subQ) {
                $subQ->where('Debit', '>', 0)->where('Credit', '=', 0);
            })
            ->orWhere(function($subQ) {
                $subQ->where('Credit', '>', 0)->where('Debit', '=', 0);
            });
        });
        
        $affected = $query->update([
            'statut'          => 'valide',
            'date_validation' => now(),
            'valide_par'      => Auth::id(),
        ]);
        
        DB::commit();
        
        $periode = \Carbon\Carbon::parse($request->date_debut)->format('d/m/Y') 
                 . ' - ' 
                 . \Carbon\Carbon::parse($request->date_fin)->format('d/m/Y');
        
        return response()->json([
            'message' => "{$affected} écriture(s) validée(s) pour la période {$periode}",
            'validated' => $affected,
            'periode' => $periode
        ]);
        
    } catch (\Exception $e) {
        DB::rollBack();
        return response()->json([
            'error'   => 'Erreur lors de la validation des écritures',
            'message' => config('app.debug') ? $e->getMessage() : 'Erreur serveur'
        ], 500);
    }
}

/**
 * Obtient un rapport des écritures à valider
 * Utile avant validation globale
 */
public function getRapportValidation()
{
    try {
        $stats = [
            'total_non_validees' => LigneEcriture::where('statut', '!=', 'valide')
                ->orWhereNull('statut')
                ->count(),
            
            'valides' => LigneEcriture::where('statut', 'valide')->count(),
            
            'invalides' => LigneEcriture::where(function($q) {
                    $q->where('statut', '!=', 'valide')
                      ->orWhereNull('statut');
                })
                ->where(function($q) {
                    // Lignes avec débit ET crédit, ou sans montant
                    $q->where(function($subQ) {
                        $subQ->where('Debit', '>', 0)->where('Credit', '>', 0);
                    })
                    ->orWhere(function($subQ) {
                        $subQ->where('Debit', '=', 0)->where('Credit', '=', 0);
                    });
                })
                ->count(),
            
            'mouvements_non_equilibres' => MouvementEcriture::with('lignes')
                ->get()
                ->filter(function($mouvement) {
                    $debit = $mouvement->lignes->sum('Debit');
                    $credit = $mouvement->lignes->sum('Credit');
                    return abs($debit - $credit) >= 0.01;
                })
                ->count(),
        ];
        
        $stats['validables'] = $stats['total_non_validees'] - $stats['invalides'];
        
        return response()->json($stats);
        
    } catch (\Exception $e) {
        return response()->json([
            'error'   => 'Erreur lors de la génération du rapport',
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
