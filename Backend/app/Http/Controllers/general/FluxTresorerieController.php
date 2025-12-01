<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
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

        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;
        $dateFinN1 = (new DateTime($dateDebut))->modify('-1 day')->format('Y-m-d');

        $get = function ($code, $dStart, $dEnd) {
            $r = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dStart, $dEnd);
            return $r && $r->montant_total ? floatval($r->montant_total) : 0;
        };

        $getVar = function ($code, $dStart, $dEnd) {
            $v = \App\Http\Controllers\calcul\UtilesController::calculerVariationCategorie($code, $dStart, $dEnd);
            return $v !== null ? floatval($v) : 0;
        };

        $getSoldeTresorerie = function ($date) use ($get) {
            return $get('TRESO',      $date, $date)   // comptes bancaires à vue
                 + $get('PLACEMENTS',$date, $date)   // équivalents de trésorerie
                 + $get('TRESOFONDS',$date, $date);  // caisse
        };

        /* ================= 1. RÉSULTAT NET (BASE) ================= */

        // Produits d’exploitation (7)
        $produitsExpl =
              $get('CA',        $dateDebut, $dateFin)
            + $get('PRODVENDU', $dateDebut, $dateFin)
            + $get('PRODLTTERM',$dateDebut, $dateFin)
            + $get('PRODIMMO',  $dateDebut, $dateFin)
            + $get('SUBVENT',   $dateDebut, $dateFin)
            + $get('AUTPRODOP', $dateDebut, $dateFin);

        // Charges d’exploitation (6)
        $chargesExpl =
              $get('ACHATCONSOM',$dateDebut, $dateFin)
            + $get('SERVEXT',    $dateDebut, $dateFin)
            + $get('IMPTAX',     $dateDebut, $dateFin)
            + $get('CHPERS',     $dateDebut, $dateFin)
            + $get('AUTCHOP',    $dateDebut, $dateFin);

        // Autres éléments
        $dotAmort   = $get('AMORTPROV',   $dateDebut, $dateFin);  // dotations aux amort/prov/pertes
        $reprises   = $get('REPRISEPROV', $dateDebut, $dateFin);  // reprises
        $prodFin    = $get('PRODFIN',     $dateDebut, $dateFin);
        $chargeFin  = $get('CHARGEFIN',   $dateDebut, $dateFin);
        $prodExcept = $get('PRODEXCEPT',  $dateDebut, $dateFin);
        $charExcept = $get('CHAREXCEPT',  $dateDebut, $dateFin);
        $impotExig  = $get('IMPOT',       $dateDebut, $dateFin);
        $impotDiff  = $get('IMPOTDIFF',   $dateDebut, $dateFin);

        $totalProduits = $produitsExpl + $prodFin + $prodExcept + $reprises;
        $totalCharges  = $chargesExpl + $chargeFin + $charExcept + $dotAmort + $impotExig + $impotDiff;
        $resultatNet   = $totalProduits - $totalCharges;

        /* ================= A. FLUX DE TRÉSORERIE LIÉS À L’ACTIVITÉ ================= */

        // 1) Retraitements non monétaires
        $plusMoinsValues     = $prodExcept - $charExcept;               // plus/moins-values nettes
        $variationImpotsDiff = $getVar('IMPOTDIFF', $dateDebut, $dateFin);

        // 2) Variation du BFR (stocks + créances – dettes d’exploitation)
        $variationStocks =
            $getVar('STOCKS', $dateDebut, $dateFin);

        $variationCreancesExpl =
              $getVar('CLIENTS',     $dateDebut, $dateFin)
            + $getVar('AUTCREANCES', $dateDebut, $dateFin);

        $variationDettesExpl =
              $getVar('FOURN',    $dateDebut, $dateFin)
            + $getVar('DETTECT',  $dateDebut, $dateFin)
            + $getVar('AUTDETTE', $dateDebut, $dateFin);

        // Formule indirecte PCG:
        // A = Résultat net
        //   + Dotations – Reprises
        //   − Plus/moins-values
        //   + Variation impôts différés
        //   − Δ Stocks − Δ Créances d’exploitation + Δ Dettes d’exploitation
        $fluxActivite =
              $resultatNet
            + $dotAmort
            - $reprises
            - $plusMoinsValues
            + $variationImpotsDiff
            - $variationStocks
            - $variationCreancesExpl
            + $variationDettesExpl;

        /* ================= B. FLUX D’INVESTISSEMENT ================= */

        // Variation des immobilisations (20,21,22,23,26,27 via tes catégories)
        $variationImmo =
              $getVar('IMMOINC',     $dateDebut, $dateFin)
            + $getVar('IMMOCO',      $dateDebut, $dateFin)
            + $getVar('IMMOCONCESS', $dateDebut, $dateFin)
            + $getVar('IMMOCOURS',   $dateDebut, $dateFin)
            + $getVar('IMMOFIN',     $dateDebut, $dateFin);

        // Règle :
        // variationImmo > 0  => acquisitions nettes => décaissement
        // variationImmo < 0  => cessions nettes    => encaissement
        $acquisitionsImmo  = $variationImmo > 0 ? $variationImmo : 0;
        $cessionsImmo      = $variationImmo < 0 ? abs($variationImmo) : 0;

        // Flux B = - acquisitions + cessions
        $fluxInvestissement = -$acquisitionsImmo + $cessionsImmo;

        /* ================= C. FLUX DE FINANCEMENT ================= */

        // Augmentation (ou diminution) des capitaux propres en numéraire:
        // on retient la variation de CAPITAL + RESERVES
        $variationCapitalRes =
              $getVar('CAPITAL',  $dateDebut, $dateFin)
            + $getVar('RESERVES', $dateDebut, $dateFin);

        // Emprunts (classe 16)
        $variationEmprunt     = $getVar('EMPRUNT', $dateDebut, $dateFin);
        $emissionEmprunt      = $variationEmprunt > 0 ? $variationEmprunt : 0;
        $remboursementEmprunt = $variationEmprunt < 0 ? abs($variationEmprunt) : 0;

        // Dividendes versés (si tu as une catégorie DIVIDENDE, sinon 0)
        $dividendesVerses = $get('DIVIDENDE', $dateDebut, $dateFin);

        // Flux C = + apports + nouveaux emprunts − remboursements − dividendes
        $fluxFinancement =
              $variationCapitalRes
            + $emissionEmprunt
            - $remboursementEmprunt
            - $dividendesVerses;

        /* ================= VARIATION ET CONTROLE DE TRÉSORERIE ================= */

        $variationTresorerie = $fluxActivite + $fluxInvestissement + $fluxFinancement;

        $tresOuverture = $getSoldeTresorerie($dateFinN1);
        $tresCloture   = $getSoldeTresorerie($dateFin);

        $structure = [
            // A – Activité (indirecte)
            ['label' => "A. Flux de trésorerie liés aux activités opérationnelles", 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => "Résultat net de l'exercice",                               'note' => '',  'montant' => $resultatNet],
            ['label' => "Dotations aux amortissements, provisions et pertes de valeur", 'note' => '',  'montant' => $dotAmort],
            ['label' => "Reprises sur amortissements, provisions et pertes de valeur", 'note' => '',  'montant' => -$reprises],
            ['label' => "Plus ou moins-values de cession d'actifs",                 'note' => '',  'montant' => -$plusMoinsValues],
            ['label' => "Variation des impôts différés",                            'note' => '',  'montant' => $variationImpotsDiff],
            ['label' => "Variation des stocks",                                     'note' => '',  'montant' => -$variationStocks],
            ['label' => "Variation des créances d'exploitation",                    'note' => '',  'montant' => -$variationCreancesExpl],
            ['label' => "Variation des dettes d'exploitation",                      'note' => '',  'montant' => $variationDettesExpl],
            ['label' => "Flux nets de trésorerie générés par l'activité (A)",       'note' => 'A', 'montant' => $fluxActivite, 'isTotal' => true],

            // B – Investissement
            ['label' => "B. Flux de trésorerie liés aux opérations d'investissement", 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => "Acquisitions d'immobilisations",                             'note' => '', 'montant' => -$acquisitionsImmo],
            ['label' => "Cessions d'immobilisations",                                 'note' => '', 'montant' => $cessionsImmo],
            ['label' => "Flux nets de trésorerie liés à l'investissement (B)",        'note' => 'B','montant' => $fluxInvestissement, 'isTotal' => true],

            // C – Financement
            ['label' => "C. Flux de trésorerie liés aux activités de financement",  'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => "Augmentation / diminution de capital et réserves",         'note' => '', 'montant' => $variationCapitalRes],
            ['label' => "Dividendes versés",                                        'note' => '', 'montant' => -$dividendesVerses],
            ['label' => "Emissions d'emprunts",                                     'note' => '', 'montant' => $emissionEmprunt],
            ['label' => "Remboursements d'emprunts",                                'note' => '', 'montant' => -$remboursementEmprunt],
            ['label' => "Flux nets de trésorerie liés au financement (C)",          'note' => 'C','montant' => $fluxFinancement, 'isTotal' => true],

            // Synthèse
            ['label' => "Variation nette de trésorerie (A + B + C)",                'note' => '', 'montant' => $variationTresorerie, 'isTotal' => true],
            ['label' => "Trésorerie au début de la période",                        'note' => '', 'montant' => $tresOuverture],
            ['label' => "Trésorerie à la fin de la période",                        'note' => '', 'montant' => $tresCloture],
        ];

        return response()->json($structure);
    }
}
