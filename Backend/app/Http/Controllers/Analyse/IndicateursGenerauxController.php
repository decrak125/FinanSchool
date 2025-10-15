<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Events\MouvementCreated;
use App\Http\Controllers\calcul\UtilesController;

class IndicateursGenerauxController extends Controller
{
/**
     * Calcule la marge d'exploitation
     * Formule : (Produits d'exploitation - Charges d'exploitation) / Produits d'exploitation × 100
     */
    public function calculMargeExploitation(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // PRODUITS D'EXPLOITATION
        $produitsExploitation = UtilesController::calculerTotalCategorieGroupe([
            'CA',           // Chiffre d'affaires (700-709)
            'PRODSTOCK',    // Production stockée (710-715)
            'PRODIMMO',     // Production immobilisée (720-729)
            'SUBVENT',      // Subventions d'exploitation (740-749)
            'AUTPRODOP',    // Autres produits d'exploitation (750-759)
            'REPRISEPROV'   // Reprises sur provisions (780-789)
        ], $dateDebut, $dateFin);

        // CHARGES D'EXPLOITATION
        $chargesExploitation = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM',  // Achats consommés (601-609)
            'SERVEXT',      // Services extérieurs (611-619)
            'CHPERS',       // Charges de personnel (620-629)
            'AUTCHOP',      // Autres charges d'exploitation (630-639)
            'AMORTPROV'     // Dotations aux amortissements/provisions (640-649)
        ], $dateDebut, $dateFin);

        // CALCUL DE LA MARGE D'EXPLOITATION
        $margeExploitation = 0;
        $interpretation = "";

        if ($produitsExploitation > 0) {
            $margeExploitation = (($produitsExploitation - $chargesExploitation) / $produitsExploitation) * 100;
            
            // Interprétation du résultat
            if ($margeExploitation > 20) {
                $interpretation = "Excellente santé financière - Forte rentabilité";
            } elseif ($margeExploitation > 10) {
                $interpretation = "Bonne santé financière - Rentabilité satisfaisante";
            } elseif ($margeExploitation > 0) {
                $interpretation = "Situation acceptable - Rentabilité faible";
            } else {
                $interpretation = "Déficit d'exploitation - Situation préoccupante";
            }
        }

        return response()->json([
            'success' => true,
            'marge_exploitation' => [
                'valeur' => round($margeExploitation, 2),
                'unite' => '%',
                'interpretation' => $interpretation
            ],
            'details_calcul' => [
                'produits_exploitation' => $produitsExploitation,
                'charges_exploitation' => $chargesExploitation,
                'resultat_exploitation' => $produitsExploitation - $chargesExploitation
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => '(Produits d\'exploitation - Charges d\'exploitation) / Produits d\'exploitation × 100'
        ]);
    }
}