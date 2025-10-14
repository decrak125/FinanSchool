<?php

namespace App\Http\Controllers\calcul;

use App\Http\Controllers\Controller;
use App\Models\calcul\IntervalleComptesCategorie;
use App\Models\calcul\CategorieFonctionelles;
use Illuminate\Http\Request;
class IntervalleComptesCategorieController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $intervalleComptes = IntervalleComptesCategorie::with('categorieFonctionelles')->get();
        return response()->json($intervalleComptes);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'compte_debut' => 'required|string|max:10',
            'compte_fin' => 'required|string|max:10',
            'id_categorie_fonctionelle' => 'required|exists:categorie_fonctionelles,id_categorie_fonctionelle',
        ]);

        $intervalleCompte = IntervalleComptesCategorie::create($validated);

        return response()->json([
            'message' => 'Intervalle de comptes créé avec succès',
            'data' => $intervalleCompte->load('categorieFonctionelles')
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(IntervalleComptesCategorie $intervalleComptesCategorie)
    {
        return response()->json($intervalleComptesCategorie->load('categorieFonctionelles'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, IntervalleComptesCategorie $intervalleComptesCategorie)
    {
        $validated = $request->validate([
            'compte_debut' => 'sometimes|required|string|max:10',
            'compte_fin' => 'sometimes|required|string|max:10',
            'id_categorie_fonctionelle' => 'sometimes|required|exists:categorie_fonctionelles,id_categorie_fonctionelle',
        ]);

        $intervalleComptesCategorie->update($validated);

        return response()->json([
            'message' => 'Intervalle de comptes mis à jour avec succès',
            'data' => $intervalleComptesCategorie->load('categorieFonctionelles')
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(IntervalleComptesCategorie $intervalleComptesCategorie)
    {
        $intervalleComptesCategorie->delete();

        return response()->json([
            'message' => 'Intervalle de comptes supprimé avec succès'
        ]);
    }

    /**
     * Recherche par catégorie fonctionnelle
     */
    public function findByCategorieFonctionelles($idCategorieFonctionelles)
    {
        $intervalles = IntervalleComptesCategorie::where('id_categorie_fonctionelle', $idCategorieFonctionelles)
            ->with('categorieFonctionelles')
            ->get();

        return response()->json($intervalles);
    }

    /**
     * Vérifie si un compte appartient à un intervalle
     */
    public function checkCompteInInterval(Request $request)
    {
        $validated = $request->validate([
            'compte' => 'required|string|max:10',
            'id_categorie_fonctionelle' => 'required|exists:categorie_fonctionelles,id_categorie_fonctionelle',
        ]);

        $intervalle = IntervalleComptesCategorie::where('id_categorie_fonctionelle', $validated['id_categorie_fonctionelle'])
            ->where('compte_debut', '<=', $validated['compte'])
            ->where('compte_fin', '>=', $validated['compte'])
            ->first();

        return response()->json([
            'exists' => !is_null($intervalle),
            'data' => $intervalle
        ]);
    }
}
