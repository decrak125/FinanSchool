<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\calcul\UtilesController;

class IndicateurRentabiliteController extends Controller
{
    /**
     * Calcule la Marge Brute
     * Formule : (Chiffre d’affaires – Coût des ventes) / Chiffre d’affaires × 100
     */
    public function calculMargeBrute(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // CHIFFRE D'AFFAIRES (Comptes 700-709)
        $chiffreAffaires = UtilesController::calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin);

        // COÛT DES VENTES (Achats consommés - Comptes 601-609)
        $coutVentes = UtilesController::calculerTotalCategorieGroupe(['ACHATCONSOM'], $dateDebut, $dateFin);

        // CALCUL DE LA MARGE BRUTE
        $margeBrute = 0;
        $interpretation = "";

        if ($chiffreAffaires > 0) {
            $margeBrute = (($chiffreAffaires - $coutVentes) / $chiffreAffaires) * 100;
            
            // Interprétation du résultat
            if ($margeBrute > 40) {
                $interpretation = "Excellente marge brute - Très bonne performance commerciale";
            } elseif ($margeBrute > 25) {
                $interpretation = "Bonne marge brute - Performance commerciale satisfaisante";
            } elseif ($margeBrute > 15) {
                $interpretation = "Marge brute acceptable - Performance commerciale moyenne";
            } else {
                $interpretation = "Marge brute faible - Revoir la stratégie commerciale ou les coûts";
            }
        }

        return response()->json([
            'success' => true,
            'marge_brute' => [
                'valeur' => round($margeBrute, 2),
                'unite' => '%',
                'interpretation' => $interpretation
            ],
            'details_calcul' => [
                'chiffre_affaires' => $chiffreAffaires,
                'cout_ventes' => $coutVentes,
                'marge_absolue' => $chiffreAffaires - $coutVentes
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => '(Chiffre d\'affaires – Coût des ventes) / Chiffre d\'affaires × 100',
            'comptes_utilises' => [
                'chiffre_affaires' => 'Comptes 700-709 (CA)',
                'cout_ventes' => 'Comptes 601-609 (ACHATCONSOM)'
            ]
        ]);
    }

    /**
     * Compare la marge brute sur deux périodes
     */
    public function comparerMargeBrute(Request $request)
    {
        $request->validate([
            'periode1_debut' => 'required|date',
            'periode1_fin' => 'required|date|after_or_equal:periode1_debut',
            'periode2_debut' => 'required|date',
            'periode2_fin' => 'required|date|after_or_equal:periode2_debut'
        ]);

        $margePeriode1 = $this->getMargeBruteDirect($request->periode1_debut, $request->periode1_fin);
        $margePeriode2 = $this->getMargeBruteDirect($request->periode2_debut, $request->periode2_fin);

        $evolution = $margePeriode2 - $margePeriode1;
        $tauxEvolution = $margePeriode1 > 0 ? ($evolution / $margePeriode1) * 100 : 0;

        return response()->json([
            'success' => true,
            'comparaison' => [
                'periode1' => [
                    'debut' => $request->periode1_debut,
                    'fin' => $request->periode1_fin,
                    'marge_brute' => round($margePeriode1, 2) . '%'
                ],
                'periode2' => [
                    'debut' => $request->periode2_debut,
                    'fin' => $request->periode2_fin,
                    'marge_brute' => round($margePeriode2, 2) . '%'
                ],
                'evolution' => [
                    'valeur_absolue' => round($evolution, 2) . '%',
                    'taux_evolution' => round($tauxEvolution, 2) . '%',
                    'interpretation' => $evolution >= 0 ? 'Amélioration' : 'Dégradation'
                ]
            ]
        ]);
    }

    /**
     * Version simplifiée pour usage interne
     */
    private function getMargeBruteDirect($dateDebut, $dateFin)
    {
        $chiffreAffaires = calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin);
        $coutVentes = calculerTotalCategorieGroupe(['ACHATCONSOM'], $dateDebut, $dateFin);

        if ($chiffreAffaires > 0) {
            return (($chiffreAffaires - $coutVentes) / $chiffreAffaires) * 100;
        }

        return 0;
    }

    /**
     * Version statique pour usage externe
     */
    public static function getMargeBrute($dateDebut, $dateFin)
    {
        $controller = new self();
        return $controller->getMargeBruteDirect($dateDebut, $dateFin);
    }

    /**
     * Calcule la Marge d'exploitation (EBIT)
     * Formule : Résultat d'exploitation / Chiffre d'affaires × 100
     */
    public function calculMargeExploitationEBIT(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // RÉSULTAT D'EXPLOITATION (Produits d'exploitation - Charges d'exploitation)
        $resultatExploitation = $this->calculerResultatExploitation($dateDebut, $dateFin);

        // CHIFFRE D'AFFAIRES (Comptes 700-709)
        $chiffreAffaires = UtilesController::calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin);

        // CALCUL DE LA MARGE D'EXPLOITATION (EBIT)
        $margeExploitation = 0;
        $interpretation = "";

        if ($chiffreAffaires > 0) {
            $margeExploitation = ($resultatExploitation / $chiffreAffaires) * 100;
            
            // Interprétation du résultat
            if ($margeExploitation > 15) {
                $interpretation = "Excellente performance opérationnelle - Très bonne rentabilité";
            } elseif ($margeExploitation > 8) {
                $interpretation = "Bonne performance opérationnelle - Rentabilité satisfaisante";
            } elseif ($margeExploitation > 0) {
                $interpretation = "Performance opérationnelle acceptable - Rentabilité modérée";
            } else {
                $interpretation = "Performance opérationnelle déficitaire - Situation à améliorer";
            }
        }

        return response()->json([
            'success' => true,
            'marge_exploitation_ebit' => [
                'valeur' => round($margeExploitation, 2),
                'unite' => '%',
                'interpretation' => $interpretation
            ],
            'details_calcul' => [
                'resultat_exploitation' => $resultatExploitation,
                'chiffre_affaires' => $chiffreAffaires
                // 'composantes_resultat' => $this->getDetailsResultatExploitation($dateDebut, $dateFin)
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => 'Résultat d\'exploitation / Chiffre d\'affaires × 100',
            'definition' => 'Mesure la performance des activités principales de l\'établissement'
        ]);
    }

    /**
     * Calcule le résultat d'exploitation (Produits d'exploitation - Charges d'exploitation)
     */
    private function calculerResultatExploitation($dateDebut, $dateFin)
    {
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

        return $produitsExploitation - $chargesExploitation;
    }

    /**
     * Calcule la Marge nette
     * Formule : Résultat net / Chiffre d'affaires × 100
     */

    public function calculMargeNette(Request $request) // MBOLA YST
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // RÉSULTAT NET (après toutes les charges et produits)
        $resultatNet = 0; // MBOLA MIANDRY AN I CEDI

        // CHIFFRE D'AFFAIRES (Comptes 700-709)
        $chiffreAffaires = UtilesController::calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin);

        // CALCUL DE LA MARGE NETTE
        $margeNette = 0;
        $interpretation = "";

        if ($chiffreAffaires > 0) {
            $margeNette = ($resultatNet / $chiffreAffaires) * 100;
            
            // Interprétation du résultat
            if ($margeNette > 10) {
                $interpretation = "Excellente rentabilité nette - Très bon bénéfice final";
            } elseif ($margeNette > 5) {
                $interpretation = "Bonne rentabilité nette - Bénéfice final satisfaisant";
            } elseif ($margeNette > 0) {
                $interpretation = "Rentabilité nette acceptable - Bénéfice final modéré";
            } else {
                $interpretation = "Rentabilité nette négative - Déficit final";
            }
        }

        return response()->json([
            'success' => true,
            'marge_nette' => [
                'valeur' => round($margeNette, 2),
                'unite' => '%',
                'interpretation' => $interpretation
            ],
            'details_calcul' => [
                'resultat_net' => $resultatNet,
                'chiffre_affaires' => $chiffreAffaires,
                // 'composantes_resultat' => $this->getDetailsResultatNet($dateDebut, $dateFin)
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => 'Résultat net / Chiffre d\'affaires × 100',
            'definition' => 'Montre le bénéfice final par euro de ventes'
        ]);
    }

    /**
 * Calcule le ROE (Return on Equity)
 * Formule : Résultat net / Capitaux propres × 100
 */
public function calculROE(Request $request) // MBOLA YST
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // RÉSULTAT NET
    $resultatNet = 0;

    // CAPITAUX PROPRES (Comptes 100-149)
    $capitauxPropres = UtilesController::calculerTotalCategorieGroupe([
        'CAPITAL',  // Capital social (100-119)
        'PRIME',    // Primes (120-129)
        'EVAL',     // Écarts d'évaluation (130-139)
        'EQUIV',    // Écarts d'équivalence (140-149)
        'RESULT'    // Réserves et report à nouveau
    ], $dateDebut, $dateFin);

    // CALCUL DU ROE
    $roe = 0;
    $interpretation = "";

    if ($capitauxPropres > 0) {
        $roe = ($resultatNet / $capitauxPropres) * 100;
        
        // Interprétation du résultat
        if ($roe > 15) {
            $interpretation = "Excellente rentabilité des fonds propres";
        } elseif ($roe > 8) {
            $interpretation = "Bonne rentabilité des fonds propres";
        } elseif ($roe > 0) {
            $interpretation = "Rentabilité modérée des fonds propres";
        } else {
            $interpretation = "Rentabilité insuffisante des fonds propres";
        }
    }

    return response()->json([
        'success' => true,
        'roe' => [
            'valeur' => round($roe, 2),
            'unite' => '%',
            'interpretation' => $interpretation
        ],
        'details_calcul' => [
            'resultat_net' => $resultatNet,
            'capitaux_propres' => $capitauxPropres
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ],
        'formule' => 'Résultat net / Capitaux propres × 100',
        'definition' => 'Rendement des fonds propres'
    ]);
}

/**
 * Calcule le ROA (Return on Assets)
 * Formule : Résultat net / Total actif × 100
 */
public function calculROA(Request $request) // MBOLA YST
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // RÉSULTAT NET
    $resultatNet = 0;

    // TOTAL ACTIF (Somme de tous les actifs)
    $totalActif = UtilesController::calculerTotalCategorieGroupe([
        'IMMOINC',      // Immobilisations incorporelles (200-209)
        'IMMOCO',       // Immobilisations corporelles (210-219)
        'IMMOCOURS',    // Immobilisations en cours (230-239)
        'IMMOFIN',      // Immobilisations financières (260-279)
        'STOCKS',       // Stocks (310-399)
        'CLIENTS',      // Clients (410-419)
        'AUTCREANCES',  // Autres créances (420-499)
        'TRESO'         // Trésorerie (512)
    ], $dateDebut, $dateFin);

    // CALCUL DU ROA
    $roa = 0;
    $interpretation = "";

    if ($totalActif > 0) {
        $roa = ($resultatNet / $totalActif) * 100;
        
        // Interprétation du résultat
        if ($roa > 10) {
            $interpretation = "Excellente efficacité des actifs";
        } elseif ($roa > 5) {
            $interpretation = "Bonne efficacité des actifs";
        } elseif ($roa > 0) {
            $interpretation = "Efficacité modérée des actifs";
        } else {
            $interpretation = "Efficacité insuffisante des actifs";
        }
    }

    return response()->json([
        'success' => true,
        'roa' => [
            'valeur' => round($roa, 2),
            'unite' => '%',
            'interpretation' => $interpretation
        ],
        'details_calcul' => [
            'resultat_net' => $resultatNet,
            'total_actif' => $totalActif
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ],
        'formule' => 'Résultat net / Total actif × 100',
        'definition' => 'Efficacité globale des actifs'
    ]);
}

}