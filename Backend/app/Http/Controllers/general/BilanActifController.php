<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class BilanActifController extends Controller
{
    /**
     * Bilan ACTIF conforme PCG Madagascar 2005
     * Structure: Brut | Amortissements/Provisions | Net
     */
    public function index(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);
        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

        // Helper brut
        $getBrut = function ($code) use ($dateDebut, $dateFin) {
            $r = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return $r && $r->montant_total ? floatval($r->montant_total) : 0;
        };

        // Helper amort / pertes de valeur
        $getAmort = function ($code) use ($dateDebut, $dateFin) {
            $r = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return $r && $r->montant_total ? floatval($r->montant_total) : 0;
        };

        // ================= ACTIFS NON COURANTS =================

        // Ecart d’acquisition (goodwill) – pas d’amortissement, seulement pertes de valeur
        $goodwillBrut  = $getBrut('GOODWILL');       // si tu as mappé 207/208
        $goodwillDep   = $getAmort('PERTEVAL_IMMO'); // part de 29 sur goodwill
        $goodwillNet   = $goodwillBrut - $goodwillDep;

        // Immobilisations incorporelles (20)
        $immoincBrut   = $getBrut('IMMOINC');        // 200-209
        $immoincAmort  = $getAmort('AMORT_IMMOINC'); // 280
        $immoincDep    = $getAmort('PERTEVAL_IMMO'); // 29x liés aux 20x
        $immoincTotalAmort = $immoincAmort + $immoincDep;
        $immoincNet    = $immoincBrut - $immoincTotalAmort;

        // Immobilisations corporelles (21)
        $immocoBrut    = $getBrut('IMMOCO');         // 210-219
        $immocoAmort   = $getAmort('AMORT_IMMOCO');  // 281-289
        $immocoDep     = $getAmort('PERTEVAL_IMMO'); // 29x liés aux 21x
        $immocoTotalAmort = $immocoAmort + $immocoDep;
        $immocoNet     = $immocoBrut - $immocoTotalAmort;

        // Immobilisations mises en concession (22)
        $immoconcBrut  = $getBrut('IMMOCONCESS');    // 220-229
        $immoconcDep   = $getAmort('PERTEVAL_IMMO'); // 284, etc.
        $immoconcNet   = $immoconcBrut - $immoconcDep;

        // Immobilisations en cours (23) – pas d’amortissement
        $immocoursBrut = $getBrut('IMMOCOURS');      // 230-239
        $immocoursNet  = $immocoursBrut;

        // Immobilisations financières (26-27) : titres, participations, prêts
        $immoFinBrut   = $getBrut('IMMOFIN');        // 260-279 (tu as une seule cat IMMOFIN dans le seeder)
        $immoFinDep    = $getAmort('PERTEVAL_IMMO'); // 29x sur immo financières
        $immoFinNet    = $immoFinBrut - $immoFinDep;

        // Totaux non courants
        $totalANCBrut  = $goodwillBrut + $immoincBrut + $immocoBrut + $immoconcBrut + $immocoursBrut + $immoFinBrut;
        $totalANCAmort = $goodwillDep  + $immoincTotalAmort + $immocoTotalAmort + $immoconcDep + $immoFinDep;
        $totalANCNet   = $totalANCBrut - $totalANCAmort;

        // ================= ACTIFS COURANTS =================

        // Stocks et en-cours (31-37)
        $stocksBrut  = $getBrut('STOCKS');          // 310-379
        $stocksDep   = $getAmort('PERTEVAL_STOCK'); // 39x
        $stocksNet   = $stocksBrut - $stocksDep;

        // Créances et emplois assimilés
        $clientsBrut     = $getBrut('CLIENTS');        // 410-419
        $clientsDep      = $getAmort('PERTEVAL_TIERS');// 49x sur clients
        $clientsNet      = $clientsBrut - $clientsDep;

        $impotsBrut      = $getBrut('IMPT');          // catégorie IMPT (impôts actifs)
        $impotsNet       = $impotsBrut;

        $autCreancesBrut = $getBrut('AUTCREANCES');   // 420-479 côté actif
        $autCreancesDep  = $getAmort('PERTEVAL_TIERS');// 49x sur autres tiers
        $autCreancesNet  = $autCreancesBrut - $autCreancesDep;

        $regiesBrut      = $getBrut('REGIES');        // 540-549
        $regiesNet       = $regiesBrut;

        // Trésorerie et équivalents
        $placementsBrut  = $getBrut('PLACEMENTS');    // 520-529
        $placementsDep   = $getAmort('PERTEVAL_FIN'); // 59x
        $placementsNet   = $placementsBrut - $placementsDep;

        $tresofondsBrut  = $getBrut('TRESOFONDS');    // 530-539
        $tresofondsNet   = $tresofondsBrut;

        $virintBrut      = $getBrut('VIRINT');        // 580-589
        $virintNet       = $virintBrut;

        // Totaux courants
        $totalACBrut =
              $stocksBrut
            + $clientsBrut
            + $impotsBrut
            + $autCreancesBrut
            + $regiesBrut
            + $placementsBrut
            + $tresofondsBrut
            + $virintBrut;

        $totalACAmort =
              $stocksDep
            + $clientsDep
            + $autCreancesDep
            + $placementsDep;

        $totalACNet = $totalACBrut - $totalACAmort;

        // TOTAL ACTIF
        $totalActifBrut  = $totalANCBrut + $totalACBrut;
        $totalActifAmort = $totalANCAmort + $totalACAmort;
        $totalActifNet   = $totalANCNet + $totalACNet;

        // ================= STRUCTURE PCG 2005 =================

        $structure = [
            // ACTIFS NON COURANTS
            ['label' => 'ACTIFS NON COURANTS', 'note' => '', 'brut' => null, 'amort' => null, 'net' => null, 'isTitle' => true],

            ['label' => 'Écart d\'acquisition (goodwill)', 'note' => '3', 'brut' => $goodwillBrut, 'amort' => $goodwillDep, 'net' => $goodwillNet, 'isTotal' => false],
            ['label' => 'Immobilisations incorporelles', 'note' => '3', 'brut' => $immoincBrut, 'amort' => $immoincTotalAmort, 'net' => $immoincNet, 'isTotal' => false],
            ['label' => 'Immobilisations corporelles', 'note' => '4', 'brut' => $immocoBrut, 'amort' => $immocoTotalAmort, 'net' => $immocoNet, 'isTotal' => false],
            ['label' => 'Immobilisations mises en concession', 'note' => '5', 'brut' => $immoconcBrut, 'amort' => $immoconcDep, 'net' => $immoconcNet, 'isTotal' => false],
            ['label' => 'Immobilisations en cours', 'note' => '6', 'brut' => $immocoursBrut, 'amort' => 0, 'net' => $immocoursNet, 'isTotal' => false],

            ['label' => 'Immobilisations financières', 'note' => '7', 'brut' => null, 'amort' => null, 'net' => null, 'isSubtitle' => true],
            ['label' => '  Immobilisations financières (titres, prêts, autres)', 'note' => '7', 'brut' => $immoFinBrut, 'amort' => $immoFinDep, 'net' => $immoFinNet, 'isTotal' => false],

            ['label' => 'TOTAL ACTIFS NON COURANTS', 'note' => 'I', 'brut' => $totalANCBrut, 'amort' => $totalANCAmort, 'net' => $totalANCNet, 'isTotal' => true],

            // ACTIFS COURANTS
            ['label' => 'ACTIFS COURANTS', 'note' => '', 'brut' => null, 'amort' => null, 'net' => null, 'isTitle' => true],

            ['label' => 'Stocks et en-cours', 'note' => '8', 'brut' => $stocksBrut, 'amort' => $stocksDep, 'net' => $stocksNet, 'isTotal' => false],

            ['label' => 'Créances et emplois assimilés', 'note' => '9', 'brut' => null, 'amort' => null, 'net' => null, 'isSubtitle' => true],
            ['label' => '  Clients et autres débiteurs', 'note' => '9.1', 'brut' => $clientsBrut, 'amort' => $clientsDep, 'net' => $clientsNet, 'isTotal' => false],
            ['label' => '  Impôts', 'note' => '9.2', 'brut' => $impotsBrut, 'amort' => 0, 'net' => $impotsNet, 'isTotal' => false],
            ['label' => '  Autres créances et actifs assimilés', 'note' => '9.3', 'brut' => $autCreancesBrut, 'amort' => $autCreancesDep, 'net' => $autCreancesNet, 'isTotal' => false],
            ['label' => '  Régies d\'avance et avances de caisse', 'note' => '9.4', 'brut' => $regiesBrut, 'amort' => 0, 'net' => $regiesNet, 'isTotal' => false],

            ['label' => 'Trésorerie et équivalents de trésorerie', 'note' => '10', 'brut' => null, 'amort' => null, 'net' => null, 'isSubtitle' => true],
            ['label' => '  Placements et autres équivalents de trésorerie', 'note' => '10.1', 'brut' => $placementsBrut, 'amort' => $placementsDep, 'net' => $placementsNet, 'isTotal' => false],
            ['label' => '  Trésorerie fonds en caisse et dépôts à vue', 'note' => '10.2', 'brut' => $tresofondsBrut, 'amort' => 0, 'net' => $tresofondsNet, 'isTotal' => false],
            ['label' => '  Virements internes', 'note' => '10.3', 'brut' => $virintBrut, 'amort' => 0, 'net' => $virintNet, 'isTotal' => false],

            ['label' => 'TOTAL ACTIFS COURANTS', 'note' => 'II', 'brut' => $totalACBrut, 'amort' => $totalACAmort, 'net' => $totalACNet, 'isTotal' => true],

            ['label' => 'TOTAL ACTIF (I + II)', 'note' => '', 'brut' => $totalActifBrut, 'amort' => $totalActifAmort, 'net' => $totalActifNet, 'isTotal' => true, 'isGrandTotal' => true],
        ];

        return response()->json($structure);
    }

    public static function getBilanActif($dateDebut, $dateFin)
    {

        // Helper pour valeur brute (comptes d'immobilisations/actifs)
        $getBrut = function ($code) use ($dateDebut, $dateFin) {
            $resultat = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return $resultat && $resultat->montant_total ? floatval($resultat->montant_total) : 0;
        };

        // Helper pour amortissements/provisions (comptes 28, 29, 39, 49, 59)
        $getAmort = function ($codeAmort) use ($dateDebut, $dateFin) {
            $resultat = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($codeAmort, $dateDebut, $dateFin);
            return $resultat && $resultat->montant_total ? floatval($resultat->montant_total) : 0;
        };

        // ============ ACTIFS NON COURANTS ============
        $goodwillBrut = $getBrut('GOODWILL');
        $goodwillAmort = $getAmort('AMORT_GOODWILL'); // Si tu as créé cette catégorie
        $goodwillNet = $goodwillBrut - $goodwillAmort;

        $immoincBrut = $getBrut('IMMOINC');
        $immoincAmort = $getAmort('AMORT_IMMOINC');
        $immoincNet = $immoincBrut - $immoincAmort;

        $immocoBrut = $getBrut('IMMOCO');
        $immocoAmort = $getAmort('AMORT_IMMOCO');
        $immocoNet = $immocoBrut - $immocoAmort;

        $immocoursBrut = $getBrut('IMMOCOURS');
        $immocoursAmort = 0; // Les immobilisations en cours ne sont pas amorties
        $immocoursNet = $immocoursBrut;

        $titrseqBrut = $getBrut('TITRSEQ');
        $titrseqAmort = $getAmort('AMORT_TITRSEQ');
        $titrseqNet = $titrseqBrut - $titrseqAmort;

        $autpartBrut = $getBrut('AUTPART');
        $autpartAmort = $getAmort('AMORT_AUTPART');
        $autpartNet = $autpartBrut - $autpartAmort;

        $autimmofinBrut = $getBrut('AUTIMMOFIN');
        $autimmofinAmort = $getAmort('AMORT_AUTIMMOFIN');
        $autimmofinNet = $autimmofinBrut - $autimmofinAmort;

        $pretBrut = $getBrut('PRET');
        $pretAmort = $getAmort('AMORT_PRET');
        $pretNet = $pretBrut - $pretAmort;

        $totalActifsNonCourantsBrut = $goodwillBrut + $immoincBrut + $immocoBrut + $immocoursBrut 
            + $titrseqBrut + $autpartBrut + $autimmofinBrut + $pretBrut;
        $totalActifsNonCourantsAmort = $goodwillAmort + $immoincAmort + $immocoAmort 
            + $titrseqAmort + $autpartAmort + $autimmofinAmort + $pretAmort;
        $totalActifsNonCourantsNet = $totalActifsNonCourantsBrut - $totalActifsNonCourantsAmort;

        // ============ ACTIFS COURANTS ============
        $stocksBrut = $getBrut('STOCKS');
        $stocksAmort = $getAmort('AMORT_STOCKS'); // Provision stocks
        $stocksNet = $stocksBrut - $stocksAmort;

        $clientsBrut = $getBrut('CLIENTS');
        $clientsAmort = $getAmort('AMORT_CLIENTS'); // Provision clients douteux
        $clientsNet = $clientsBrut - $clientsAmort;

        $imptBrut = $getBrut('IMPT');
        $imptAmort = 0;
        $imptNet = $imptBrut;

        $autcreancesBrut = $getBrut('AUTCREANCES');
        $autcreancesAmort = $getAmort('AMORT_AUTCREANCES');
        $autcreancesNet = $autcreancesBrut - $autcreancesAmort;

        $placementsBrut = $getBrut('PLACEMENTS');
        $placementsAmort = $getAmort('AMORT_PLACEMENTS');
        $placementsNet = $placementsBrut - $placementsAmort;

        $tresofondsBrut = $getBrut('TRESOFONDS');
        $tresofondsAmort = 0; // Trésorerie non amortissable
        $tresofondsNet = $tresofondsBrut;

        $totalActifsCourantsBrut = $stocksBrut + $clientsBrut + $imptBrut + $autcreancesBrut 
            + $placementsBrut + $tresofondsBrut;
        $totalActifsCourantsAmort = $stocksAmort + $clientsAmort + $autcreancesAmort + $placementsAmort;
        $totalActifsCourantsNet = $totalActifsCourantsBrut - $totalActifsCourantsAmort;

        $totalActifBrut = $totalActifsNonCourantsBrut + $totalActifsCourantsBrut;
        $totalActifAmort = $totalActifsNonCourantsAmort + $totalActifsCourantsAmort;
        $totalActifNet = $totalActifsNonCourantsNet + $totalActifsCourantsNet;

        return [
            // ACTIFS NON COURANTS
            'structure' =>[['label' => 'ACTIFS NON COURANTS', 'note' => '', 'brut' => null, 'amort' => null, 'net' => null, 'isTitle' => true],
            
            ['label' => 'Écart d\'acquisition (goodwill)', 'note' => '', 'brut' => $goodwillBrut, 'amort' => $goodwillAmort, 'net' => $goodwillNet, 'isTotal' => false],
            ['label' => 'Immobilisations incorporelles', 'note' => '', 'brut' => $immoincBrut, 'amort' => $immoincAmort, 'net' => $immoincNet, 'isTotal' => false],
            ['label' => 'Immobilisations corporelles', 'note' => '', 'brut' => $immocoBrut, 'amort' => $immocoAmort, 'net' => $immocoNet, 'isTotal' => false],
            ['label' => 'Immobilisations en cours', 'note' => '', 'brut' => $immocoursBrut, 'amort' => $immocoursAmort, 'net' => $immocoursNet, 'isTotal' => false],
            
            ['label' => 'Immobilisations financières', 'note' => '', 'brut' => null, 'amort' => null, 'net' => null, 'isSubtitle' => true],
            ['label' => 'Titres mis en équivalence', 'note' => '', 'brut' => $titrseqBrut, 'amort' => $titrseqAmort, 'net' => $titrseqNet, 'isTotal' => false],
            ['label' => 'Autres participations et créances rattachées', 'note' => '', 'brut' => $autpartBrut, 'amort' => $autpartAmort, 'net' => $autpartNet, 'isTotal' => false],
            ['label' => 'Autres titres immobilisés', 'note' => '', 'brut' => $autimmofinBrut, 'amort' => $autimmofinAmort, 'net' => $autimmofinNet, 'isTotal' => false],
            ['label' => 'Prêts et autres immobilisations financières', 'note' => '', 'brut' => $pretBrut, 'amort' => $pretAmort, 'net' => $pretNet, 'isTotal' => false],
            
            ['label' => 'TOTAL ACTIFS NON COURANTS', 'note' => '', 'brut' => $totalActifsNonCourantsBrut, 'amort' => $totalActifsNonCourantsAmort, 'net' => $totalActifsNonCourantsNet, 'isTotal' => true],
            
            // ACTIFS COURANTS
            ['label' => 'ACTIFS COURANTS', 'note' => '', 'brut' => null, 'amort' => null, 'net' => null, 'isTitle' => true],
            
            ['label' => 'Stocks et en-cours', 'note' => '', 'brut' => $stocksBrut, 'amort' => $stocksAmort, 'net' => $stocksNet, 'isTotal' => false],
            
            ['label' => 'Créances et emplois assimilés', 'note' => '', 'brut' => null, 'amort' => null, 'net' => null, 'isSubtitle' => true],
            ['label' => 'Clients et autres débiteurs', 'note' => '', 'brut' => $clientsBrut, 'amort' => $clientsAmort, 'net' => $clientsNet, 'isTotal' => false],
            ['label' => 'Impôts', 'note' => '', 'brut' => $imptBrut, 'amort' => $imptAmort, 'net' => $imptNet, 'isTotal' => false],
            ['label' => 'Autres créances et actifs assimilés', 'note' => '', 'brut' => $autcreancesBrut, 'amort' => $autcreancesAmort, 'net' => $autcreancesNet, 'isTotal' => false],
            
            ['label' => 'Trésorerie et équivalents de trésorerie', 'note' => '', 'brut' => null, 'amort' => null, 'net' => null, 'isSubtitle' => true],
            ['label' => 'Placements et autres équivalents de trésorerie', 'note' => '', 'brut' => $placementsBrut, 'amort' => $placementsAmort, 'net' => $placementsNet, 'isTotal' => false],
            ['label' => 'Trésorerie fonds en caisse et dépôts à vue', 'note' => '', 'brut' => $tresofondsBrut, 'amort' => $tresofondsAmort, 'net' => $tresofondsNet, 'isTotal' => false],
            
            ['label' => 'TOTAL ACTIFS COURANTS', 'note' => '', 'brut' => $totalActifsCourantsBrut, 'amort' => $totalActifsCourantsAmort, 'net' => $totalActifsCourantsNet, 'isTotal' => true],
            
            ['label' => 'TOTAL ACTIF', 'note' => '', 'brut' => $totalActifBrut, 'amort' => $totalActifAmort, 'net' => $totalActifNet, 'isTotal' => true]]
        ];

        return $structure;
    }
}
