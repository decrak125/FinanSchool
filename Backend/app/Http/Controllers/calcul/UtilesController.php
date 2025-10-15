<?php

namespace App\Http\Controllers\calcul;

use App\Http\Controllers\Controller;
use App\Models\calcul\CompteCategories;
use App\Models\PlanCompte\SousCompte;
use App\Models\calcul\CategorieFonctionelles;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\DB;

class UtilesController extends Controller
{
    /**
     * Calcule la somme des montants pour une catégorie fonctionnelle
     * avec les dates paramétrables
     * exemple fiantsona azy
     * {
    *   "code_categorie": "AUTCHOP",
    *   "date_debut": "2025-01-01",
    *   "date_fin": "2025-12-31"
    *   }
     */
    public function getSommeParCategorie(Request $request)
    {
        $request->validate([
            'code_categorie' => 'required|string|exists:categorie_fonctionelles,code',
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $codeCategorie = $request->code_categorie;
        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        $resultat = DB::table('ligne_ecritures as le')
            ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
            ->join('compte_categories as cc', 'sc.Id_Sous_compte', '=', 'cc.id_sous_compte')
            ->join('categorie_fonctionelles as cf', 'cc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
            ->where('cf.code', $codeCategorie)
            ->where('cc.actif', true)
            ->where('le.statut', 'valide')
            ->whereBetween('le.date_validation', [$dateDebut, $dateFin])
            ->select(
                'cf.code',
                'cf.libelle',
                DB::raw('ABS(SUM(le."Debit" - le."Credit")) as montant_total')
            )
            ->groupBy('cf.id_categorie_fonctionelle', 'cf.code', 'cf.libelle')
            ->first();

        return response()->json([
            'success' => true,
            'categorie' => $resultat ? $resultat->libelle : null,
            'code' => $codeCategorie,
            'montant_total' => $resultat ? $resultat->montant_total : 0,
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ]
        ]);
    }

    /**
     * Calcule le total d'un groupe de catégories fonctionnelles
     */
    public static function calculerTotalCategorieGroupe(array $codesCategories, $dateDebut, $dateFin)
    {
        $total = 0;

        foreach ($codesCategories as $code) {
            $montant = self::calculerSommeCategorie($code, $dateDebut, $dateFin);
            $total += $montant ? $montant->montant_total : 0;
        }

        return $total;
    }

    /**
     * Version simplifiée pour usage interne
     */
    public static function calculerSommeCategorie($codeCategorie, $dateDebut, $dateFin)
    {
        return DB::table('ligne_ecritures as le')
            ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
            ->join('compte_categories as cc', 'sc.Id_Sous_compte', '=', 'cc.id_sous_compte')
            ->join('categorie_fonctionelles as cf', 'cc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
            ->where('cf.code', $codeCategorie)
            ->where('cc.actif', true)
            ->where('le.statut', 'valide')
            ->whereBetween('le.date_validation', [$dateDebut, $dateFin])
            ->select(
                'cf.code',
                'cf.libelle',
                DB::raw('ABS(SUM(le."Debit" - le."Credit")) as montant_total')
            )
            ->groupBy('cf.id_categorie_fonctionelle', 'cf.code', 'cf.libelle')
            ->first();
    }

}