<?php

namespace App\Http\Controllers\ParametresAnalytique;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\TypeCentre;

class TypeCentreController extends Controller
{
    public function index()
    {
        return TypeCentre::all();
    }

    public function show($id)
    {
        return TypeCentre::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'code' => 'required|string|max:20',
            'libelle' => 'required|string|max:100',
        ]);

        return TypeCentre::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $type = TypeCentre::findOrFail($id);
        $type->update($request->all());

        return $type;
    }

    public function destroy($id)
    {
        $type = TypeCentre::findOrFail($id);
        $type->delete();

        return response()->json(['message' => 'TypeCentre supprimé']);
    }
}
