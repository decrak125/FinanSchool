<?php

namespace App\Http\Controllers\ParametresAnalytique;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\NiveauAlerte;

class NiveauAlerteController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $niveaux = NiveauAlerte::with('interpretations.indicateurAnalytique')
            ->orderBy('id_niveau_alerte')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $niveaux
        ]);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $request->validate([
            'libelle' => 'required|string|max:100',
            'couleur' => 'required|string|max:20'
        ]);

        $niveau = NiveauAlerte::create($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Niveau d\'alerte créé avec succès',
            'data' => $niveau
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show($id)
    {
        $niveau = NiveauAlerte::with('interpretations.indicateurAnalytique')
            ->find($id);

        if (!$niveau) {
            return response()->json([
                'success' => false,
                'message' => 'Niveau d\'alerte non trouvé'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $niveau
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $niveau = NiveauAlerte::find($id);

        if (!$niveau) {
            return response()->json([
                'success' => false,
                'message' => 'Niveau d\'alerte non trouvé'
            ], 404);
        }

        $request->validate([
            'libelle' => 'sometimes|required|string|max:100',
            'couleur' => 'sometimes|required|string|max:20'
        ]);

        $niveau->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Niveau d\'alerte mis à jour avec succès',
            'data' => $niveau
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy($id)
    {
        $niveau = NiveauAlerte::find($id);

        if (!$niveau) {
            return response()->json([
                'success' => false,
                'message' => 'Niveau d\'alerte non trouvé'
            ], 404);
        }

        // Vérifier s'il y a des interprétations liées
        if ($niveau->interpretations()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Impossible de supprimer ce niveau d\'alerte car il est utilisé dans des interprétations'
            ], 422);
        }

        $niveau->delete();

        return response()->json([
            'success' => true,
            'message' => 'Niveau d\'alerte supprimé avec succès'
        ]);
    }
}