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

        $get = function ($code) use ($dateDebut, $dateFin) {
            $r = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return $r && $r->montant_total ? floatval($r->montant_total) : 0;
        };

        // ================== RÉSULTAT NET (COMPTE DE RÉSULTAT PCG) ==================
        // PRODUITS
        $ca          = $get('CA');          // 700-709
        $prodVendu   = $get('PRODVENDU');   // 710-719
        $prodImmo    = $get('PRODIMMO');    // 720-729
        $prodLTTerm  = $get('PRODLTTERM');  // 730-739
        $subventExpl = $get('SUBVENT');     // 740-749 (subv d’exploitation)
        $autProdOp   = $get('AUTPRODOP');   // 750-759
        $prodFin     = $get('PRODFIN');     // 760-769
        $prodExcept  = $get('PRODEXCEPT');  // 770-779
        $repriseProv = $get('REPRISEPROV'); // 780-789
        $transfCharg = $get('TRANSFCHARG'); // 790-799

        // CHARGES
        $achatConsom = $get('ACHATCONSOM'); // 600-609
        $servExt     = $get('SERVEXT');     // 610-629
        $impTax      = $get('IMPTAX');      // 630-639
        $chPers      = $get('CHPERS');      // 640-649
        $autChOp     = $get('AUTCHOP');     // 650-659
        $chargeFin   = $get('CHARGEFIN');   // 660-669
        $charExcept  = $get('CHAREXCEPT');  // 670-679
        $amortProv   = $get('AMORTPROV');   // 680-689
        $impot       = $get('IMPOT');       // 690-699 (impôt sur le résultat)

        $totalProduits =
              $ca
            + $prodVendu
            + $prodImmo
            + $prodLTTerm
            + $subventExpl
            + $autProdOp
            + $prodFin
            + $prodExcept
            + $repriseProv
            + $transfCharg;

        $totalCharges =
              $achatConsom
            + $servExt
            + $impTax
            + $chPers
            + $autChOp
            + $chargeFin
            + $charExcept
            + $amortProv
            + $impot;

        $resultatNet = $totalProduits - $totalCharges;

        // ================== CAPITAUX PROPRES (PCG 2005) ==================
        // 10 : Capital et réserves
        $capital    = $get('CAPITAL');      // 100-103
        $reserves   = $get('RESERVES');     // 104-109
        $reportNouv = $get('REPORTNOUV');   // 110-119

        // 13 : Subventions d’investissement
        $subvInvest = $get('SUBVINVEST');   // 130-139

        // 14 : Provisions réglementées
        $provReg    = $get('PROVREG');      // 140-149

        // Résultat net de l’exercice (12)
        // déjà calculé: $resultatNet

        $totalCapitauxPropres =
              $capital
            + $reserves
            + $reportNouv
            + $subvInvest
            + $provReg
            + $resultatNet;

        // ================== PASSIFS NON COURANTS ==================
        // 15 : Provisions pour risques et charges (LT)
        $provNCour = $get('PROVNCOUR'); // 150-159

        // 16 : Emprunts et dettes financières (LT)
        $emprunt   = $get('EMPRUNT');   // 160-169

        $totalPassifsNonCourants = $provNCour + $emprunt;

        // ================== PASSIFS COURANTS ==================
        // 17 : Dettes CT
        $detteCT   = $get('DETTECT');    // 170-179

        // 18 : Comptes de liaison
        $cptLiais  = $get('CPTLIAISON'); // 180-189

        // 40 : Fournisseurs et comptes rattachés
        $fourn     = $get('FOURN');      // 400-409

        // 48 : Provisions / produits constatés d’avance (courants)
        $provc     = $get('PROVC');      // 480-489

        // 42-47 : Autres dettes (salariés, Etat, organismes sociaux, divers)
        $autDette  = $get('AUTDETTE');   // 420-479 (hors fournisseurs déjà isolés)

        $totalPassifsCourants =
              $detteCT
            + $cptLiais
            + $fourn
            + $provc
            + $autDette;

        $totalPassif = $totalCapitauxPropres + $totalPassifsNonCourants + $totalPassifsCourants;

        // ================== STRUCTURE EXACTE BILAN PASSIF ==================
        $structure = [
            // I. CAPITAUX PROPRES
            ['label' => 'I. CAPITAUX PROPRES', 'note' => '', 'montant' => null, 'isTitle' => true],

            // 10 Capital et réserves
            ['label' => 'Capital émis', 'note' => '10', 'montant' => $capital, 'isTotal' => false],
            ['label' => 'Primes et réserves', 'note' => '10', 'montant' => $reserves, 'isTotal' => false],
            ['label' => 'Report à nouveau', 'note' => '11', 'montant' => $reportNouv, 'isTotal' => false],

            // 13 Subventions d’investissement
            ['label' => 'Subventions d’investissement', 'note' => '13', 'montant' => $subvInvest, 'isTotal' => false],

            // 14 Provisions réglementées
            ['label' => 'Provisions réglementées', 'note' => '14', 'montant' => $provReg, 'isTotal' => false],

            // Résultat de l’exercice
            ['label' => 'Résultat net de l’exercice', 'note' => '12', 'montant' => $resultatNet, 'isTotal' => false],

            ['label' => 'TOTAL CAPITAUX PROPRES', 'note' => 'I', 'montant' => $totalCapitauxPropres, 'isTotal' => true],

            // II. PASSIFS NON COURANTS
            ['label' => 'II. PASSIFS NON COURANTS', 'note' => '', 'montant' => null, 'isTitle' => true],

            ['label' => 'Provisions pour risques et charges (non courantes)', 'note' => '15', 'montant' => $provNCour, 'isTotal' => false],
            ['label' => 'Emprunts et dettes financières à long terme', 'note' => '16', 'montant' => $emprunt, 'isTotal' => false],

            ['label' => 'TOTAL PASSIFS NON COURANTS', 'note' => 'II', 'montant' => $totalPassifsNonCourants, 'isTotal' => true],

            // III. PASSIFS COURANTS
            ['label' => 'III. PASSIFS COURANTS', 'note' => '', 'montant' => null, 'isTitle' => true],

            ['label' => 'Dettes à court terme', 'note' => '17', 'montant' => $detteCT, 'isTotal' => false],
            ['label' => 'Comptes de liaison et opérations particulières', 'note' => '18', 'montant' => $cptLiais, 'isTotal' => false],
            ['label' => 'Fournisseurs et comptes rattachés', 'note' => '40', 'montant' => $fourn, 'isTotal' => false],
            ['label' => 'Provisions et produits constatés d’avance (courants)', 'note' => '48', 'montant' => $provc, 'isTotal' => false],
            ['label' => 'Autres dettes (Etat, personnel, organismes sociaux, divers)', 'note' => '42-47', 'montant' => $autDette, 'isTotal' => false],

            ['label' => 'TOTAL PASSIFS COURANTS', 'note' => 'III', 'montant' => $totalPassifsCourants, 'isTotal' => true],

            ['label' => 'TOTAL PASSIF (I + II + III)', 'note' => '', 'montant' => $totalPassif, 'isTotal' => true],
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
