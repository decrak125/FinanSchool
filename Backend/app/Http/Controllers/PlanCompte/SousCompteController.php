<?php

namespace App\Http\Controllers\PlanCompte;

use App\Http\Controllers\Controller;
use App\Models\PlanCompte\SousCompte;
use Illuminate\Http\Request;

class SousCompteController extends Controller
{
    public function index()
    {
        return SousCompte::with('compte')->get(); // inclure le compte lié
    }

    public function show($id)
    {
        return SousCompte::with('compte')->findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'suffixe' => 'required|string|max:10',
            'Libelle' => 'required|string|max:255',
            'Id_Compte' => 'required|exists:comptes,Id_Compte',
        ]);

        $compte = \App\Models\PlanCompte\Compte::findOrFail($request->Id_Compte);
        $codeSousCompte = $compte->Code_compte . str_pad($request->suffixe, 3, "0", STR_PAD_LEFT);

        // Vérifier si le code existe déjà
        if (\App\Models\PlanCompte\SousCompte::where('Code_sous_compte', $codeSousCompte)->exists()) {
            return response()->json(['message' => 'Ce code sous-compte existe déjà'], 422);
        }

        $sousCompte = new SousCompte();
        $sousCompte->Code_sous_compte = $codeSousCompte;
        $sousCompte->Libelle = $request->Libelle;
        $sousCompte->Id_Compte = $request->Id_Compte;
        $sousCompte->save();

        return response()->json($sousCompte->load('compte'));
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'suffixe' => 'required|string|max:10',
            'Libelle' => 'required|string|max:255',
            'Id_Compte' => 'required|exists:comptes,Id_Compte',
        ]);

        $sousCompte = SousCompte::findOrFail($id);
        $compte = \App\Models\PlanCompte\Compte::findOrFail($request->Id_Compte);
        $codeSousCompte = $compte->Code_compte . str_pad($request->suffixe, 3, "0", STR_PAD_LEFT);

        // Vérifier doublon, sauf pour le même en cours de modification
        if (SousCompte::where('Code_sous_compte', $codeSousCompte)
            ->where('Id_Sous_compte', '<>', $id)
            ->exists()) {
            return response()->json(['message' => 'Ce code sous-compte existe déjà'], 422);
        }

        $sousCompte->Code_sous_compte = $codeSousCompte;
        $sousCompte->Libelle = $request->Libelle;
        $sousCompte->Id_Compte = $request->Id_Compte;
        $sousCompte->save();

        return response()->json($sousCompte->load('compte'));
    }


    public function destroy($id)
    {
        $sousCompte = SousCompte::findOrFail($id);
        $sousCompte->delete();

        return response()->json(['message' => 'Sous-compte supprimé']);
    }
}
