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

    public function store(Request $request)
    {
        $request->validate([
            'Id_Sous_compte' => 'required|exists:sous_comptes,Id_Sous_compte',
            'id_centre' => 'required|integer|exists:centreanalytique,id_centre',
            'description' => 'required|string|max:255',
        ]);

        return AffectationAnalytique::create($request->all());
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
