<?php

namespace App\Http\Controllers\Saisie;

use App\Models\Saisie\GrandLivre;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class GrandLivreController extends Controller
{
    /**
     * Display a listing of the grand livre data, with optional date filters.
     */
    public function index(Request $request)
    {
        $query = GrandLivre::query();

        if ($request->has('date_debut') && $request->has('date_fin')) {
            $query->whereBetween('date_mouvement', [$request->date_debut, $request->date_fin]);
        }

        $grandLivreData = $query->orderBy('code_compte')
            ->orderBy('code_sous_compte')
            ->orderBy('date_mouvement')
            ->get();

        return response()->json($grandLivreData);
    }

    /**
     * Show data for a specific account or sub-account, with optional date filters.
     */
    public function show(Request $request, $codeCompte, $codeSousCompte = null)
    {
        $query = GrandLivre::where('code_compte', $codeCompte);

        if ($codeSousCompte) {
            $query->where('code_sous_compte', $codeSousCompte);
        }

        if ($request->has('date_debut') && $request->has('date_fin')) {
            $query->whereBetween('date_mouvement', [$request->date_debut, $request->date_fin]);
        }

        $data = $query->orderBy('date_mouvement')->get();

        return response()->json($data);
    }

    /**
     * Récupère les écritures d'un seul compte (sans sous-compte spécifique)
     * avec filtres optionnels par date
     */
    public function getEcrituresCompte(Request $request, $codeCompte)
    {
        $query = GrandLivre::where('code_compte', $codeCompte);

        if ($request->has('date_debut') && $request->has('date_fin')) {
            $query->whereBetween('date_mouvement', [$request->date_debut, $request->date_fin]);
        }

        // Optionnel : filtrer par année et mois
        if ($request->has('annee')) {
            $query->whereYear('date_mouvement', $request->annee);
        }

        if ($request->has('mois')) {
            $query->whereMonth('date_mouvement', $request->mois);
        }

        $data = $query->orderBy('date_mouvement')
            ->orderBy('id') // ou un autre champ pour garantir l'ordre
            ->get();

        // Calcul du solde
        $solde = $data->sum('debit') - $data->sum('credit');

        return response()->json([
            'code_compte' => $codeCompte,
            'ecritures' => $data,
            'total_debit' => $data->sum('debit'),
            'total_credit' => $data->sum('credit'),
            'solde' => $solde
        ]);
    }

    /**
     * Alternative : version simplifiée pour récupérer seulement les écritures
     * sans les calculs de totaux
     */
    public function getEcrituresCompteSimple(Request $request, $codeCompte)
    {
        $query = GrandLivre::where('code_compte', $codeCompte);

        if ($request->has('date_debut') && $request->has('date_fin')) {
            $query->whereBetween('date_mouvement', [$request->date_debut, $request->date_fin]);
        }

        $data = $query->orderBy('date_mouvement')->get();

        return response()->json($data);
    }

public function getByCompte(Request $request, $codeCompte)
    {
        $query = GrandLivre::where('code_compte', $codeCompte);

        if ($request->has('date_debut') && $request->has('date_fin')) {
            $query->whereBetween('date_mouvement', [$request->date_debut, $request->date_fin]);
        }

        $ecritures = $query->orderBy('date_mouvement')
            ->orderBy('id')
            ->get();

        // Calcul des totaux
        $totalDebit = $ecritures->sum('Debit');
        $totalCredit = $ecritures->sum('Credit');
        $solde = $totalDebit - $totalCredit;

        // Récupérer le libellé du compte (prend le premier enregistrement)
        $libelleCompte = $ecritures->first()->libelle_compte ?? '';

        return response()->json([
            'code_compte' => $codeCompte,
            'libelle_compte' => $libelleCompte,
            'ecritures' => $ecritures,
            'total_debit' => (float)$totalDebit,
            'total_credit' => (float)$totalCredit,
            'solde' => (float)$solde
        ]);
    }
}