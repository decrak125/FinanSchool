<?php

namespace App\Http\Controllers\PlanCompte;

use App\Http\Controllers\Controller;
use App\Models\PlanCompte\Compte;
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
            'Code_compte' => 'required|string|unique:comptes,Code_compte',
            'Libelle' => 'required|string|max:255',
            'Id_Rubrique' => 'required|exists:rubriques,Id_Rubrique',
        ]);

        return Compte::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $compte = Compte::findOrFail($id);
        $compte->update($request->all());

        return $compte;
    }

    public function destroy($id)
    {
        $compte = Compte::findOrFail($id);
        $compte->delete();

        return response()->json(['message' => 'Compte supprimé']);
    }
}
