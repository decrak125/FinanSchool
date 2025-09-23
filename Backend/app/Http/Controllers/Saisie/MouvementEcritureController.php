<?php

namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saisie\MouvementEcriture;

class MouvementEcritureController extends Controller
{
    public function index()
    {
        return MouvementEcriture::all();
    }

    public function show($id)
    {
        return MouvementEcriture::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Date_mouvement' => 'required|date',
            'Numero_piece' => 'nullable|string|max:50',
            'Id_Journal' => 'required|exists:journals,Id_Journal',
        ]);

        return MouvementEcriture::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $mouvement = MouvementEcriture::findOrFail($id);
        $mouvement->update($request->all());

        return $mouvement;
    }

    public function destroy($id)
    {
        $mouvement = MouvementEcriture::findOrFail($id);
        $mouvement->delete();

        return response()->json(['message' => 'Mouvement supprimé']);
    }
}
