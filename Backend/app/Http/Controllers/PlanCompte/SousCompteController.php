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
            'Code_sous_compte' => 'required|string|unique:sous_comptes,Code_sous_compte',
            'Libelle' => 'required|string|max:255',
            'Id_Compte' => 'required|exists:comptes,Id_Compte',
        ]);

        return SousCompte::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $sousCompte = SousCompte::findOrFail($id);
        $sousCompte->update($request->all());

        return $sousCompte;
    }

    public function destroy($id)
    {
        $sousCompte = SousCompte::findOrFail($id);
        $sousCompte->delete();

        return response()->json(['message' => 'Sous-compte supprimé']);
    }
}
