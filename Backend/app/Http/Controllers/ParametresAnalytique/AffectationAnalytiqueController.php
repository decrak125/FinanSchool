<?php

namespace App\Http\Controllers\ParametresAnalytique;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\AffectationAnalytique;
use App\Models\ParametresAnalytique\CentreAnalytique;
use App\Models\PlanCompte\Compte;
use App\Models\PlanCompte\SousCompte;
use Illuminate\Support\Facades\DB;
use App\Models\ParametresAnalytique\TypeCentre;

class AffectationAnalytiqueController extends Controller
{
    public function index()
    {
        return AffectationAnalytique::with(['centre', 'sousCompte', 'type'])->get();
    }

    public function show($id)
    {
        return AffectationAnalytique::with(['centre', 'sousCompte', 'type'])->findOrFail($id);
    }

    /**
     * 🔹 Crée automatiquement les affectations pour tous les sous-comptes d'un compte
     */
    public function store(Request $request)
    {
        $request->validate([
            'Id_Compte' => 'required|exists:comptes,Id_Compte',
            'ventilations' => 'required|array|min:1',
            'ventilations.*.id_centre' => 'required|exists:centreanalytique,id_centre',
            'ventilations.*.id_type' => 'required|exists:typecentre,id_type', // ← NOUVEAU CHAMP
            'ventilations.*.taux' => 'required|numeric|min:0|max:100',
            'ventilations.*.description' => 'nullable|string|max:255',
        ]);

        // Vérifier que le total des taux = 100%
        $totalTaux = collect($request->ventilations)->sum('taux');
        if (abs($totalTaux - 100) > 0.01) {
            return response()->json([
                'success' => false,
                'message' => "Le total des taux doit être égal à 100% (actuellement: $totalTaux%)"
            ], 422);
        }

        $sousComptes = SousCompte::where('Id_Compte', $request->Id_Compte)->get();

        if ($sousComptes->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => "Aucun sous-compte trouvé pour ce compte"
            ], 422);
        }

        $affectations = [];
        $doublons = [];

        foreach ($sousComptes as $sous) {
            foreach ($request->ventilations as $ventilation) {
                $existeDeja = AffectationAnalytique::where('Id_Sous_compte', $sous->Id_Sous_compte)
                    ->where('id_centre', $ventilation['id_centre'])
                    ->exists();

                if ($existeDeja) {
                    $centreNom = CentreAnalytique::find($ventilation['id_centre'])->nom ?? $ventilation['id_centre'];
                    $doublons[] = $sous->Libelle . ' - Centre ' . $centreNom;
                    continue;
                }

                $affectations[] = AffectationAnalytique::create([
                    'Id_Sous_compte' => $sous->Id_Sous_compte,
                    'id_centre'      => $ventilation['id_centre'],
                    'id_type'        => $ventilation['id_type'], // ← NOUVEAU CHAMP
                    'taux'           => $ventilation['taux'],
                    'description'    => $ventilation['description'] ?? $sous->Libelle . ' - Ventilation',
                ]);
            }
        }

        $message = count($affectations) . ' affectations créées avec succès';
        if (count($doublons) > 0) {
            $message .= '. ' . count($doublons) . ' doublons ignorés: ' . implode(', ', array_slice($doublons, 0, 5));
            if (count($doublons) > 5) {
                $message .= '...';
            }
        }

        return response()->json([
            'success' => true,
            'message' => $message,
            'data'    => $affectations,
            'doublons_ignores' => $doublons
        ], 201);
    }

    /**
     * 🔹 Met à jour plusieurs ventilations en même temps pour un SOUS-COMPTE spécifique
     */
    public function updateMultiple(Request $request)
    {
        $request->validate([
            'Id_Sous_compte' => 'required|exists:sous_comptes,Id_Sous_compte',
            'ventilations' => 'required|array|min:1',
            'ventilations.*.id_affectation' => 'nullable|exists:affectationanalytique,id_affectation',
            'ventilations.*.id_centre' => 'required|exists:centreanalytique,id_centre',
            'ventilations.*.id_type' => 'required|exists:typecentre,id_type', // ← NOUVEAU CHAMP
            'ventilations.*.taux' => 'required|numeric|min:0|max:100',
            'ventilations.*.description' => 'nullable|string|max:255',
        ]);

        // Vérifier que le total des taux = 100%
        $totalTaux = collect($request->ventilations)->sum('taux');
        if (abs($totalTaux - 100) > 0.01) {
            return response()->json([
                'success' => false,
                'message' => "Le total des taux doit être égal à 100% (actuellement: $totalTaux%)"
            ], 422);
        }

        DB::beginTransaction();
        try {
            $results = [
                'updated' => 0,
                'created' => 0,
                'deleted' => 0
            ];

            // Récupérer les affectations existantes pour ce SOUS-COMPTE spécifique
            $existingAffectations = AffectationAnalytique::where('Id_Sous_compte', $request->Id_Sous_compte)
                ->get();

            // Séparer les ventilations à mettre à jour et à créer
            $ventilationsToUpdate = collect($request->ventilations)->filter(fn($v) => !empty($v['id_affectation']));
            $ventilationsToCreate = collect($request->ventilations)->filter(fn($v) => empty($v['id_affectation']));

            // 1. Mettre à jour les existantes
            foreach ($ventilationsToUpdate as $ventilation) {
                $affectation = $existingAffectations->firstWhere('id_affectation', $ventilation['id_affectation']);
                if ($affectation) {
                    $affectation->update([
                        'id_centre' => $ventilation['id_centre'],
                        'id_type'   => $ventilation['id_type'], // ← NOUVEAU CHAMP
                        'taux' => $ventilation['taux'],
                        'description' => $ventilation['description'] ?? $affectation->description,
                    ]);
                    $results['updated']++;
                }
            }

            // 2. Créer les nouvelles pour le SOUS-COMPTE spécifique
            foreach ($ventilationsToCreate as $ventilation) {
                // Vérifier si ça n'existe pas déjà
                $exists = $existingAffectations
                    ->where('id_centre', $ventilation['id_centre'])
                    ->first();

                if (!$exists) {
                    AffectationAnalytique::create([
                        'Id_Sous_compte' => $request->Id_Sous_compte,
                        'id_centre' => $ventilation['id_centre'],
                        'id_type'   => $ventilation['id_type'], // ← NOUVEAU CHAMP
                        'taux' => $ventilation['taux'],
                        'description' => $ventilation['description'] ?? 'Ventilation',
                    ]);
                    $results['created']++;
                }
            }

            // 3. Supprimer celles qui ne sont plus dans la liste
            $ventilationIdsToKeep = $ventilationsToUpdate->pluck('id_affectation')->filter();
            $affectationsToDelete = $existingAffectations->whereNotIn('id_affectation', $ventilationIdsToKeep);

            foreach ($affectationsToDelete as $affectation) {
                $affectation->delete();
                $results['deleted']++;
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => "Mise à jour réussie : {$results['updated']} modifiées, {$results['created']} créées, {$results['deleted']} supprimées",
                'data' => $results
            ]);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la mise à jour: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * 🔹 Mise à jour d'une affectation
     */
    public function update(Request $request, $id)
    {
        $affectation = AffectationAnalytique::findOrFail($id);

        $request->validate([
            'id_centre' => 'required|exists:centreanalytique,id_centre',
            'id_type'   => 'required|exists:typecentre,id_type', // ← NOUVEAU CHAMP
            'taux' => 'required|numeric|min:0|max:100',
            'description' => 'nullable|string|max:255',
        ]);

        $affectation->update([
            'id_centre' => $request->id_centre,
            'id_type'   => $request->id_type, // ← NOUVEAU CHAMP
            'taux' => $request->taux,
            'description' => $request->description ?? $affectation->description,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Ventilation mise à jour avec succès.',
            'data' => $affectation->fresh(['centre', 'sousCompte'])
        ]);
    }

    /**
     * 🔹 Supprime toutes les affectations d'un sous-compte
     */
    public function destroyBySousCompte($id_sous_compte)
    {
        $sousCompte = SousCompte::find($id_sous_compte);
        if (!$sousCompte) {
            return response()->json([
                'success' => false,
                'message' => 'Sous-compte non trouvé'
            ], 404);
        }

        $count = AffectationAnalytique::where('Id_Sous_compte', $id_sous_compte)->count();

        if ($count === 0) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune affectation trouvée pour ce sous-compte'
            ], 404);
        }

        AffectationAnalytique::where('Id_Sous_compte', $id_sous_compte)->delete();

        return response()->json([
            'success' => true,
            'message' => "$count affectation(s) supprimée(s) avec succès pour le sous-compte",
            'count' => $count
        ]);
    }

    /**
     * 🔹 Suppression avec rééquilibrage intelligent
     */
    public function destroy($id)
    {
        $affectation = AffectationAnalytique::findOrFail($id);

        $sousCompteId = $affectation->Id_Sous_compte;
        $tauxSupprime = $affectation->taux;

        $affectation->delete();

        $affectationsRestantes = AffectationAnalytique::where('Id_Sous_compte', $sousCompteId)->get();

        if ($affectationsRestantes->isEmpty()) {
            return response()->json([
                'message' => 'Affectation supprimée avec succès. Aucune ventilation restante.',
                'rebalanced' => false
            ]);
        }

        // Cas 1: Une seule ventilation restante → lui donner 100%
        if ($affectationsRestantes->count() === 1) {
            $affectationsRestantes->first()->update(['taux' => 100]);
            return response()->json([
                'message' => 'Affectation supprimée avec succès. La ventilation restante a été ajustée à 100%.',
                'rebalanced' => true
            ]);
        }

        // Cas 2: Plusieurs ventilations → répartir équitablement
        $tauxParAffectation = $tauxSupprime / $affectationsRestantes->count();

        foreach ($affectationsRestantes as $affectationRestante) {
            $nouveauTaux = round($affectationRestante->taux + $tauxParAffectation, 2);
            $affectationRestante->update(['taux' => $nouveauTaux]);
        }

        // Ajustement final pour exactement 100%
        $totalFinal = AffectationAnalytique::where('Id_Sous_compte', $sousCompteId)->sum('taux');
        $difference = round(100 - $totalFinal, 2);

        if (abs($difference) > 0.01) {
            $derniereAffectation = $affectationsRestantes->last();
            $derniereAffectation->update([
                'taux' => round($derniereAffectation->taux + $difference, 2)
            ]);
        }

        return response()->json([
            'message' => 'Affectation supprimée avec succès. Les taux ont été rééquilibrés automatiquement.',
            'rebalanced' => true
        ]);
    }

    /**
     * 🔹 Import CSV avec ventilation
     */
    public function importViaCompte(Request $request)
    {
        $request->validate([
            'file' => 'required|mimes:csv,txt'
        ]);

        $imported = 0;
        $skipped = 0;

        $file = $request->file('file');
        $path = $file->getRealPath();

        if (($handle = fopen($path, "r")) !== false) {
            $header = fgetcsv($handle, 1000, ";");

            while (($row = fgetcsv($handle, 1000, ";")) !== false) {
                $data = [];
                foreach ($header as $i => $key) {
                    $data[$key] = $row[$i] ?? null;
                }

                $codeCompte = strtolower(trim($data['compte'] ?? $row[0]));
                $nomCentre  = strtolower(trim($data['centre'] ?? $row[1]));
                $codeType   = strtolower(trim($data['code_type'] ?? $row[4])); // ← NOUVEAU CHAMP
                $taux       = floatval($data['taux'] ?? 100);
                $desc       = $data['description'] ?? '';

                $compte = Compte::whereRaw('LOWER("Code_compte") = ?', [$codeCompte])->first();
                $centre = CentreAnalytique::whereRaw('LOWER(nom) = ?', [$nomCentre])->first();
                $type = \App\Models\ParametresAnalytique\TypeCentre::whereRaw('LOWER(code) = ?', [$codeType])->first(); // ← NOUVEAU

                if (!$compte || !$centre || !$type) { // ← VÉRIFICATION TYPE AJOUTÉE
                    $skipped++;
                    continue;
                }

                $sousComptes = SousCompte::where('Id_Compte', $compte->Id_Compte)->get();

                foreach ($sousComptes as $sous) {
                    $exists = AffectationAnalytique::where('Id_Sous_compte', $sous->Id_Sous_compte)
                        ->where('id_centre', $centre->id_centre)
                        ->exists();

                    if ($exists) {
                        $skipped++;
                        continue;
                    }

                    AffectationAnalytique::create([
                        'Id_Sous_compte' => $sous->Id_Sous_compte,
                        'id_centre'      => $centre->id_centre,
                        'id_type'        => $type->id_type, // ← NOUVEAU CHAMP
                        'taux'           => $taux,
                        'description'    => $sous->Libelle . ($desc ? ' - ' . $desc : ''),
                    ]);

                    $imported++;
                }
            }

            fclose($handle);
        }

        return response()->json([
            'success'  => true,
            'imported' => $imported,
            'skipped'  => $skipped,
            'message'  => "Import terminé : $imported créés, $skipped ignorés."
        ]);
    }
    /**
 * 🔹 Import CSV avec ventilation directe par sous-comptes
 */
public function importDirecte(Request $request)
{
    $request->validate([
        'file' => 'required|mimes:csv,txt'
    ]);

    $imported = 0;
    $skipped = 0;

    $file = $request->file('file');
    $path = $file->getRealPath();

    if (($handle = fopen($path, "r")) !== false) {
        $header = fgetcsv($handle, 1000, ";");

        while (($row = fgetcsv($handle, 1000, ";")) !== false) {
            $data = [];
            foreach ($header as $i => $key) {
                $data[$key] = $row[$i] ?? null;
            }

            // Lecture directe du code sous-compte
            $codeSousCompte = strtolower(trim($data['sous_compte'] ?? $row[0]));
            $nomCentre      = strtolower(trim($data['centre'] ?? $row[1]));
            $codeType       = strtolower(trim($data['code_type'] ?? $row[4]));
            $taux           = floatval($data['taux'] ?? 100);
            $desc           = $data['description'] ?? '';

            // Recherche directe du sous-compte
            $sousCompte = SousCompte::whereRaw('LOWER("Code_sous_compte") = ?', [$codeSousCompte])->first();
            $centre = CentreAnalytique::whereRaw('LOWER(nom) = ?', [$nomCentre])->first();
            $type = \App\Models\ParametresAnalytique\TypeCentre::whereRaw('LOWER(code) = ?', [$codeType])->first();

            // Vérification que tous les éléments existent
            if (!$sousCompte || !$centre || !$type) {
                $skipped++;
                continue;
            }

            // Vérification si l'affectation existe déjà
            $exists = AffectationAnalytique::where('Id_Sous_compte', $sousCompte->Id_Sous_compte)
                ->where('id_centre', $centre->id_centre)
                ->exists();

            if ($exists) {
                $skipped++;
                continue;
            }

            // Création directe de l'affectation
            AffectationAnalytique::create([
                'Id_Sous_compte' => $sousCompte->Id_Sous_compte,
                'id_centre'      => $centre->id_centre,
                'id_type'        => $type->id_type,
                'taux'           => $taux,
                'description'    => $sousCompte->Libelle . ($desc ? ' - ' . $desc : ''),
            ]);

            $imported++;
        }

        fclose($handle);
    }

    return response()->json([
        'success'  => true,
        'imported' => $imported,
        'skipped'  => $skipped,
        'message'  => "Import terminé : $imported créés, $skipped ignorés."
    ]);
}



/**
 * 🔹 Affiche les sous-comptes non affectés avec pagination (Code_compte 600-799)
 */
public function sousComptesNonAffectesPagines(Request $request)
{
    $perPage = $request->get('per_page', 8);
    
    $sousComptesNonAffectes = SousCompte::whereNotIn('Id_Sous_compte', function($query) {
        $query->select('Id_Sous_compte')
              ->from('affectationanalytique');
    })
    ->whereHas('compte', function($query) {
        $query->whereBetween('Code_compte', [600, 799]);
    })
    ->with(['compte'])
    ->paginate($perPage);

    return response()->json([
        'success' => true,
        'data' => $sousComptesNonAffectes
    ]);
}

/**
 * 🔹 Crée une affectation pour un sous-compte spécifique
 */
public function storeForSousCompte(Request $request)
{
    $request->validate([
        'Id_Sous_compte' => 'required|exists:sous_comptes,Id_Sous_compte',
        'ventilations' => 'required|array|min:1',
        'ventilations.*.id_centre' => 'required|exists:centreanalytique,id_centre',
        'ventilations.*.id_type' => 'required|exists:typecentre,id_type',
        'ventilations.*.taux' => 'required|numeric|min:0|max:100',
        'ventilations.*.description' => 'nullable|string|max:255',
    ]);

    // Vérifier que le total des taux = 100%
    $totalTaux = collect($request->ventilations)->sum('taux');
    if (abs($totalTaux - 100) > 0.01) {
        return response()->json([
            'success' => false,
            'message' => "Le total des taux doit être égal à 100% (actuellement: $totalTaux%)"
        ], 422);
    }

    // Vérifier que le sous-compte existe
    $sousCompte = SousCompte::find($request->Id_Sous_compte);
    if (!$sousCompte) {
        return response()->json([
            'success' => false,
            'message' => "Sous-compte non trouvé"
        ], 422);
    }

    $affectations = [];
    $doublons = [];

    foreach ($request->ventilations as $ventilation) {
        $existeDeja = AffectationAnalytique::where('Id_Sous_compte', $request->Id_Sous_compte)
            ->where('id_centre', $ventilation['id_centre'])
            ->exists();

        if ($existeDeja) {
            $centreNom = CentreAnalytique::find($ventilation['id_centre'])->nom ?? $ventilation['id_centre'];
            $doublons[] = 'Centre ' . $centreNom;
            continue;
        }

        $affectations[] = AffectationAnalytique::create([
            'Id_Sous_compte' => $request->Id_Sous_compte,
            'id_centre'      => $ventilation['id_centre'],
            'id_type'        => $ventilation['id_type'],
            'taux'           => $ventilation['taux'],
            'description'    => $ventilation['description'] ?? $sousCompte->Libelle . ' - Ventilation',
        ]);
    }

    $message = count($affectations) . ' affectation(s) créée(s) avec succès pour le sous-compte ' . $sousCompte->Code_sous_compte;
    
    if (count($doublons) > 0) {
        $message .= '. ' . count($doublons) . ' doublon(s) ignoré(s): ' . implode(', ', array_slice($doublons, 0, 5));
        if (count($doublons) > 5) {
            $message .= '...';
        }
    }

    return response()->json([
        'success' => true,
        'message' => $message,
        'data'    => $affectations,
        'doublons_ignores' => $doublons
    ], 201);
}
}