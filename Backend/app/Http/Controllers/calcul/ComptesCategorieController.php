<?php

namespace App\Http\Controllers\calcul;

use App\Http\Controllers\Controller;
use App\Models\calcul\CompteCategories;
use App\Models\PlanCompte\SousCompte;
use App\Models\calcul\CategorieFonctionelles;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ComptesCategorieController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $compteCategories = CompteCategories::with(['sousCompte', 'categorieFonctionelles'])->get();
        return response()->json($compteCategories);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'poids' => 'required|numeric|min:0',
            'date_debut' => 'required|date',
            'date_fin' => 'nullable|date|after:date_debut',
            'actif' => 'nullable|boolean',
            'id_sous_compte' => [
                'required',
                Rule::exists('sous_comptes', 'Id_Sous_compte')
            ],
            'id_categorie_fonctionelle' => [
                'required',
                Rule::exists('categorie_fonctionelles', 'id_categorie_fonctionelle')
            ],
        ]);

        $compteCategorie = CompteCategories::create($validated);

        return response()->json([
            'message' => 'Compte catégorie créé avec succès',
            'data' => $compteCategorie->load(['sousCompte', 'categorieFonctionelles'])
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(CompteCategories $compteCategories)
    {
        return response()->json($compteCategories->load(['sousCompte', 'categorieFonctionelles']));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, CompteCategories $compteCategories)
    {
        $validated = $request->validate([
            'poids' => 'sometimes|required|numeric|min:0',
            'date_debut' => 'sometimes|required|date',
            'date_fin' => 'nullable|date|after:date_debut',
            'actif' => 'nullable|boolean',
            'id_sous_compte' => [
                'sometimes',
                'required',
                Rule::exists('sous_comptes', 'Id_Sous_compte')
            ],
            'id_categorie_fonctionelle' => [
                'sometimes',
                'required',
                Rule::exists('categorie_fonctionelles', 'id_categorie_fonctionelle')
            ],
        ]);

        $compteCategories->update($validated);

        return response()->json([
            'message' => 'Compte catégorie mis à jour avec succès',
            'data' => $compteCategories->load(['sousCompte', 'categorieFonctionelles'])
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(CompteCategories $compteCategories)
    {
        $compteCategories->delete();

        return response()->json([
            'message' => 'Compte catégorie supprimé avec succès'
        ]);
    }

    /**
     * Récupère les comptes catégories actifs
     */
    public function getActifs()
    {
        $compteCategories = CompteCategories::where('actif', true)
            ->with(['sousCompte', 'categorieFonctionelles'])
            ->get();

        return response()->json($compteCategories);
    }

    /**
     * Récupère les comptes catégories par sous-compte
     */
    public function getBySousCompte($idSousCompte)
    {
        $compteCategories = CompteCategories::where('id_sous_compte', $idSousCompte)
            ->with(['sousCompte', 'categorieFonctionelles'])
            ->get();

        return response()->json($compteCategories);
    }

    /**
     * Récupère les comptes catégories par catégorie fonctionnelle
     */
    public function getByCategorieFonctionelle($idCategorieFonctionelle)
    {
        $compteCategories = CompteCategories::where('id_categorie_fonctionelle', $idCategorieFonctionelle)
            ->with(['sousCompte', 'categorieFonctionelles'])
            ->get();

        return response()->json($compteCategories);
    }

    /**
     * Récupère les comptes catégories valides pour une date donnée
     */
    public function getByDate(Request $request)
    {
        $validated = $request->validate([
            'date' => 'required|date'
        ]);

        $compteCategories = CompteCategories::where('date_debut', '<=', $validated['date'])
            ->where(function($query) use ($validated) {
                $query->where('date_fin', '>=', $validated['date'])
                      ->orWhereNull('date_fin');
            })
            ->where('actif', true)
            ->with(['sousCompte', 'categorieFonctionelles'])
            ->get();

        return response()->json($compteCategories);
    }

    /**
     * Active/désactive un compte catégorie
     */
    public function toggleActif(CompteCategories $compteCategories)
    {
        $compteCategories->update([
            'actif' => !$compteCategories->actif
        ]);

        return response()->json([
            'message' => 'Statut actif mis à jour avec succès',
            'data' => $compteCategories->load(['sousCompte', 'categorieFonctionelles'])
        ]);
    }

    /**
     * Vérifie la validité d'un compte catégorie pour une date donnée
     */
    public function checkValidite(Request $request, $id)
    {
        $validated = $request->validate([
            'date' => 'required|date'
        ]);

        $compteCategorie = CompteCategories::findOrFail($id);

        $estValide = $compteCategorie->date_debut <= $validated['date'] &&
                    ($compteCategorie->date_fin === null || $compteCategorie->date_fin >= $validated['date']) &&
                    $compteCategorie->actif;

        return response()->json([
            'est_valide' => $estValide,
            'compte_categorie' => $compteCategorie
        ]);
    }
}
