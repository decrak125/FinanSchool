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
    // public function getSommeParCategorie(Request $request)
    // {
    //     $request->validate([
    //         'code_categorie' => 'required|string|exists:categorie_fonctionelles,code',
    //         'date_debut' => 'required|date',
    //         'date_fin' => 'required|date|after_or_equal:date_debut'
    //     ]);

    //     $codeCategorie = $request->code_categorie;
    //     $dateDebut = $request->date_debut;
    //     $dateFin = $request->date_fin;

    //     $resultat = DB::table('ligne_ecritures as le')
    //         ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
    //         ->join('compte_categories as cc', 'sc.Id_Sous_compte', '=', 'cc.id_sous_compte')
    //         ->join('categorie_fonctionelles as cf', 'cc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
    //         ->where('cf.code', $codeCategorie)
    //         ->where('cc.actif', true)
    //         ->where('le.statut', 'valide')
    //         ->whereBetween('le.date_validation', [$dateDebut, $dateFin])
    //         ->select(
    //             'cf.code',
    //             'cf.libelle',
    //             DB::raw('ABS(SUM(le."Debit" - le."Credit")) as montant_total')
    //         )
    //         ->groupBy('cf.id_categorie_fonctionelle', 'cf.code', 'cf.libelle')
    //         ->first();

    //     return response()->json([
    //         'success' => true,
    //         'categorie' => $resultat ? $resultat->libelle : null,
    //         'code' => $codeCategorie,
    //         'montant_total' => $resultat ? $resultat->montant_total : 0,
    //         'periode' => [
    //             'date_debut' => $dateDebut,
    //             'date_fin' => $dateFin
    //         ]
    //     ]);
    // }

public function getSommeParCategorie(Request $request)
{
    $request->validate([
        'code_categorie' => 'required|string|exists:categorie_fonctionelles,code',
        'date_debut' => 'required|date',
        'date_fin'   => 'required|date|after_or_equal:date_debut'
    ]);
    $codeCategorie = $request->code_categorie;
    $dateDebut = $request->date_debut;
    $dateFin   = $request->date_fin;

    $idsSousComptes = DB::table('compte_categories as cc')
        ->join('categorie_fonctionelles as cf', 'cc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
        ->where('cf.code', $codeCategorie)
        ->where('cc.actif', true)
        ->pluck('cc.id_sous_compte');

    $codesSousComptes = DB::table('sous_comptes')
        ->whereIn('Id_Sous_compte', $idsSousComptes)
        ->pluck('Code_sous_compte');

    $resultat = DB::table('vue_balance_generale as vbg')
        ->whereIn('vbg.code_sous_compte', $codesSousComptes)
        ->whereBetween('vbg.date_mouvement', [$dateDebut, $dateFin])
        ->selectRaw('ABS(SUM(vbg.solde_final)) as montant_total')
        ->first();

    return response()->json([
        'success' => true,
        'categorie' => $codeCategorie,
        'montant_total' => $resultat ? $resultat->montant_total : 0,
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin'   => $dateFin
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
    // public static function calculerSommeCategorie($codeCategorie, $dateDebut, $dateFin)
    // {
    //     return DB::table('ligne_ecritures as le')
    //         ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
    //         ->join('compte_categories as cc', 'sc.Id_Sous_compte', '=', 'cc.id_sous_compte')
    //         ->join('categorie_fonctionelles as cf', 'cc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
    //         ->where('cf.code', $codeCategorie)
    //         ->where('cc.actif', true)
    //         ->where('le.statut', 'valide')
    //         ->whereBetween('le.date_validation', [$dateDebut, $dateFin])
    //         ->select(
    //             'cf.code',
    //             'cf.libelle',
    //             DB::raw('ABS(SUM(le."Debit" - le."Credit")) as montant_total')
    //         )
    //         ->groupBy('cf.id_categorie_fonctionelle', 'cf.code', 'cf.libelle')
    //         ->first();
    // }

public static function calculerSommeCategorie($codeCategorie, $dateDebut, $dateFin)
{
    // 1. Trouver les Id_Sous_compte associés à la catégorie
    $idsSousComptes = DB::table('compte_categories as cc')
        ->join('categorie_fonctionelles as cf', 'cc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
        ->where('cf.code', $codeCategorie)
        ->where('cc.actif', true)
        ->pluck('cc.id_sous_compte');

    // 2. Récupérer les codes des sous-comptes correspondants
    $codesSousComptes = DB::table('sous_comptes')
        ->whereIn('Id_Sous_compte', $idsSousComptes)
        ->pluck('Code_sous_compte');

    // 3. Calculer le montant total en utilisant la vue
    $resultat = DB::table('vue_balance_generale as vbg')
        ->whereIn('vbg.code_sous_compte', $codesSousComptes)
        ->whereBetween('vbg.date_mouvement', [$dateDebut, $dateFin])
        ->selectRaw(
            '? as code, NULL as libelle, ABS(SUM(vbg.solde_final)) as montant_total',
            [$codeCategorie]
        )
        ->first();

    // Structure du retour conforme à l'ancienne fonction
    return $resultat;
}


public static function calculerVariationCategorie($codeCategorie, $dateDebut, $dateFin)
{
    // Solde à la date de début
    $resultatDebut = self::calculerSommeCategorie($codeCategorie, $dateDebut, $dateDebut);
    $montantDebut = $resultatDebut && $resultatDebut->montant_total ? floatval($resultatDebut->montant_total) : 0;

    // Solde à la date de fin
    $resultatFin = self::calculerSommeCategorie($codeCategorie, $dateFin, $dateFin);
    $montantFin = $resultatFin && $resultatFin->montant_total ? floatval($resultatFin->montant_total) : 0;

    return $montantFin - $montantDebut; // Variation N - N-1
}

public static function SommeCodeAnalytique($dateStart, $dateEnd, $code)
{
    $query = DB::table('ligne_ecritures as le')
        ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
        ->join('code_analytique as co', 'aa.id_code', '=', 'co.id_code')
        ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
        ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd]);

    if (!empty($code)) {
        $query->where('co.code', $code);
    }
    $sommeVentilee = $query->select(
        DB::raw('ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) as total_ventile')
    )->value('total_ventile');

    return $sommeVentilee;
}


}