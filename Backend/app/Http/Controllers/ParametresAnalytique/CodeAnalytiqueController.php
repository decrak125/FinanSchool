<?php

namespace App\Http\Controllers\ParametresAnalytique;

use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\CodeAnalytique;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class CodeAnalytiqueController extends Controller
{
    // 🔍 Liste tous les codes analytiques
    public function index()
    {
        return response()->json(CodeAnalytique::all());
    }

    // ➕ Crée un nouveau code analytique
    public function store(Request $request)
    {
        $validated = $request->validate([
            'code' => 'required|string|max:10|unique:code_analytique,code',
            'libelle' => 'required|string|max:150',
            'plage_de_extension' => 'nullable|string|max:20',
        ]);

        $code = CodeAnalytique::create($validated);
        return response()->json($code, 201);
    }

    // 📄 Affiche un code analytique spécifique
    public function show($id)
    {
        $code = CodeAnalytique::findOrFail($id);
        return response()->json($code);
    }

    // ✏️ Met à jour un code analytique
    public function update(Request $request, $id)
    {
        $code = CodeAnalytique::findOrFail($id);

        $validated = $request->validate([
            'code' => 'sometimes|string|max:10|unique:code_analytique,code,' . $id . ',id_code',
            'libelle' => 'sometimes|string|max:150',
            'plage_de_extension' => 'nullable|string|max:20',
        ]);

        $code->update($validated);
        return response()->json($code);
    }

    // ❌ Supprime un code analytique
    public function destroy($id)
    {
        $code = CodeAnalytique::findOrFail($id);
        $code->delete();

        return response()->json(['message' => 'Code supprimé avec succès']);
    }
}
