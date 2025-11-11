<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class BilanPassifController extends Controller
{
    /**
     * Bilan PASSIF conforme PCG Madagascar 2005
     * Utilise uniquement les codes du seeder
     */
    public function index(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);
        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

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

        $structure = [
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
