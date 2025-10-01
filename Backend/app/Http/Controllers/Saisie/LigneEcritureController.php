<?php

namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saisie\LigneEcriture;
use App\Models\User;
use Illuminate\Support\Facades\Auth;


class LigneEcritureController extends Controller
{
    public function index()
    {
        return LigneEcriture::with('journal','sousCompte','mouvement','modePaiement')->get();
    }

    public function show($id)
    {
        return LigneEcriture::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Libelle' => 'required|string|max:255',
            'Debit' => 'required|numeric',
            'Credit' => 'required|numeric',
            'Reference' => 'nullable|string|max:50',
            'Quantite' => 'nullable|integer',
            'Id_Mode_paiement' => 'nullable|exists:mode_paiements,Id_Mode_paiement',
            'Id_Mouvement_ecriture' => 'required|exists:mouvement_ecritures,Id_Mouvement_ecriture',
            'Id_Journal' => 'required|exists:journals,Id_Journal',
            'Id_Sous_compte' => 'required|exists:sous_comptes,Id_Sous_compte',
        ]);

        return LigneEcriture::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $ligne = LigneEcriture::findOrFail($id);
        $ligne->update($request->all());

        return $ligne;
    }

    public function destroy($id)
    {
        $ligne = LigneEcriture::findOrFail($id);
        $ligne->delete();

        return response()->json(['message' => 'Ligne supprimée']);
    }

        public function valider($id)
    {
        $ecriture = LigneEcriture::findOrFail($id);

        if ($ecriture->statut === 'valide') {
            return response()->json(['message' => 'Cette écriture est déjà validée'], 400);
        }

        $ecriture->update([
            'statut' => 'valide',
            'date_validation' => now(),
            'valide_par' => Auth::user()->id, // utilise l'ID de l'utilisateur authentifié
        ]);

        return response()->json([
            'message' => 'Écriture validée avec succès',
            'data' => $ecriture
        ]);
    }

}
