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
 * Calcule le Total des Produits
 * Somme des comptes de classe 7
 */
public function calculTotalProduits(Request $request)
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // TOTAL DES PRODUITS (Comptes de classe 7)
    $totalProduits = UtilesController::calculerTotalCategorieGroupe([
        'CA',           // Chiffre d'affaires (700-709)
        'PRODSTOCK',    // Production stockée (710-715)
        'PRODIMMO',     // Production immobilisée (720-729)
        'SUBVENT',      // Subventions d'exploitation (740-749)
        'AUTPRODOP',    // Autres produits d'exploitation (750-759)
        'PRODFIN',      // Produits financiers (760-769)
        'PRODEXCEPT',   // Produits exceptionnels (770-779)
        'REPRISEPROV'   // Reprises sur provisions (780-789)
    ], $dateDebut, $dateFin);

    return response()->json([
        'success' => true,
        'total_produits' => [
            'valeur' => round($totalProduits, 2),
            'definition' => 'Tous les revenus de l\'école'
        ],
        'details_comptes' => [
            'chiffre_affaires' => UtilesController::calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin),
            'produits_exploitation' => UtilesController::calculerTotalCategorieGroupe(['PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP'], $dateDebut, $dateFin),
            'produits_financiers' => UtilesController::calculerTotalCategorieGroupe(['PRODFIN'], $dateDebut, $dateFin),
            'produits_exceptionnels' => UtilesController::calculerTotalCategorieGroupe(['PRODEXCEPT'], $dateDebut, $dateFin),
            'reprises_provisions' => UtilesController::calculerTotalCategorieGroupe(['REPRISEPROV'], $dateDebut, $dateFin)
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ]
    ]);
}

/**
 * Calcule le Total des Charges
 * Somme des comptes de classe 6
 */
public function calculTotalCharges(Request $request)
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // TOTAL DES CHARGES (Comptes de classe 6)
    $totalCharges = UtilesController::calculerTotalCategorieGroupe([
        'ACHATCONSOM',  // Achats consommés (601-609)
        'SERVEXT',      // Services extérieurs (611-619)
        'CHPERS',       // Charges de personnel (620-629)
        'AUTCHOP',      // Autres charges d'exploitation (630-639)
        'AMORTPROV',    // Dotations aux amortissements/provisions (640-649)
        'CHARGEFIN',    // Charges financières (650-659)
        'CHAREXCEPT'    // Charges exceptionnelles (670-679)
    ], $dateDebut, $dateFin);

    return response()->json([
        'success' => true,
        'total_charges' => [
            'valeur' => round($totalCharges, 2),
            'definition' => 'Ensemble des dépenses'
        ],
        'details_comptes' => [
            'achats_consommes' => UtilesController::calculerTotalCategorieGroupe(['ACHATCONSOM'], $dateDebut, $dateFin),
            'services_exterieurs' => UtilesController::calculerTotalCategorieGroupe(['SERVEXT'], $dateDebut, $dateFin),
            'charges_personnel' => UtilesController::calculerTotalCategorieGroupe(['CHPERS'], $dateDebut, $dateFin),
            'autres_charges_exploitation' => UtilesController::calculerTotalCategorieGroupe(['AUTCHOP'], $dateDebut, $dateFin),
            'dotations_amortissements' => UtilesController::calculerTotalCategorieGroupe(['AMORTPROV'], $dateDebut, $dateFin),
            'charges_financieres' => UtilesController::calculerTotalCategorieGroupe(['CHARGEFIN'], $dateDebut, $dateFin),
            'charges_exceptionnelles' => UtilesController::calculerTotalCategorieGroupe(['CHAREXCEPT'], $dateDebut, $dateFin)
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ]
    ]);
}

/**
 * Calcule le Résultat net
 * Formule : Produits – Charges
 */
public function calculResultatNet(Request $request)
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // TOTAL PRODUITS
    $totalProduits = UtilesController::calculerTotalCategorieGroupe([
        'CA', 'PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP', 
        'PRODFIN', 'PRODEXCEPT', 'REPRISEPROV'
    ], $dateDebut, $dateFin);

    // TOTAL CHARGES
    $totalCharges = UtilesController::calculerTotalCategorieGroupe([
        'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 
        'AMORTPROV', 'CHARGEFIN', 'CHAREXCEPT'
    ], $dateDebut, $dateFin);

    // RÉSULTAT NET
    $resultatNet = $totalProduits - $totalCharges;
    
    // INTERPRÉTATION
    $interpretation = $resultatNet >= 0 
        ? "Bénéfice de l'exercice"
        : "Perte de l'exercice";

    return response()->json([
        'success' => true,
        'resultat_net' => [
            'valeur' => round($resultatNet, 2),
            'interpretation' => $interpretation,
            'definition' => 'Bénéfice ou perte de l\'exercice'
        ],
        'details_calcul' => [
            'total_produits' => $totalProduits,
            'total_charges' => $totalCharges
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ],
        'formule' => 'Produits – Charges'
    ]);
}

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