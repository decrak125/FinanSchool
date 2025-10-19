<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class BilanPassifController extends Controller
{
    /**
     * Bilan PASSIF conforme PCG Madagascar 2005
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

        // ============ CAPITAUX PROPRES ============
        $capital = $get('CAPITAL');
        $prime = $get('PRIME');
        $eval = $get('EVAL');
        $equiv = $get('EQUIV');
        $result = $get('RESULT');
        $autcpro = $get('AUTCPRO');
        
        $partGroupe = $capital + $prime + $eval + $equiv + $result + $autcpro;
        $partMinoritaires = $get('MINORITAIRES'); // Si applicable
        
        $totalCapitauxPropres = $partGroupe + $partMinoritaires;

        // ============ PASSIFS NON COURANTS ============
        $subvinv = $get('SUBVINV');
        $imptdiff = $get('IMPTPASS');
        $emprunt = $get('EMPRUNT');
        $provncour = $get('PROVNCOUR');
        
        $totalPassifsNonCourants = $subvinv + $imptdiff + $emprunt + $provncour;

        // ============ PASSIFS COURANTS ============
        $dettect = $get('DETTECT');
        $fourn = $get('FOURN');
        $provc = $get('PROVC');
        $autdette = $get('AUTDETTE');
        $decouv = $get('DECOUV');
        
        $totalPassifsCourants = $dettect + $fourn + $provc + $autdette + $decouv;

        $totalPassif = $totalCapitauxPropres + $totalPassifsNonCourants + $totalPassifsCourants;

        $structure = [
            // CAPITAUX PROPRES
            ['label' => 'CAPITAUX PROPRES', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Capital émis', 'note' => '', 'montant' => $capital, 'isTotal' => false],
            ['label' => 'Primes et réserves consolidées', 'note' => '', 'montant' => $prime, 'isTotal' => false],
            ['label' => 'Écarts d\'évaluation', 'note' => '', 'montant' => $eval, 'isTotal' => false],
            ['label' => 'Écart d\'équivalence', 'note' => '', 'montant' => $equiv, 'isTotal' => false],
            ['label' => 'Résultat net - part du groupe', 'note' => '', 'montant' => $result, 'isTotal' => false],
            ['label' => 'Autres capitaux propres - report à nouveau', 'note' => '', 'montant' => $autcpro, 'isTotal' => false],
            ['label' => 'Part de la société consolidante', 'note' => '', 'montant' => $partGroupe, 'isSubtotal' => true],
            ['label' => 'Part des minoritaires', 'note' => '', 'montant' => $partMinoritaires, 'isTotal' => false],
            ['label' => 'TOTAL CAPITAUX PROPRES', 'note' => '', 'montant' => $totalCapitauxPropres, 'isTotal' => true],
            
            // PASSIFS NON COURANTS
            ['label' => 'PASSIFS NON COURANTS', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Produits différés (subventions d\'investissement)', 'note' => '', 'montant' => $subvinv, 'isTotal' => false],
            ['label' => 'Impôts différés', 'note' => '', 'montant' => $imptdiff, 'isTotal' => false],
            ['label' => 'Emprunts et dettes financières', 'note' => '', 'montant' => $emprunt, 'isTotal' => false],
            ['label' => 'Provisions et produits constatés d\'avance', 'note' => '', 'montant' => $provncour, 'isTotal' => false],
            ['label' => 'TOTAL PASSIFS NON COURANTS', 'note' => '', 'montant' => $totalPassifsNonCourants, 'isTotal' => true],
            
            // PASSIFS COURANTS
            ['label' => 'PASSIFS COURANTS', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Dettes court terme', 'note' => '', 'montant' => $dettect, 'isTotal' => false],
            ['label' => 'Fournisseurs et comptes rattachés', 'note' => '', 'montant' => $fourn, 'isTotal' => false],
            ['label' => 'Provisions et produits constatés d\'avance', 'note' => '', 'montant' => $provc, 'isTotal' => false],
            ['label' => 'Autres dettes', 'note' => '', 'montant' => $autdette, 'isTotal' => false],
            ['label' => 'Comptes de trésorerie découverts bancaires', 'note' => '', 'montant' => $decouv, 'isTotal' => false],
            ['label' => 'TOTAL PASSIFS COURANTS', 'note' => '', 'montant' => $totalPassifsCourants, 'isTotal' => true],
            
            ['label' => 'TOTAL PASSIF ET CAPITAUX PROPRES', 'note' => '', 'montant' => $totalPassif, 'isTotal' => true]
        ];

        return response()->json($structure);
    }
}
