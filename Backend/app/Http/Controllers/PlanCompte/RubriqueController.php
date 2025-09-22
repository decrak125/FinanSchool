<?php

namespace App\Http\Controllers\PlanCompte;
use App\Http\Controllers\Controller;
use App\Models\PlanCompte\Rubrique;
use Illuminate\Http\Request;

class RubriqueController extends Controller
{
    public function index()
    {
        return Rubrique::with('classe')->get(); // inclure la classe liée
    }

    public function show($id)
    {
        return Rubrique::with('classe')->findOrFail($id);
    }

    public function store(Request $request)
{
    $request->validate([
        'suffixe' => 'required|string|max:10',
        'Libelle' => 'required|string|max:255',
        'Id_Classe' => 'required|exists:classes,Id_Classe',
    ]);

    $classe = \App\Models\PlanCompte\Classe::findOrFail($request->Id_Classe);

    // Code_rubrique = Code_classe + suffixe (2 chiffres)
    $codeRubrique = $classe->Code . str_pad($request->suffixe, 1, "0", STR_PAD_LEFT);

    // Vérifier si déjà existant
    if (\App\Models\PlanCompte\Rubrique::where('Code_rubrique', $codeRubrique)->exists()) {
        return response()->json(['message' => 'Cette rubrique existe déjà'], 422);
    }

    $rubrique = new \App\Models\PlanCompte\Rubrique();
    $rubrique->Code_rubrique = $codeRubrique;
    $rubrique->Libelle = $request->Libelle;
    $rubrique->Id_Classe = $classe->Id_Classe;
    $rubrique->save();

    return response()->json($rubrique->load('classe'));
}

public function update(Request $request, $id)
{
    $request->validate([
        'suffixe' => 'required|string|max:10',
        'Libelle' => 'required|string|max:255',
        'Id_Classe' => 'required|exists:classes,Id_Classe',
    ]);

    $rubrique = \App\Models\PlanCompte\Rubrique::findOrFail($id);
    $classe = \App\Models\PlanCompte\Classe::findOrFail($request->Id_Classe);

    $codeRubrique = $classe->Code . str_pad($request->suffixe, 1, "0", STR_PAD_LEFT);

    // Vérifier doublon sauf pour cette rubrique
    if (\App\Models\PlanCompte\Rubrique::where('Code_rubrique', $codeRubrique)
        ->where('Id_Rubrique', '<>', $id)
        ->exists()) {
        return response()->json(['message' => 'Cette rubrique existe déjà'], 422);
    }

    $rubrique->Code_rubrique = $codeRubrique;
    $rubrique->Libelle = $request->Libelle;
    $rubrique->Id_Classe = $classe->Id_Classe;
    $rubrique->save();

    return response()->json($rubrique->load('classe'));
}

    public function destroy($id)
    {
        $rubrique = Rubrique::findOrFail($id);
        $rubrique->delete();

        return response()->json(['message' => 'Rubrique supprimée']);
    }
}
