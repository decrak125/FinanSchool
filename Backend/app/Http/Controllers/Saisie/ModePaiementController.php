<?php

namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saisie\ModePaiement;

class ModePaiementController extends Controller
{
    public function index()
    {
        return ModePaiement::all();
    }

    public function show($id)
    {
        return ModePaiement::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Libelle' => 'required|string|max:50|unique:mode_paiements,Libelle',
            'Abr' => 'required|string|max:50|unique:mode_paiements,Abr',
        ]);

        return ModePaiement::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $mode = ModePaiement::findOrFail($id);
        $mode->update($request->all());

        return $mode;
    }

    public function destroy($id)
    {
        $mode = ModePaiement::findOrFail($id);
        $mode->delete();

        return response()->json(['message' => 'Mode de paiement supprimé']);
    }
}
