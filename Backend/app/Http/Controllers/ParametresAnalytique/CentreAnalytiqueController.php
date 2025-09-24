<?php

namespace App\Http\Controllers\ParametresAnalytique;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\CentreAnalytique;

class CentreAnalytiqueController extends Controller
{
    public function index()
    {
        return CentreAnalytique::all();
    }

    public function show($id)
    {
        return CentreAnalytique::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nom' => 'required|string|max:150',
            'description' => 'required|string|max:100',
            'id_axe' => 'required|integer',
            'id_type' => 'required|integer',
        ]);

        return CentreAnalytique::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $centre = CentreAnalytique::findOrFail($id);
        $centre->update($request->all());

        return $centre;
    }

    public function destroy($id)
    {
        $centre = CentreAnalytique::findOrFail($id);
        $centre->delete();

        return response()->json(['message' => 'CentreAnalytique supprimé']);
    }
}
