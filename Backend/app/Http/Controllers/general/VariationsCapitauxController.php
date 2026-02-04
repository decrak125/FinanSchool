<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\exercice\ExerciceComptable;
use App\Http\Controllers\calcul\UtilesController;

class VariationsCapitauxController extends Controller
{
    public function index(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);

        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

        // 1. Récupération des exercices
        $exercices = ExerciceComptable::where('Date_fin', '<=', $dateFin)
            ->orderBy('Date_fin', 'desc')
            ->limit(3)
            ->get();

        if ($exercices->count() < 3) {
            return response()->json(['error' => 'Pas assez d\'exercices consécutifs'], 422);
        }

        $exN  = $exercices[0];
        $exN1 = $exercices[1];
        $exN2 = $exercices[2];

        // Helper simple et sûr
        $getSolde = function ($code, $debut, $fin) {
            $r = UtilesController::calculerSommeCategorie($code, $debut, $fin);
            return ($r && property_exists($r, 'montant_total')) ? floatval($r->montant_total) : 0.0;
        };

        // --- N-2 ---
        $capitalN2  = $getSolde('CAPITAL', $exN2->Date_debut, $exN2->Date_fin);
        
        // C'est ici qu'on remplit les Réserves avec TOUS vos codes (comme dans BilanPassif)
        $reservesN2 = $getSolde('RESERVES', $exN2->Date_debut, $exN2->Date_fin)
                    + $getSolde('PRIME',    $exN2->Date_debut, $exN2->Date_fin)
                    + $getSolde('EVAL',     $exN2->Date_debut, $exN2->Date_fin)
                    + $getSolde('EQUIV',    $exN2->Date_debut, $exN2->Date_fin);
        
        // Idem pour le Report à Nouveau (inclut Autres Cap Propres)
        $reportN2   = $getSolde('REPORTNOUV', $exN2->Date_debut, $exN2->Date_fin)
                    + $getSolde('AUTCPRO',    $exN2->Date_debut, $exN2->Date_fin);
                    
        $subvInvN2  = $getSolde('SUBVINVEST', $exN2->Date_debut, $exN2->Date_fin);
        $provRegN2  = $getSolde('PROVREG',    $exN2->Date_debut, $exN2->Date_fin);
        $resultN2   = $this->getResultatExercice($exN2);

        // --- N-1 ---
        $capitalN1  = $getSolde('CAPITAL', $exN1->Date_debut, $exN1->Date_fin);
        
        $reservesN1 = $getSolde('RESERVES', $exN1->Date_debut, $exN1->Date_fin)
                    + $getSolde('PRIME',    $exN1->Date_debut, $exN1->Date_fin)
                    + $getSolde('EVAL',     $exN1->Date_debut, $exN1->Date_fin)
                    + $getSolde('EQUIV',    $exN1->Date_debut, $exN1->Date_fin);

        $reportN1   = $getSolde('REPORTNOUV', $exN1->Date_debut, $exN1->Date_fin)
                    + $getSolde('AUTCPRO',    $exN1->Date_debut, $exN1->Date_fin);
        
        $subvInvN1  = $getSolde('SUBVINVEST', $exN1->Date_debut, $exN1->Date_fin);
        $provRegN1  = $getSolde('PROVREG',    $exN1->Date_debut, $exN1->Date_fin);
        $resultN1   = $this->getResultatExercice($exN1);

        // --- N ---
        $capitalN   = $getSolde('CAPITAL', $exN->Date_debut, $exN->Date_fin);
        
        $reservesN  = $getSolde('RESERVES', $exN->Date_debut, $exN->Date_fin)
                    + $getSolde('PRIME',    $exN->Date_debut, $exN->Date_fin)
                    + $getSolde('EVAL',     $exN->Date_debut, $exN->Date_fin)
                    + $getSolde('EQUIV',    $exN->Date_debut, $exN->Date_fin);

        $reportN    = $getSolde('REPORTNOUV', $exN->Date_debut, $exN->Date_fin)
                    + $getSolde('AUTCPRO',    $exN->Date_debut, $exN->Date_fin);
        
        $subvInvN   = $getSolde('SUBVINVEST', $exN->Date_debut, $exN->Date_fin);
        $provRegN   = $getSolde('PROVREG',    $exN->Date_debut, $exN->Date_fin);
        $resultN    = $this->getResultatExercice($exN);

        // --- VARIATIONS ---
        $variationN1 = [
            'capital'  => $capitalN1  - $capitalN2,
            'reserves' => $reservesN1 - $reservesN2,
            'report'   => $reportN1   - $reportN2,
            'subvInv'  => $subvInvN1  - $subvInvN2,
            'provReg'  => $provRegN1  - $provRegN2,
            'result'   => $resultN2, 
        ];

        $variationN = [
            'capital'  => $capitalN   - $capitalN1,
            'reserves' => $reservesN  - $reservesN1,
            'report'   => $reportN    - $reportN1,
            'subvInv'  => $subvInvN   - $subvInvN1,
            'provReg'  => $provRegN   - $provRegN1,
            'result'   => $resultN1, 
        ];

        // --- STRUCTURE DU TABLEAU ---
        // Je reviens strictement à la structure qui marchait (Tableau direct)
        $structure = [
            [
                'label'    => "Solde au début N-1",
                'capital'  => $capitalN2,
                'reserves' => $reservesN2,
                'report'   => $reportN2,
                'subvInv'  => $subvInvN2,
                'provReg'  => $provRegN2,
                'result'   => $resultN2,
                'total'    => $capitalN2 + $reservesN2 + $reportN2 + $subvInvN2 + $provRegN2 + $resultN2,
                'isTotal'  => true,
            ],
            [
                'label'    => "Mouvements de l'exercice N-1",
                'capital'  => $variationN1['capital'],
                'reserves' => $variationN1['reserves'],
                'report'   => $variationN1['report'],
                'subvInv'  => $variationN1['subvInv'],
                'provReg'  => $variationN1['provReg'],
                'result'   => -$variationN1['result'],
                'total'    => ($variationN1['capital'] + $variationN1['reserves'] + $variationN1['report'] + $variationN1['subvInv'] + $variationN1['provReg']) - $variationN1['result'],
                'isDetail' => true,
            ],
            [
                'label'    => "Solde à la fin N-1",
                'capital'  => $capitalN1,
                'reserves' => $reservesN1,
                'report'   => $reportN1,
                'subvInv'  => $subvInvN1,
                'provReg'  => $provRegN1,
                'result'   => $resultN1,
                'total'    => $capitalN1 + $reservesN1 + $reportN1 + $subvInvN1 + $provRegN1 + $resultN1,
                'isTotal'  => true,
            ],
            [
                'label'    => "Mouvements de l'exercice N",
                'capital'  => $variationN['capital'],
                'reserves' => $variationN['reserves'],
                'report'   => $variationN['report'],
                'subvInv'  => $variationN['subvInv'],
                'provReg'  => $variationN['provReg'],
                'result'   => $resultN,
                'total'    => ($variationN['capital'] + $variationN['reserves'] + $variationN['report'] + $variationN['subvInv'] + $variationN['provReg']) - $variationN['result'],
                'isDetail' => true,
            ],
            [
                'label'    => "Solde à la fin N",
                'capital'  => $capitalN,
                'reserves' => $reservesN,
                'report'   => -$reportN,
                'subvInv'  => $subvInvN,
                'provReg'  => $provRegN,
                'result'   => $resultN,
                'total'    => $capitalN + $reservesN + (-$reportN) + $subvInvN + $provRegN + $resultN,
                'isTotal'  => true,
            ],
        ];

        return response()->json($structure);
    }

    protected function getResultatExercice(ExerciceComptable $ex)
    {
        $dateDebut = $ex->Date_debut;
        $dateFin   = $ex->Date_fin;

        $get = function ($code) use ($dateDebut, $dateFin) {
            $r = UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return ($r && property_exists($r, 'montant_total')) ? floatval($r->montant_total) : 0.0;
        };

        $produits = $get('CA') + $get('PRODSTOCK') + $get('PRODIMMO') + $get('SUBVENT') + $get('AUTPRODOP') + $get('PRODFIN') + $get('PRODEXCEPT') + $get('REPRISEPROV') + $get('TRANSFCHARG');
        $charges  = $get('ACHATCONSOM') + $get('SERVEXT') + $get('IMPTAX') + $get('CHPERS') + $get('AUTCHOP') + $get('CHARGEFIN') + $get('CHAREXCEPT') + $get('AMORTPROV') + $get('IMPOT');

        return $produits - $charges;
    }
}
