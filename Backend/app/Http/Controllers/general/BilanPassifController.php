<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class BilanPassifController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);

        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

        $get = function ($code, $sens = null) use ($dateDebut, $dateFin) {
    $r = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin, $sens);
    return $r && $r->montant_total ? floatval($r->montant_total) : 0;
};


        // ================== RÉSULTAT NET (COMPTE DE RÉSULTAT PCG) ==================
        // PRODUITS
        $ca          = $get('CA');
        $prodVendu   = $get('PRODVENDU');
        $prodImmo    = $get('PRODIMMO');
        $prodLTTerm  = $get('PRODLTTERM');
        $subventExpl = $get('SUBVENT');
        $autProdOp   = $get('AUTPRODOP');
        $prodFin     = $get('PRODFIN');
        $prodExcept  = $get('PRODEXCEPT');
        $repriseProv = $get('REPRISEPROV');
        $transfCharg = $get('TRANSFCHARG');

        // CHARGES
        $achatConsom = $get('ACHATCONSOM');
        $servExt     = $get('SERVEXT');
        $impTax      = $get('IMPTAX');
        $chPers      = $get('CHPERS');
        $autChOp     = $get('AUTCHOP');
        $chargeFin   = $get('CHARGEFIN');
        $charExcept  = $get('CHAREXCEPT');
        $amortProv   = $get('AMORTPROV');
        $impot       = $get('IMPOT');

        $totalProduits = $ca + $prodVendu + $prodImmo + $prodLTTerm + $subventExpl 
                       + $autProdOp + $prodFin + $prodExcept + $repriseProv + $transfCharg;

        $totalCharges = $achatConsom + $servExt + $impTax + $chPers + $autChOp 
                      + $chargeFin + $charExcept + $amortProv + $impot;

        $resultatNet = $totalProduits - $totalCharges;

        // ================== CAPITAUX PROPRES (PCG 2005) ==================
        // Classe 10 : Capital, réserves et assimilés
        $capital     = $get('CAPITAL');      // 101-103
        $primes      = $get('PRIMES');       // 104-105
        $ecartReeval = $get('ECARTREEVAL');  // 106
        $ecartEquiv  = $get('ECARTEQUIV');   // 107
        $reserves  = $get('RESERVES');   // 108
        $actionnaires = $get('ACTIONCAP');   // 109 (Capital souscrit non appelé / non versé)

        // Classe 11 : Report à nouveau
        $reportNou  = $get('REPORTNOUV');
        $reportNouv = -$reportNou;
        
        // 110-119

        // Classe 12 : Résultat de l'exercice (N)
        // $resultatNet déjà calculé

        // Classe 13 : Subventions d'investissement
        $subvInvest  = $get('SUBVINVEST');   // 131-138

        // Classe 14 : Provisions réglementées
        $provReg     = $get('PROVREG');      // 141-148

        $totalCapitauxPropres = $capital + $primes + $ecartReeval + $ecartEquiv 
                              + $reserves - $actionnaires + $reportNouv 
                              + $resultatNet + $subvInvest + $provReg;

        // ================== PASSIFS NON COURANTS ==================
        // Classe 15 : Provisions pour risques et charges (> 1 an)
        $provRisques      = $get('PROVRISQUES');    // 151
        $provCharges      = $get('PROVCHARGES');    // 152-158
        $totalProvNCour   = $provRisques + $provCharges;

        // Classe 16 : Emprunts et dettes financières (> 1 an)
        $empruntObl       = $get('EMPRUNT');        // 161-165
        $dettesLocFin     = $get('DETTELOC');       // 166-167
        $autDettesFin     = $get('AUTDETTEFIN');    // 168
        $totalEmprNCour   = $empruntObl + $dettesLocFin + $autDettesFin;

        $totalPassifsNonCourants = $totalProvNCour + $totalEmprNCour;

        // ================== PASSIFS COURANTS ==================
        // Classe 17 : Dettes rattachées à des participations (CT)
        $dettesPartic    = $get('DETTEPARTIC');    // 171-178

        // Classe 18 : Comptes de liaison
        $cptLiais        = $get('CPTLIAISON');     // 181-188

        // Classe 40 : Fournisseurs et comptes rattachés
        $fourn           = $get('FOURN');          // 401-409
        $avancesRecues   = $get('AVANCREC');       // 419

        // Classe 42 : Personnel et comptes rattachés
        $dettesPersonnel = $get('DETTEPERS');      // 421-428

        // Classe 43 : Sécurité sociale et autres organismes sociaux
        $dettesSecu      = $get('AUTCREANCES');      // 431-438

        // Classe 44 : État et collectivités publiques
        $dettesEta      = $get('ETAT','credit');  
        $impot = $get ("IMPOT");
        $dettesEtat = $dettesEta -$impot;   // 441-449

        // Classe 45 : Associés et groupe
        $dettesAssoc     = $get('DETTE_ASSOC');     // 451-458

        // Classe 46 : Débiteurs et créditeurs divers
        $autCredits       = $get('IMPOT');
        $perscred = $get('PERS_CRED');      // 461-469
        $autCredit = $autCredits + $perscred;

        // Classe 47 : Comptes transitoires ou d'attente
        $cptTransit      = $get('CPTTRANSIT');     // 471-479

        // Classe 48 : Provisions et produits constatés d'avance (CT)
        $provc           = $get('');          // 481-488
        $prodConstAvance = $get('PRODCONSTAV');    // 489

        // Partie CT des dettes financières (classe 16 < 1 an)
        $dettesFinCT     = $get('DETTECT');        // 16x (portion < 1 an)

        $totalPassifsCourants = $dettesPartic + $cptLiais + $fourn + $avancesRecues 
                              + $dettesPersonnel + $dettesSecu + $dettesEtat 
                              + $dettesAssoc + $autCredit + $cptTransit 
                              + $provc + $prodConstAvance + $dettesFinCT;

        $totalPassif = $totalCapitauxPropres + $totalPassifsNonCourants + $totalPassifsCourants;

        // ================== STRUCTURE EXACTE BILAN PASSIF PCG 2005 ==================
        $structure = [
            // ========== CAPITAUX PROPRES ==========
            ['label' => 'CAPITAUX PROPRES', 'note' => '', 'montant' => null, 'isTitle' => true],
            
            ['label' => 'Capital', 'note' => '10.1', 'montant' => $capital, 'isSubtitle' => false],
            ['label' => 'Primes liées au capital', 'note' => '10.4', 'montant' => $primes, 'isSubtitle' => false],
            ['label' => 'Écarts de réévaluation', 'note' => '10.6', 'montant' => $ecartReeval, 'isSubtitle' => false],
            ['label' => 'Écarts d\'équivalence', 'note' => '10.7', 'montant' => $ecartEquiv, 'isSubtitle' => false],
            ['label' => 'Réserves', 'note' => '10.8', 'montant' => $reserves, 'isSubtitle' => false],
            ['label' => 'Capital souscrit non appelé (–)', 'note' => '10.9', 'montant' => -$actionnaires, 'isSubtitle' => false],
            ['label' => 'Report à nouveau', 'note' => '11', 'montant' => $reportNouv, 'isSubtitle' => false],
            ['label' => 'Résultat net de l\'exercice (bénéfice + ou perte –)', 'note' => '12', 'montant' => $resultatNet, 'isSubtitle' => false],
            ['label' => 'Subventions d\'investissement', 'note' => '13', 'montant' => $subvInvest, 'isSubtitle' => false],
            ['label' => 'Provisions réglementées', 'note' => '14', 'montant' => $provReg, 'isSubtitle' => false],
            
            ['label' => 'TOTAL CAPITAUX PROPRES', 'note' => 'I', 'montant' => $totalCapitauxPropres, 'isTotal' => true],

            // ========== PASSIFS NON COURANTS ==========
            ['label' => 'PASSIFS NON COURANTS', 'note' => '', 'montant' => null, 'isTitle' => true],
            
            ['label' => 'Provisions pour risques et charges (non courantes)', 'note' => '', 'montant' => null, 'isSubtitle' => true],
            ['label' => '  Provisions pour risques', 'note' => '15.1', 'montant' => $provRisques, 'isSubtitle' => false],
            ['label' => '  Provisions pour charges', 'note' => '15.2', 'montant' => $provCharges, 'isSubtitle' => false],
            ['label' => 'Total provisions pour risques et charges', 'note' => '', 'montant' => $totalProvNCour, 'isSubtotal' => true],
            
            ['label' => 'Emprunts et dettes financières (non courants)', 'note' => '', 'montant' => null, 'isSubtitle' => true],
            ['label' => '  Emprunts obligataires', 'note' => '16.1', 'montant' => $empruntObl, 'isSubtitle' => false],
            ['label' => '  Dettes de location-financement', 'note' => '16.6', 'montant' => $dettesLocFin, 'isSubtitle' => false],
            ['label' => '  Autres dettes financières', 'note' => '16.8', 'montant' => $autDettesFin, 'isSubtitle' => false],
            ['label' => 'Total emprunts et dettes financières', 'note' => '', 'montant' => $totalEmprNCour, 'isSubtotal' => true],
            
            ['label' => 'TOTAL PASSIFS NON COURANTS', 'note' => 'II', 'montant' => $totalPassifsNonCourants, 'isTotal' => true],

            // ========== PASSIFS COURANTS ==========
            ['label' => 'PASSIFS COURANTS', 'note' => '', 'montant' => null, 'isTitle' => true],
            
            ['label' => 'Fournisseurs et comptes rattachés', 'note' => '40', 'montant' => $fourn, 'isSubtitle' => false],
            ['label' => 'Dettes sociales', 'note' => '43', 'montant' => $dettesSecu, 'isSubtitle' => false],
            ['label' => 'Dettes fiscales', 'note' => '44', 'montant' => $dettesEtat, 'isSubtitle' => false],
            ['label' => 'Dettes envers les associés', 'note' => '45', 'montant' => $dettesAssoc, 'isSubtitle' => false],
            ['label' => 'Autres créditeurs', 'note' => '46', 'montant' => $autCredit, 'isSubtitle' => false],
            ['label' => 'Comptes transitoires ou d\'attente', 'note' => '47', 'montant' => $cptTransit, 'isSubtitle' => false],
            ['label' => 'Provisions pour risques et charges (courantes)', 'note' => '48.1', 'montant' => $provc, 'isSubtitle' => false],
            ['label' => 'Produits constatés d\'avance', 'note' => '48.9', 'montant' => $prodConstAvance, 'isSubtitle' => false],
            
            ['label' => 'TOTAL PASSIFS COURANTS', 'note' => 'III', 'montant' => $totalPassifsCourants, 'isTotal' => true],

            // ========== TOTAL GÉNÉRAL ==========
            ['label' => 'TOTAL GÉNÉRAL DU PASSIF (I + II + III)', 'note' => '', 'montant' => $totalPassif, 'isTotal' => true],
        ];

        return response()->json($structure);
    }



        public static function getBilanPassif($dateDebut, $dateFin)
    {
        $get = function ($code) use ($dateDebut, $dateFin) {
            $resultat = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return $resultat && $resultat->montant_total ? floatval($resultat->montant_total) : 0;
        };

        // ============ CALCUL DU RÉSULTAT NET (même formule que compte de résultat) ============
        // Produits
        $ca = $get('CA');
        $prodStock = $get('PRODSTOCK');
        $prodImmo = $get('PRODIMMO');
        $subvent = $get('SUBVENT');
        $autProdOp = $get('AUTPRODOP');
        $prodFin = $get('PRODFIN');
        $prodExcept = $get('PRODEXCEPT');
        $repriseProv = $get('REPRISEPROV');
        
        // Charges
        $achatConsom = $get('ACHATCONSOM');
        $servExt = $get('SERVEXT');
        $impTax = $get('IMPTAX');
        $chPers = $get('CHPERS');
        $autChOp = $get('AUTCHOP');
        $chargeFin = $get('CHARGEFIN');
        $charExcept = $get('CHAREXCEPT');
        $amortProv = $get('AMORTPROV');
        $impot = $get('IMPOT');

        $totalProduits = $ca + $prodStock + $prodImmo + $subvent + $autProdOp + $prodFin + $prodExcept + $repriseProv;
        $totalCharges = $achatConsom + $servExt + $impTax + $chPers + $autChOp + $chargeFin + $charExcept + $amortProv + $impot;
        $resultatNet = $totalProduits - $totalCharges;

        // ============ CAPITAUX PROPRES (codes du seeder uniquement) ============
        $capital = $get('CAPITAL');
        $prime = $get('PRIME');
        $eval = $get('EVAL');
        $equiv = $get('EQUIV');
        $autcpro = $get('AUTCPRO');
        
        $partGroupe = $capital + $prime + $eval + $equiv + $resultatNet + $autcpro;
        $partMinoritaires = 0; // Non présent dans le seeder
        
        $totalCapitauxPropres = $partGroupe + $partMinoritaires;

        // ============ PASSIFS NON COURANTS (codes du seeder uniquement) ============
        $emprunt = $get('EMPRUNT');
        $provncour = $get('PROVNCOUR');
        
        $totalPassifsNonCourants = $emprunt + $provncour;

        // ============ PASSIFS COURANTS (codes du seeder uniquement) ============
        $dettect = $get('DETTECT');
        $fourn = $get('FOURN');
        $provc = $get('PROVC');
        $autdette = $get('AUTDETTE');
        
        $totalPassifsCourants = $dettect + $fourn + $provc + $autdette;

        $totalPassif = $totalCapitauxPropres + $totalPassifsNonCourants + $totalPassifsCourants;

        return ['structure' => [
            // CAPITAUX PROPRES
            ['label' => 'CAPITAUX PROPRES', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Capital émis', 'note' => '', 'montant' => $capital, 'isTotal' => false],
            ['label' => 'Primes et réserves', 'note' => '', 'montant' => $prime, 'isTotal' => false],
            ['label' => 'Écarts d\'évaluation', 'note' => '', 'montant' => $eval, 'isTotal' => false],
            ['label' => 'Écart d\'équivalence', 'note' => '', 'montant' => $equiv, 'isTotal' => false],
            ['label' => 'Résultat net de l\'exercice', 'note' => '', 'montant' => $resultatNet, 'isTotal' => false],
            ['label' => 'Autres capitaux propres - report à nouveau', 'note' => '', 'montant' => $autcpro, 'isTotal' => false],
            ['label' => 'TOTAL CAPITAUX PROPRES', 'note' => '', 'montant' => $totalCapitauxPropres, 'isTotal' => true],
            
            // PASSIFS NON COURANTS
            ['label' => 'PASSIFS NON COURANTS', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Emprunts et dettes financières', 'note' => '', 'montant' => $emprunt, 'isTotal' => false],
            ['label' => 'Provisions non courantes', 'note' => '', 'montant' => $provncour, 'isTotal' => false],
            ['label' => 'TOTAL PASSIFS NON COURANTS', 'note' => '', 'montant' => $totalPassifsNonCourants, 'isTotal' => true],
            
            // PASSIFS COURANTS
            ['label' => 'PASSIFS COURANTS', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Dettes court terme', 'note' => '', 'montant' => $dettect, 'isTotal' => false],
            ['label' => 'Fournisseurs et comptes rattachés', 'note' => '', 'montant' => $fourn, 'isTotal' => false],
            ['label' => 'Provisions courantes', 'note' => '', 'montant' => $provc, 'isTotal' => false],
            ['label' => 'Autres dettes', 'note' => '', 'montant' => $autdette, 'isTotal' => false],
            ['label' => 'TOTAL PASSIFS COURANTS', 'note' => '', 'montant' => $totalPassifsCourants, 'isTotal' => true],
            
            ['label' => 'TOTAL PASSIF', 'note' => '', 'montant' => $totalPassif, 'isTotal' => true]
        ]];

    }

}
