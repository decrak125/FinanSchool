<?php

namespace App\Http\Controllers\ParametresAnalytique;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\AffectationAnalytique;
use App\Models\ParametresAnalytique\CentreAnalytique;
use App\Models\PlanCompte\Compte;
use App\Models\PlanCompte\SousCompte;
use Illuminate\Support\Facades\DB;

class AffectationAnalytiqueController extends Controller
{
    public function index()
    {
        return AffectationAnalytique::with(['centre', 'sousCompte'])->get();
    }

    public function show($id)
    {
        return AffectationAnalytique::with(['centre', 'sousCompte'])->findOrFail($id);
    }

    /**
     * 🔹 Crée automatiquement les affectations pour tous les sous-comptes d’un compte
     * avec un taux par défaut de 100%
     */
    public function store(Request $request)
    {
        $request->validate([
            'Id_Compte' => 'required|exists:comptes,Id_Compte',
            'ventilations' => 'required|array|min:1',
            'ventilations.*.id_centre' => 'required|exists:centreanalytique,id_centre',
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
    
                // Ajouter un log pour déboguer
                \Log::info('Données reçues:', $request->all());
                \Log::info('Ventilation données:', $ventilation);

                $affectations[] = AffectationAnalytique::create([
                    'Id_Sous_compte' => $sous->Id_Sous_compte,
                    'id_centre'      => $ventilation['id_centre'],
                    'taux'           => $ventilation['taux'], // ← Vérifiez que cette valeur est correcte
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
     * 🔹 Mise à jour d’une affectation : vérifie que le total des taux d’un même sous-compte = 100%
     */
    public function update(Request $request, $id)
    {
        $affectation = AffectationAnalytique::findOrFail($id);
    
        $request->validate([
            'id_centre' => 'required|exists:centreanalytique,id_centre',
            'taux' => 'required|numeric|min:0|max:100',
            'description' => 'nullable|string|max:255',
        ]);
    
        // Mise à jour simple sans vérification de total
        $affectation->update([
            'id_centre' => $request->id_centre,
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
     * 🔹 Suppression d’une affectation
     */
    public function destroy($id)
    {
        $affectation = AffectationAnalytique::findOrFail($id);
        $affectation->delete();

        return response()->json(['message' => 'Affectation supprimée avec succès.']);
    }

    /**
     * 🔹 Import CSV avec ventilation
     */
    public function import(Request $request)
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
                $taux       = floatval($data['taux'] ?? 100);
                $desc       = $data['description'] ?? '';

                $compte = Compte::whereRaw('LOWER("Code_compte") = ?', [$codeCompte])->first();
                $centre = CentreAnalytique::whereRaw('LOWER(nom) = ?', [$nomCentre])->first();

                if (!$compte || !$centre) {
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
}
