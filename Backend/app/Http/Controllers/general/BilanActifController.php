<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class BilanActifController extends Controller
{
    /**
     * Bilan ACTIF conforme PCG Madagascar 2005
     * Structure: Brut | Amortissements/Provisions | Net (N et N-1)
     */
    public function index(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);
        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

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

        $structure = [
            // ACTIFS NON COURANTS
            ['label' => 'ACTIFS NON COURANTS', 'note' => '', 'brut' => null, 'amort' => null, 'net' => null, 'isTitle' => true],
            
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
            
            ['label' => 'TOTAL ACTIF', 'note' => '', 'brut' => $totalActifBrut, 'amort' => $totalActifAmort, 'net' => $totalActifNet, 'isTotal' => true]
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
