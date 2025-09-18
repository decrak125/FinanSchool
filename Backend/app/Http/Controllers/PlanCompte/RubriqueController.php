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
            'Code_rubrique' => 'required|string|unique:rubriques,Code_rubrique',
            'Libelle' => 'required|string|max:255',
            'Id_Classe' => 'required|exists:classes,Id_Classe',
        ]);

        return Rubrique::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $rubrique = Rubrique::findOrFail($id);
        $rubrique->update($request->all());

        return $rubrique;
    }

    public function destroy($id)
    {
        $rubrique = Rubrique::findOrFail($id);
        $rubrique->delete();

        return response()->json(['message' => 'Rubrique supprimée']);
    }
}
