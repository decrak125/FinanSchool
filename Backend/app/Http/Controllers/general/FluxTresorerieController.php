<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\calcul\UtilesController;
use App\Models\exercice\ExerciceComptable;
use DateTime;

class FluxTresorerieController extends Controller
{
    /**
     * Tableau des flux de trésorerie – Méthode INDIRECTE (PCG Madagascar 2005)
     */
    public function index(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);

        // ========= 1) Identifier N et N-1 via exercices =========
        $exN = ExerciceComptable::getExerciceByDate($request->date_fin);
        if (!$exN) {
            return response()->json(['error' => 'Aucun exercice trouvé pour cette date_fin'], 404);
        }

        $exN1 = ExerciceComptable::find($exN->Id_Exercice_comptable - 1); // N-1 = id-1 (ta règle)
        if (!$exN1) {
            return response()->json(['error' => 'Exercice N-1 introuvable (id-1)'], 404);
        }

        // Dates officielles de l'exercice N
        $dateDebut = $exN->Date_debut->format('Y-m-d');
        $dateFin   = $exN->Date_fin->format('Y-m-d');

        // Date de clôture N-1 (ouverture N = clôture N-1)
        $dateFinN1 = $exN1->Date_fin->format('Y-m-d');

        // Origine "intelligente" (pas 1900) : début du premier exercice en base
        $origine = ExerciceComptable::min('Date_debut');
        $origine = $origine ? (new DateTime($origine))->format('Y-m-d') : $dateDebut;

        // ========= 2) Helpers =========

        // 1. Somme des mouvements sur la période N (flux de période)
        $get = function ($code, $dStart, $dEnd) {
            $r = UtilesController::calculerSommeCategorie($code, $dStart, $dEnd);
            return $r && $r->montant_total ? floatval($r->montant_total) : 0;
        };

        // 2. Solde cumulé à une date (photo à date)
        $getSolde = function ($code, $date) use ($origine) {
            $solde = UtilesController::calculerVariationCategorie($code, $origine, $date);
            return $solde !== null ? floatval($solde) : 0;
        };

        // 3. Variation EXACTE demandée : solde(N-1) - solde(N)
        $getVar = function ($code) use ($getSolde, $dateFinN1, $dateFin) {
            return $getSolde($code, $dateFinN1) - $getSolde($code, $dateFin);
        };

        /* ==========================================================================
           1. CALCUL DU RÉSULTAT NET
           ========================================================================== */

        // Produits
        $produitsExpl = $get('CA', $dateDebut, $dateFin)
                      + $get('PRODVENDU', $dateDebut, $dateFin)
                      + $get('PRODLTTERM', $dateDebut, $dateFin)
                      + $get('PRODIMMO', $dateDebut, $dateFin)
                      + $get('SUBVENT', $dateDebut, $dateFin)
                      + $get('AUTPRODOP', $dateDebut, $dateFin);

        // Charges
        $chargesExpl  = $get('ACHATCONSOM', $dateDebut, $dateFin)
                      + $get('SERVEXT', $dateDebut, $dateFin)
                      + $get('IMPTAX', $dateDebut, $dateFin)
                      + $get('CHPERS', $dateDebut, $dateFin)
                      + $get('AUTCHOP', $dateDebut, $dateFin);

        // Financiers & Exceptionnels
        $dotAmort   = $get('AMORTPROV', $dateDebut, $dateFin);
        $reprises   = $get('REPRISEPROV', $dateDebut, $dateFin);
        $prodFin    = $get('PRODFIN', $dateDebut, $dateFin);
        $chargeFin  = $get('CHARGEFIN', $dateDebut, $dateFin);
        $prodExcept = $get('PRODEXCEPT', $dateDebut, $dateFin);
        $charExcept = $get('CHAREXCEPT', $dateDebut, $dateFin);
        $impotExig  = $get('IMPOT', $dateDebut, $dateFin);
        $impotDiffP = $get('IMPOTDIFF', $dateDebut, $dateFin);

        $totalProduits = $produitsExpl + $prodFin + $prodExcept + $reprises;
        $totalCharges  = $chargesExpl + $chargeFin + $charExcept + $dotAmort + $impotExig + $impotDiffP;

        $resultatNet = $totalProduits - $totalCharges;

        /* ==========================================================================
           A. FLUX DE TRÉSORERIE LIÉS À L’ACTIVITÉ
           ========================================================================== */

        $plusMoinsValues     = $prodExcept - $charExcept;

        // Variations = solde(N-1) - solde(N)
        $variationImpotsDiff = $getVar('IMPOTDIFF');
        $variationStocks     = $getVar('STOCKS');
        $variationCreances   = $getVar('CLIENTS') + $getVar('AUTCREANCES');
        $variationDettes     = $getVar('FOURN') + $getVar('DETTECT') + $getVar('AUTDETTE');

        // Avec (N-1 - N) :
        // - stocks/creances : + variation = effet cash (diminution => positif)
        // - dettes : effet cash = - variation
        $fluxActivite =
              $resultatNet
            + $dotAmort
            - $reprises
            - $plusMoinsValues
            + $variationImpotsDiff
            + $variationStocks
            + $variationCreances
            - $variationDettes;

        /* ==========================================================================
           B. FLUX D’INVESTISSEMENT
           ========================================================================== */

        $acqImmo =
              (UtilesController::calculerSommeCategorie('IMMOINC',     $dateDebut, $dateFin, 'debit')->montant_total ?? 0)
            + (UtilesController::calculerSommeCategorie('IMMOCO',      $dateDebut, $dateFin, 'debit')->montant_total ?? 0)
            + (UtilesController::calculerSommeCategorie('IMMOCONCESS', $dateDebut, $dateFin, 'debit')->montant_total ?? 0)
            + (UtilesController::calculerSommeCategorie('IMMOCOURS',   $dateDebut, $dateFin, 'debit')->montant_total ?? 0)
            + (UtilesController::calculerSommeCategorie('IMMOFIN',     $dateDebut, $dateFin, 'debit')->montant_total ?? 0);

        $cessionsImmo = $prodExcept;
        $fluxInvestissement = -$acqImmo + $cessionsImmo;

        /* ==========================================================================
           C. FLUX DE FINANCEMENT
           ========================================================================== */

        $variationCapitalRes = $getVar('CAPITAL') + $getVar('RESERVES');
        $variationEmprunt    = $getVar('EMPRUNT');
        $dividendesVerses    = $get('DIVIDENDE', $dateDebut, $dateFin);

        $fluxFinancement =
              -$variationCapitalRes
            - $variationEmprunt
            - $dividendesVerses;

        /* ==========================================================================
           SYNTHÈSE ET CONTRÔLE
           ========================================================================== */

        $variationTresorerie = $fluxActivite + $fluxInvestissement + $fluxFinancement;

        // Trésorerie N-1 et N (photo à la clôture)
        $tresOuverture = $getSolde('TRESO', $dateFinN1);
        $tresCloture   = $getSolde('TRESO', $dateFin);

        $ecart = $tresCloture - $tresOuverture;

        // VRAI contrôle : doit tendre vers 0
        $controle = $ecart;

        $structure = [
            ['label' => "Flux de trésorerie liés à l'activité", 'isTitle' => true],
            ['label' => "Résultat net de l'exercice", 'montant' => $resultatNet],
            ['label' => "Ajustements pour :", 'isSubtitle' => true],
            ['label' => "Amortissements et provisions", 'montant' => $dotAmort],
            ['label' => "Reprises sur provisions", 'montant' => -$reprises],
            ['label' => "Plus ou moins-values de cession", 'montant' => -$plusMoinsValues],

            ['label' => "Variation du BFR lié à l'activité :", 'isSubtitle' => true],
            // Ici on affiche l'effet cash (cohérent avec la formule ci-dessus)
            ['label' => "Variation des stocks", 'montant' => $variationStocks],
            ['label' => "Variation des clients et autres créances", 'montant' => $variationCreances],
            ['label' => "Variation des fournisseurs et autres dettes", 'montant' => -$variationDettes],

            ['label' => "Flux net de trésorerie généré par l'activité (A)", 'montant' => $fluxActivite, 'isTotal' => true],

            ['label' => "Flux de trésorerie liés aux investissements", 'isTitle' => true],
            ['label' => "Décaissements sur acquisitions d'immobilisations", 'montant' => -$acqImmo],
            ['label' => "Encaissements sur cessions d'immobilisations", 'montant' => $cessionsImmo],
            ['label' => "Flux net de trésorerie lié à l'investissement (B)", 'montant' => $fluxInvestissement, 'isTotal' => true],

            ['label' => "Flux de trésorerie liés au financement", 'isTitle' => true],
            ['label' => "Dividendes versés aux actionnaires", 'montant' => -$dividendesVerses],
            ['label' => "Augmentation de capital", 'montant' => -$variationCapitalRes],
            ['label' => "Variation des emprunts", 'montant' => -$variationEmprunt],
            ['label' => "Flux net de trésorerie lié au financement (C)", 'montant' => $fluxFinancement, 'isTotal' => true],

            ['label' => "Variation nette de la trésorerie (A+B+C)", 'montant' => $variationTresorerie, 'isTotal' => true],
            ['label' => "Trésorerie d'ouverture (clôture N-1)", 'montant' => $tresOuverture],
            ['label' => "Trésorerie de clôture (clôture N)", 'montant' => $tresCloture],
            ['label' => "Écart de contrôle (doit = 0)", 'montant' => $controle, 'isWarning' => (abs($controle) > 0.01)],
        ];

        return response()->json($structure);
    }
}
