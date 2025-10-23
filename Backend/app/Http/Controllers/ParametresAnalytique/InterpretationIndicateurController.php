<?php

namespace App\Http\Controllers\ParametresAnalytique;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\InterpretationIndicateur;

class InterpretationIndicateurController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $interpretations = InterpretationIndicateur::with(['indicateurAnalytique', 'niveauAlerte'])
            ->orderBy('id_indicateur_analytique')
            ->orderBy('valeur', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $interpretations
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'id_indicateur_analytique' => 'required|exists:indicateurs_analytique,id_indicateur_analytique',
            'valeur' => 'required|numeric',
            'interpretation' => 'required|string',
            'id_niveau_alerte' => 'required|exists:niveau_alerte,id_niveau_alerte'
        ]);

        $interpretation = InterpretationIndicateur::create($request->all());

        // Charger les relations pour la réponse
        $interpretation->load(['indicateurAnalytique', 'niveauAlerte']);

        return response()->json([
            'success' => true,
            'message' => 'Interprétation créée avec succès',
            'data' => $interpretation
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $interpretation = InterpretationIndicateur::with(['indicateurAnalytique', 'niveauAlerte'])
            ->find($id);

        if (!$interpretation) {
            return response()->json([
                'success' => false,
                'message' => 'Interprétation non trouvée'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $interpretation
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $interpretation = InterpretationIndicateur::find($id);

        if (!$interpretation) {
            return response()->json([
                'success' => false,
                'message' => 'Interprétation non trouvée'
            ], 404);
        }

        $request->validate([
            'id_indicateur_analytique' => 'sometimes|required|exists:indicateurs_analytique,id_indicateur_analytique',
            'valeur' => 'sometimes|required|numeric',
            'interpretation' => 'sometimes|required|string',
            'id_niveau_alerte' => 'sometimes|required|exists:niveau_alerte,id_niveau_alerte'
        ]);

        $interpretation->update($request->all());

        // Recharger les relations
        $interpretation->load(['indicateurAnalytique', 'niveauAlerte']);

        return response()->json([
            'success' => true,
            'message' => 'Interprétation mise à jour avec succès',
            'data' => $interpretation
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $interpretation = InterpretationIndicateur::find($id);

        if (!$interpretation) {
            return response()->json([
                'success' => false,
                'message' => 'Interprétation non trouvée'
            ], 404);
        }

        $interpretation->delete();

        return response()->json([
            'success' => true,
            'message' => 'Interprétation supprimée avec succès'
        ]);
    }

    /**
     * Récupérer les interprétations par indicateur
     */
    public function getByIndicateur($idIndicateur)
    {
        $interpretations = InterpretationIndicateur::with('niveauAlerte')
            ->where('id_indicateur_analytique', $idIndicateur)
            ->orderBy('valeur', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $interpretations
        ]);
    }

    /**
     * Récupérer l'interprétation appropriée pour une valeur donnée
     */
    public function getInterpretationForValue(Request $request, $idIndicateur)
    {
        $request->validate([
            'valeur' => 'required|numeric'
        ]);

        $valeur = $request->valeur;

        $interpretation = InterpretationIndicateur::with('niveauAlerte')
            ->where('id_indicateur_analytique', $idIndicateur)
            ->where('valeur', '<=', $valeur)
            ->orderBy('valeur', 'desc')
            ->first();

        if (!$interpretation) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune interprétation trouvée pour cette valeur'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $interpretation
        ]);
    }
}