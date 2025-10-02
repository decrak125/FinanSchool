<?php

namespace App\Http\Controllers\ParametresAnalytique;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\AffectationAnalytique;
use App\Models\ParametresAnalytique\CentreAnalytique;
use App\Models\PlanCompte\Compte;
use App\Models\PlanCompte\SousCompte;

class AffectationAnalytiqueController extends Controller
{
    public function index()
    {
        return AffectationAnalytique::with('centre','sousCompte')->get();
    }

    public function show($id)
    {
        return AffectationAnalytique::findOrFail($id);
    }

    // public function store(Request $request)
    // {
    //     $request->validate([
    //         'Id_Sous_compte' => 'required|exists:sous_comptes,Id_Sous_compte',
    //         'id_centre' => 'required|integer|exists:centreanalytique,id_centre',
    //         'description' => 'required|string|max:255',
    //     ]);

    //     return AffectationAnalytique::create($request->all());
    // }

    public function store(Request $request)
    {
        $request->validate([
            'Id_Compte' => 'required|exists:comptes,Id_Compte',
            'id_centre' => 'required|exists:centreanalytique,id_centre',
            'description' => 'nullable|string|max:255',
        ]);

        // Récupérer tous les sous-comptes liés au compte choisi
        $sousComptes = \App\Models\PlanCompte\SousCompte::where('Id_Compte', $request->Id_Compte)->get();

        $affectations = [];

        foreach ($sousComptes as $sous) {
            $affectations[] = \App\Models\ParametresAnalytique\AffectationAnalytique::create([
                'Id_Sous_compte' => $sous->Id_Sous_compte,
                'id_centre' => $request->id_centre,
                'description' => $sous->Libelle . ' - ' . $request->description,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => count($affectations) . ' affectations créées avec succès',
            'data' => $affectations
        ], 201);
    }




    public function update(Request $request, $id)
    {
        $affectation = AffectationAnalytique::findOrFail($id);
        $affectation->update($request->all());

        return $affectation;
    }

    public function destroy($id)
    {
        $affectation = AffectationAnalytique::findOrFail($id);
        $affectation->delete();

        return response()->json(['message' => 'AffectationAnalytique supprimée']);
    }

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
        $header = fgetcsv($handle, 1000, ","); // lire l'entête

        while (($row = fgetcsv($handle, 1000, ",")) !== false) {
            $data = [];
            foreach ($header as $i => $key) {
                $data[$key] = $row[$i] ?? null;
            }

            $codeCompte = strtolower(trim($data['compte'] ?? $row[0]));
            $nomCentre  = strtolower(trim($data['centre'] ?? $row[1]));
            $desc       = $data['description'] ?? $row[2] ?? '';

            // 🔹 Trouver le compte par Code_compte (insensible à la casse)
            $compte = Compte::whereRaw('LOWER("Code_compte") = ?', [$codeCompte])->first();

            // 🔹 Trouver le centre par son nom (insensible à la casse)
            $centre = CentreAnalytique::whereRaw('LOWER(nom) = ?', [$nomCentre])->first();

            if (!$compte || !$centre) {
                $skipped++;
                continue; // ignorer si compte ou centre invalide
            }

            // 🔹 Récupérer tous les sous-comptes liés au compte
            $sousComptes = SousCompte::where('Id_Compte', $compte->Id_Compte)->get();

            foreach ($sousComptes as $sous) {
                // Vérifier doublon : si une affectation existe déjà
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
        'message'  => "Import terminé : $imported affectations créées, $skipped ignorées."
    ]);
}


}
