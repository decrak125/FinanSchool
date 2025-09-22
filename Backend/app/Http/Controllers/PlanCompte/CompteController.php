<?php

namespace App\Http\Controllers\PlanCompte;

use App\Http\Controllers\Controller;
use App\Models\PlanCompte\Compte;
use App\Models\PlanCompte\Rubrique;
use Illuminate\Http\Request;

class CompteController extends Controller
{
    public function index()
    {
        return Compte::with('rubrique')->get(); // inclure la rubrique liée
    }

    public function show($id)
    {
        return Compte::with('rubrique')->findOrFail($id);
    }

    public function store(Request $request)
{
    $request->validate([
        'suffixe' => 'required|string|max:10',
        'Libelle' => 'required|string|max:255',
        'Id_Rubrique' => 'required|exists:rubriques,Id_Rubrique',
    ]);

    $rubrique = Rubrique::findOrFail($request->Id_Rubrique);

    // Code_compte = Code_rubrique + suffixe (ex: 20 + 1 = 201)
    $codeCompte = $rubrique->Code_rubrique . str_pad($request->suffixe, 1, "0", STR_PAD_LEFT);

    // Vérifier si le code existe déjà
    if (Compte::where('Code_compte', $codeCompte)->exists()) {
        return response()->json(['message' => 'Ce code compte existe déjà'], 422);
    }

    $compte = new Compte();
    $compte->Code_compte = $codeCompte;
    $compte->Libelle = $request->Libelle;
    $compte->Id_Rubrique = $rubrique->Id_Rubrique;
    $compte->save();

    return response()->json($compte->load('rubrique'));
}

public function update(Request $request, $id)
{
    $request->validate([
        'suffixe' => 'required|string|max:10',
        'Libelle' => 'required|string|max:255',
        'Id_Rubrique' => 'required|exists:rubriques,Id_Rubrique',
    ]);

    $compte = Compte::findOrFail($id);
    $rubrique = Rubrique::findOrFail($request->Id_Rubrique);

    // Reconstruire Code_compte = Code_rubrique + suffixe
    $codeCompte = $rubrique->Code_rubrique . str_pad($request->suffixe, 1, "0", STR_PAD_LEFT);

    // Vérifier doublon sauf pour le compte en cours
    if (Compte::where('Code_compte', $codeCompte)
        ->where('Id_Compte', '<>', $id)
        ->exists()) {
        return response()->json(['message' => 'Ce code compte existe déjà'], 422);
    }

    $compte->Code_compte = $codeCompte;
    $compte->Libelle = $request->Libelle;
    $compte->Id_Rubrique = $rubrique->Id_Rubrique;
    $compte->save();

    return response()->json($compte->load('rubrique'));
}


    public function destroy($id)
    {
        $compte = Compte::findOrFail($id);
        $compte->delete();

        return response()->json(['message' => 'Compte supprimé']);
    }
}
