<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\calcul\UtilesController;

class IndicateurSolvabiliteController extends Controller
{
    /**
 * Calcule le Ratio d'endettement
 * Formule : Dettes financières / Capitaux propres
 */
public function calculRatioEndettement(Request $request)
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // DETTES FINANCIÈRES
    $dettesFinancieres = UtilesController::calculerTotalCategorieGroupe([
        'EMPRUNT'   // Emprunts et dettes financières (160-169)
    ], $dateDebut, $dateFin);

    // CAPITAUX PROPRES
    $capitauxPropres = UtilesController::calculerTotalCategorieGroupe([
        'CAPITAL',  // Capital social (100-119)
        'PRIME',    // Primes (120-129)
        'EVAL',     // Écarts d'évaluation (130-139)
        'EQUIV',    // Écarts d'équivalence (140-149)
        'RESULT'    // Réserves et report à nouveau
    ], $dateDebut, $dateFin);

    // CALCUL DU RATIO D'ENDETTEMENT
    $ratio = 0;
    $interpretation = "";

    if ($capitauxPropres > 0) {
        $ratio = $dettesFinancieres / $capitauxPropres;
        
        // Interprétation du résultat
        if ($ratio < 0.5) {
            $interpretation = "Structure financière très solide - Faible endettement";
        } elseif ($ratio < 1) {
            $interpretation = "Structure financière saine - Endettement modéré";
        } elseif ($ratio < 2) {
            $interpretation = "Endettement élevé - Surveillance nécessaire";
        } else {
            $interpretation = "Endettement très élevé - Situation risquée";
        }
    }

    return response()->json([
        'success' => true,
        'ratio_endettement' => [
            'valeur' => round($ratio, 2),
            'interpretation' => $interpretation,
            'seuil_reference' => "Plus il est faible, plus la structure est solide"
        ],
        'details_calcul' => [
            'dettes_financieres' => $dettesFinancieres,
            'capitaux_propres' => $capitauxPropres
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ],
        'formule' => 'Dettes financières / Capitaux propres',
        'definition' => 'Mesure le niveau d\'endettement de l\'établissement'
    ]);
}

/**
 * Calcule l'Autonomie financière
 * Formule : Capitaux propres / Total bilan × 100
 */
public function calculAutonomieFinanciere(Request $request)
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // CAPITAUX PROPRES
    $capitauxPropres = UtilesController::calculerTotalCategorieGroupe([
        'CAPITAL',  // Capital social (100-119)
        'PRIME',    // Primes (120-129)
        'EVAL',     // Écarts d'évaluation (130-139)
        'EQUIV',    // Écarts d'équivalence (140-149)
        'RESULT'    // Réserves et report à nouveau
    ], $dateDebut, $dateFin);

    // TOTAL BILAN (Actif total ou Passif total)
    $totalBilan = UtilesController::calculerTotalCategorieGroupe([
        'IMMOINC',      // Immobilisations incorporelles (200-209)
        'IMMOCO',       // Immobilisations corporelles (210-219)
        'IMMOCOURS',    // Immobilisations en cours (230-239)
        'IMMOFIN',      // Immobilisations financières (260-279)
        'STOCKS',       // Stocks (310-399)
        'CLIENTS',      // Clients (410-419)
        'AUTCREANCES',  // Autres créances (420-499)
        'TRESO'         // Trésorerie (512)
    ], $dateDebut, $dateFin);

    // CALCUL DE L'AUTONOMIE FINANCIÈRE
    $autonomie = 0;
    $interpretation = "";

    if ($totalBilan > 0) {
        $autonomie = ($capitauxPropres / $totalBilan) * 100;
        
        // Interprétation du résultat
        if ($autonomie > 50) {
            $interpretation = "Très forte autonomie financière - Structure excellente";
        } elseif ($autonomie > 30) {
            $interpretation = "Bonne autonomie financière - Structure saine";
        } elseif ($autonomie > 20) {
            $interpretation = "Autonomie acceptable - Surveillance recommandée";
        } else {
            $interpretation = "Autonomie insuffisante - Dépendance financière élevée";
        }
    }

    return response()->json([
        'success' => true,
        'autonomie_financiere' => [
            'valeur' => round($autonomie, 2),
            'unite' => '%',
            'interpretation' => $interpretation,
            'seuil_reference' => "> 30% = bonne autonomie financière"
        ],
        'details_calcul' => [
            'capitaux_propres' => $capitauxPropres,
            'total_bilan' => $totalBilan
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ],
        'formule' => 'Capitaux propres / Total bilan × 100',
        'definition' => 'Mesure l\'indépendance financière de l\'établissement'
    ]);
}

    /**
     * Calcule la CAF (Cash Flow) approximative
     * Formule simplifiée : Résultat net + Dotations aux amortissements
     */
    private function calculerCAF($dateDebut, $dateFin) //MBOLA YST
    {
        // RÉSULTAT NET
        $resultatNet = 0;
        
        // DOTATIONS AUX AMORTISSEMENTS ET PROVISIONS
        $dotationsAmortissements = UtilesController::calculerTotalCategorieGroupe(['AMORTPROV'], $dateDebut, $dateFin);

        return $resultatNet + $dotationsAmortissements;
    }

/**
 * Calcule la Capacité de remboursement
 * Formule : Endettement net / CAF (Cash Flow)
 */
public function calculCapaciteRemboursement(Request $request)
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // ENDETTEMENT NET (Dettes financières)
    $endettementNet = UtilesController::calculerTotalCategorieGroupe([
        'EMPRUNT'   // Emprunts et dettes financières (160-169)
    ], $dateDebut, $dateFin);

    // CAF (Cash Flow) - Approximation par le résultat net + dotations
    $caf = $this->calculerCAF($dateDebut, $dateFin);

    // CALCUL DE LA CAPACITÉ DE REMBOURSEMENT
    $capaciteRemboursement = 0;
    $interpretation = "";

    if ($caf > 0) {
        $capaciteRemboursement = $endettementNet / $caf;
        
        // Interprétation du résultat
        if ($capaciteRemboursement < 3) {
            $interpretation = "Très bonne capacité de remboursement - Dette facilement remboursable";
        } elseif ($capaciteRemboursement < 5) {
            $interpretation = "Bonne capacité de remboursement - Dette gérable";
        } elseif ($capaciteRemboursement < 7) {
            $interpretation = "Capacité de remboursement acceptable - Surveillance nécessaire";
        } else {
            $interpretation = "Capacité de remboursement faible - Risque élevé";
        }
    }

    return response()->json([
        'success' => true,
        'capacite_remboursement' => [
            'valeur' => round($capaciteRemboursement, 2),
            'unite' => 'années',
            'interpretation' => $interpretation,
            'seuil_reference' => "Nombre d'années nécessaires pour rembourser la dette"
        ],
        'details_calcul' => [
            'endettement_net' => $endettementNet,
            'caf' => $caf
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ],
        'formule' => 'Endettement net / CAF (Cash Flow)',
        'definition' => 'Mesure le temps nécessaire pour rembourser la dette avec la CAF'
    ]);
}

}