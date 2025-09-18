<?php

namespace App\Http\Controllers\PlanCompte;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\PlanCompte\Classe;

class ClasseController extends Controller
{
    public function index()
    {
        return Classe::all();
    }

    public function show($id)
    {
        return Classe::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Code' => 'required|string|unique:classes,Code',
            'Libelle' => 'required|string|max:255',
        ]);

        return Classe::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $classe = Classe::findOrFail($id);
        $classe->update($request->all());

        return $classe;
    }

    public function destroy($id)
    {
        $classe = Classe::findOrFail($id);
        $classe->delete();

        return response()->json(['message' => 'Classe supprimée']);
    }
}
