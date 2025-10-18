<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class VariationsCapitauxController extends Controller
{
    /**
     * Tableau des variations des capitaux propres - PCG Madagascar 2005
     * Version simplifiée pour école
     */
    public function index(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);
        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

        // Helper pour récupérer soldes par période
        $getSolde = function ($code, $debut, $fin) {
            $resultat = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $debut, $fin);
            return $resultat && $resultat->montant_total ? floatval($resultat->montant_total) : 0;
        };

        // Récupérer les exercices N, N-1, N-2
        $exercices = \App\Models\exercice\ExerciceComptable::orderBy('Annee_fiscale', 'desc')->limit(3)->get();
        
        $dateDebutN = $dateDebut;
        $dateFinN = $dateFin;
        $dateDebutN1 = $exercices[1]->Date_debut ?? null;
        $dateFinN1 = $exercices[1]->Date_fin ?? null;
        $dateDebutN2 = $exercices[2]->Date_debut ?? null;
        $dateFinN2 = $exercices[2]->Date_fin ?? null;

        // ============ SOLDES N-2 ============
        $capitalN2 = $dateDebutN2 ? $getSolde('CAPITAL', $dateDebutN2, $dateFinN2) : 0;
        $primeN2 = $dateDebutN2 ? $getSolde('PRIME', $dateDebutN2, $dateFinN2) : 0;
        $evalN2 = $dateDebutN2 ? $getSolde('EVAL', $dateDebutN2, $dateFinN2) : 0;
        $equivN2 = $dateDebutN2 ? $getSolde('EQUIV', $dateDebutN2, $dateFinN2) : 0;
        $resultN2 = $dateDebutN2 ? $getSolde('RESULT', $dateDebutN2, $dateFinN2) : 0;
        $autcproN2 = $dateDebutN2 ? $getSolde('AUTCPRO', $dateDebutN2, $dateFinN2) : 0;
        $totalN2 = $capitalN2 + $primeN2 + $evalN2 + $equivN2 + $resultN2 + $autcproN2;

        // ============ SOLDES N-1 ============
        $capitalN1 = $dateDebutN1 ? $getSolde('CAPITAL', $dateDebutN1, $dateFinN1) : 0;
        $primeN1 = $dateDebutN1 ? $getSolde('PRIME', $dateDebutN1, $dateFinN1) : 0;
        $evalN1 = $dateDebutN1 ? $getSolde('EVAL', $dateDebutN1, $dateFinN1) : 0;
        $equivN1 = $dateDebutN1 ? $getSolde('EQUIV', $dateDebutN1, $dateFinN1) : 0;
        $resultN1 = $dateDebutN1 ? $getSolde('RESULT', $dateDebutN1, $dateFinN1) : 0;
        $autcproN1 = $dateDebutN1 ? $getSolde('AUTCPRO', $dateDebutN1, $dateFinN1) : 0;
        $totalN1 = $capitalN1 + $primeN1 + $evalN1 + $equivN1 + $resultN1 + $autcproN1;

        // ============ SOLDES N ============
        $capitalN = $getSolde('CAPITAL', $dateDebutN, $dateFinN);
        $primeN = $getSolde('PRIME', $dateDebutN, $dateFinN);
        $evalN = $getSolde('EVAL', $dateDebutN, $dateFinN);
        $equivN = $getSolde('EQUIV', $dateDebutN, $dateFinN);
        $resultN = $getSolde('RESULT', $dateDebutN, $dateFinN);
        $autcproN = $getSolde('AUTCPRO', $dateDebutN, $dateFinN);
        $totalN = $capitalN + $primeN + $evalN + $equivN + $resultN + $autcproN;

        // ============ VARIATIONS ============
        $varCapitalN1 = $capitalN1 - $capitalN2;
        $varPrimeN1 = $primeN1 - $primeN2;
        $varEvalN1 = $evalN1 - $evalN2;
        $varEquivN1 = $equivN1 - $equivN2;
        $varResultN1 = $resultN1;
        $varAutcproN1 = $autcproN1 - $autcproN2;
        $varTotalN1 = $totalN1 - $totalN2;

        $varCapitalN = $capitalN - $capitalN1;
        $varPrimeN = $primeN - $primeN1;
        $varEvalN = $evalN - $evalN1;
        $varEquivN = $equivN - $equivN1;
        $varResultN = $resultN;
        $varAutcproN = $autcproN - $autcproN1;
        $varTotalN = $totalN - $totalN1;

        $structure = [
            [
                'label' => 'Solde au début N-1',
                'capital' => $capitalN2,
                'prime' => $primeN2,
                'eval' => $evalN2,
                'equiv' => $equivN2,
                'result' => $resultN2,
                'autcpro' => $autcproN2,
                'total' => $totalN2,
                'isTotal' => true
            ],
            [
                'label' => 'Variations de l\'exercice N-1',
                'capital' => $varCapitalN1,
                'prime' => $varPrimeN1,
                'eval' => $varEvalN1,
                'equiv' => $varEquivN1,
                'result' => $varResultN1,
                'autcpro' => $varAutcproN1,
                'total' => $varTotalN1,
                'isDetail' => true
            ],
            [
                'label' => 'Solde à la fin N-1',
                'capital' => $capitalN1,
                'prime' => $primeN1,
                'eval' => $evalN1,
                'equiv' => $equivN1,
                'result' => $resultN1,
                'autcpro' => $autcproN1,
                'total' => $totalN1,
                'isTotal' => true
            ],
            [
                'label' => 'Variations de l\'exercice N',
                'capital' => $varCapitalN,
                'prime' => $varPrimeN,
                'eval' => $varEvalN,
                'equiv' => $varEquivN,
                'result' => $varResultN,
                'autcpro' => $varAutcproN,
                'total' => $varTotalN,
                'isDetail' => true
            ],
            [
                'label' => 'Solde à la fin N',
                'capital' => $capitalN,
                'prime' => $primeN,
                'eval' => $evalN,
                'equiv' => $equivN,
                'result' => $resultN,
                'autcpro' => $autcproN,
                'total' => $totalN,
                'isTotal' => true
            ]
        ];

        return response()->json($structure);
    }
}
