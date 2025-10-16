<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\calcul\UtilesController;

class IndicateurLiquiditeController extends Controller
{
    /**
 * Calcule le Ratio de liquidité générale
 * Formule : Actif circulant / Passif à court terme
 */
public function calculRatioLiquiditeGenerale(Request $request)
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // ACTIF CIRCULANT
    $actifCirculant = UtilesController::calculerTotalCategorieGroupe([
        'STOCKS',       // Stocks (310-399)
        'CLIENTS',      // Clients (410-419)
        'AUTCREANCES',  // Autres créances (420-499)
        'TRESO'         // Trésorerie (512)
    ], $dateDebut, $dateFin);

    // PASSIF À COURT TERME
    $passifCourtTerme = UtilesController::calculerTotalCategorieGroupe([
        'FOURN',        // Fournisseurs (400-409)
        'DETTECT',      // Dettes court terme (420-449)
        'PROVC',        // Provisions court terme (480-489)
        'AUTDETTE',     // Autres dettes (450-499)
        'DECOUV'        // Découverts bancaires (519)
    ], $dateDebut, $dateFin);

    // CALCUL DU RATIO
    $ratio = 0;
    $interpretation = "";

    if ($passifCourtTerme > 0) {
        $ratio = $actifCirculant / $passifCourtTerme;
        
        // Interprétation du résultat
        if ($ratio > 1.5) {
            $interpretation = "Très bonne solvabilité à court terme - Excédent de liquidité";
        } elseif ($ratio > 1) {
            $interpretation = "Bonne solvabilité à court terme - Situation saine";
        } elseif ($ratio > 0.8) {
            $interpretation = "Solvabilité acceptable - Surveillance recommandée";
        } else {
            $interpretation = "Solvabilité insuffisante - Risque de liquidité";
        }
    }

    return response()->json([
        'success' => true,
        'ratio_liquidite_generale' => [
            'valeur' => round($ratio, 2),
            'interpretation' => $interpretation,
            'seuil_reference' => "> 1 indique une bonne solvabilité à court terme"
        ],
        'details_calcul' => [
            'actif_circulant' => $actifCirculant,
            'passif_court_terme' => $passifCourtTerme
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ],
        'formule' => 'Actif circulant / Passif à court terme',
        'definition' => 'Mesure la capacité à honorer les dettes à court terme'
    ]);
}

/**
 * Calcule la Trésorerie Nette
 * Formule : Encaissements - Décaissements
 */
public function calculTresorerieNette(Request $request)
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // ENCAISSEMENTS (Total des crédits)
    $encaissements = DB::table('ligne_ecritures')
        ->where('statut', 'valide')
        ->whereBetween('date_validation', [$dateDebut, $dateFin])
        ->sum('Credit');

    // DÉCAISSEMENTS (Total des débits)
    $decaissements = DB::table('ligne_ecritures')
        ->where('statut', 'valide')
        ->whereBetween('date_validation', [$dateDebut, $dateFin])
        ->sum('Debit');

    // TRÉSORERIE NETTE
    $tresorerieNette = $encaissements - $decaissements;
    
    // INTERPRÉTATION
    $interpretation = $tresorerieNette >= 0 
        ? "Excédent de trésorerie - Situation favorable"
        : "Déficit de trésorerie - Attention nécessaire";

    return response()->json([
        'success' => true,
        'tresorerie_nette' => [
            'valeur' => round($tresorerieNette, 2),
            'interpretation' => $interpretation
        ],
        'details_calcul' => [
            'encaissements' => $encaissements,
            'decaissements' => $decaissements
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ],
        'formule' => 'Encaissements - Décaissements',
        'definition' => 'Solde de trésorerie sur la période'
    ]);
}

/**
 * Calcule le Besoin en Fonds de Roulement (BFR)
 * Formule : (Stocks + Créances clients) - Dettes fournisseurs
 */
public function calculBFR(Request $request)
{
    $request->validate([
        'date_debut' => 'required|date',
        'date_fin' => 'required|date|after_or_equal:date_debut'
    ]);

    $dateDebut = $request->date_debut;
    $dateFin = $request->date_fin;

    // STOCKS
    $stocks = UtilesController::calculerTotalCategorieGroupe(['STOCKS'], $dateDebut, $dateFin);

    // CRÉANCES CLIENTS
    $creancesClients = UtilesController::calculerTotalCategorieGroupe(['CLIENTS'], $dateDebut, $dateFin);

    // DETTES FOURNISSEURS
    $dettesFournisseurs = UtilesController::calculerTotalCategorieGroupe(['FOURN'], $dateDebut, $dateFin);

    // CALCUL DU BFR
    $bfr = ($stocks + $creancesClients) - $dettesFournisseurs;
    
    // INTERPRÉTATION
    if ($bfr > 0) {
        $interpretation = "BFR positif - Besoin de financement du cycle d'exploitation";
    } elseif ($bfr < 0) {
        $interpretation = "BFR négatif - Ressource dégagée du cycle d'exploitation";
    } else {
        $interpretation = "BFR nul - Équilibre du cycle d'exploitation";
    }

    return response()->json([
        'success' => true,
        'bfr' => [
            'valeur' => round($bfr, 2),
            'interpretation' => $interpretation
        ],
        'details_calcul' => [
            'stocks' => $stocks,
            'creances_clients' => $creancesClients,
            'dettes_fournisseurs' => $dettesFournisseurs,
            'actif_circulant_exploitation' => $stocks + $creancesClients
        ],
        'periode' => [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin
        ],
        'formule' => '(Stocks + Créances clients) - Dettes fournisseurs',
        'definition' => 'Permet d\'évaluer le besoin financier d\'exploitation'
    ]);
}

}