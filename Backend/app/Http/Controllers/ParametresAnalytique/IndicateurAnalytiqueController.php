<?php

namespace App\Http\Controllers\ParametresAnalytique;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\IndicateurAnalytique;

class IndicateurAnalytiqueController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $indicateurs = IndicateurAnalytique::with('interpretations.niveauAlerte')
            ->orderBy('id_indicateur_analytique')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $indicateurs
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'libelle' => 'required|string|max:255',
            'description' => 'required|string',
            'formule' => 'required|string'
        ]);

        $indicateur = IndicateurAnalytique::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Indicateur analytique créé avec succès',
            'data' => $indicateur
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $indicateur = IndicateurAnalytique::with('interpretations.niveauAlerte')
            ->find($id);

        if (!$indicateur) {
            return response()->json([
                'success' => false,
                'message' => 'Indicateur analytique non trouvé'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $indicateur
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $indicateur = IndicateurAnalytique::find($id);

        if (!$indicateur) {
            return response()->json([
                'success' => false,
                'message' => 'Indicateur analytique non trouvé'
            ], 404);
        }

        $request->validate([
            'libelle' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'formule' => 'sometimes|required|string'
        ]);

        $indicateur->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Indicateur analytique mis à jour avec succès',
            'data' => $indicateur
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $indicateur = IndicateurAnalytique::find($id);

        if (!$indicateur) {
            return response()->json([
                'success' => false,
                'message' => 'Indicateur analytique non trouvé'
            ], 404);
        }

        $indicateur->delete();

        return response()->json([
            'success' => true,
            'message' => 'Indicateur analytique supprimé avec succès'
        ]);
    }

    /**
     * Récupérer les indicateurs par catégorie
     */
    public function getByCategorie($categorie)
    {
        $indicateurs = IndicateurAnalytique::where('description', 'LIKE', "%{$categorie}%")
            ->orWhere('libelle', 'LIKE', "%{$categorie}%")
            ->with('interpretations.niveauAlerte')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $indicateurs
        ]);
    }
}