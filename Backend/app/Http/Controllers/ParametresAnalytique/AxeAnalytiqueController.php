<?php

namespace App\Http\Controllers\ParametresAnalytique;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\AxeAnalytique;

class AxeAnalytiqueController extends Controller
{
    public function index()
    {
        return AxeAnalytique::all();
    }

    public function show($id)
    {
        return AxeAnalytique::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'axe' => 'required|string|max:100',
            'description' => 'required|string|max:255',
        ]);

        return AxeAnalytique::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $axe = AxeAnalytique::findOrFail($id);
        $axe->update($request->all());

        return $axe;
    }

    public function destroy($id)
    {
        $axe = AxeAnalytique::findOrFail($id);
        $axe->delete();

        return response()->json(['message' => 'AxeAnalytique supprimé']);
    }
}
