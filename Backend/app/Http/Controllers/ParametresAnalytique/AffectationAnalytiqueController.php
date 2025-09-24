<?php

namespace App\Http\Controllers\ParametresAnalytique;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\AffectationAnalytique;

class AffectationAnalytiqueController extends Controller
{
    public function index()
    {
        return AffectationAnalytique::all();
    }

    public function show($id)
    {
        return AffectationAnalytique::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Id_Sous_compte' => 'required|integer',
            'id_centre' => 'required|integer',
            'description' => 'required|string|max:100',
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
