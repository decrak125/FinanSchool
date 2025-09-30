<?php

namespace App\Http\Controllers\ParametresAnalytique;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\AffectationAnalytique;

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
}
