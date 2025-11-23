<?php
namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\exercice\ExerciceComptable;

class VariationsCapitauxController extends Controller
{
    /**
     * Tableau des variations des capitaux propres - PCG Madagascar 2005, compatible date
     */
    public function index(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);
        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

        // Récupère les 3 exercices les plus proches (contenant date_debut/date_fin)
        $exercices = ExerciceComptable::where('Date_fin', '<=', $dateFin)
            ->orderBy('Date_fin', 'desc')
            ->limit(3)
            ->get();

        if ($exercices->count() < 3) {
            return response()->json(['error' => 'Pas assez d\'exercices consécutifs pour rapport'], 422);
        }

        $exN   = $exercices[0]; // Exercice choisi
        $exN1  = $exercices[1]; // Exercice précédent
        $exN2  = $exercices[2]; // Encore avant

        // Helper solde sur période
        $getSolde = function ($code, $debut, $fin) {
            $r = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $debut, $fin);
            return $r && property_exists($r, "montant_total") ? floatval($r->montant_total) : 0;
        };

        // --- SOLDES EXERCICES ---
        $capN2    = $getSolde('CAPITAL',  $exN2->Date_debut, $exN2->Date_fin);
        $primeN2  = $getSolde('PRIME',    $exN2->Date_debut, $exN2->Date_fin);
        $evalN2   = $getSolde('EVAL',     $exN2->Date_debut, $exN2->Date_fin);
        $equivN2  = $getSolde('EQUIV',    $exN2->Date_debut, $exN2->Date_fin);
        $autcproN2= $getSolde('AUTCPRO',  $exN2->Date_debut, $exN2->Date_fin);
        $resultN2 = $getSolde('RESULT',   $exN2->Date_debut, $exN2->Date_fin);

        $capN1    = $getSolde('CAPITAL',  $exN1->Date_debut, $exN1->Date_fin);
        $primeN1  = $getSolde('PRIME',    $exN1->Date_debut, $exN1->Date_fin);
        $evalN1   = $getSolde('EVAL',     $exN1->Date_debut, $exN1->Date_fin);
        $equivN1  = $getSolde('EQUIV',    $exN1->Date_debut, $exN1->Date_fin);
        $autcproN1= $getSolde('AUTCPRO',  $exN1->Date_debut, $exN1->Date_fin);
        $resultN1 = $getSolde('RESULT',   $exN1->Date_debut, $exN1->Date_fin);

        $capN    = $getSolde('CAPITAL',  $exN->Date_debut, $exN->Date_fin);
        $primeN  = $getSolde('PRIME',    $exN->Date_debut, $exN->Date_fin);
        $evalN   = $getSolde('EVAL',     $exN->Date_debut, $exN->Date_fin);
        $equivN  = $getSolde('EQUIV',    $exN->Date_debut, $exN->Date_fin);
        $autcproN= $getSolde('AUTCPRO',  $exN->Date_debut, $exN->Date_fin);
        $resultN = $getSolde('RESULT',   $exN->Date_debut, $exN->Date_fin);

        // --- VARIATIONS avec affectation du résultat net --- (conforme PCG)
        $variationN1 = [
            'capital'  => $capN1    - $capN2,
            'prime'    => $primeN1  - $primeN2,
            'eval'     => $evalN1   - $evalN2,
            'equiv'    => $equivN1  - $equivN2,
            'autcpro'  => $autcproN1- $autcproN2,
            'result'   => $resultN2, // résultat affecté dans N-1
        ];

        $variationN = [
            'capital'  => $capN     - $capN1,
            'prime'    => $primeN   - $primeN1,
            'eval'     => $evalN    - $evalN1,
            'equiv'    => $equivN   - $equivN1,
            'autcpro'  => $autcproN - $autcproN1,
            'result'   => $resultN1, // résultat affecté dans N
        ];

        $structure = [
            [
                'label'    => "Solde au début N-1",
                'capital'  => $capN2,
                'prime'    => $primeN2,
                'eval'     => $evalN2,
                'equiv'    => $equivN2,
                'result'   => null,
                'autcpro'  => $autcproN2,
                'total'    => $capN2 + $primeN2 + $evalN2 + $equivN2 + $autcproN2,
                'isTotal'  => true
            ],
            [
                'label'    => "Mouvements de l'exercice N-1 (affectation du résultat N-2)",
                'capital'  => $variationN1['capital'],
                'prime'    => $variationN1['prime'],
                'eval'     => $variationN1['eval'],
                'equiv'    => $variationN1['equiv'],
                'result'   => $variationN1['result'],
                'autcpro'  => $variationN1['autcpro'],
                'total'    => ($variationN1['capital'] + $variationN1['prime'] + $variationN1['eval'] + $variationN1['equiv'] + $variationN1['autcpro']),
                'isDetail' => true
            ],
            [
                'label'    => "Solde à la fin N-1",
                'capital'  => $capN1,
                'prime'    => $primeN1,
                'eval'     => $evalN1,
                'equiv'    => $equivN1,
                'result'   => $resultN1,
                'autcpro'  => $autcproN1,
                'total'    => $capN1 + $primeN1 + $evalN1 + $equivN1 + $autcproN1,
                'isTotal'  => true
            ],
            [
                'label'    => "Mouvements de l'exercice N (affectation du résultat N-1)",
                'capital'  => $variationN['capital'],
                'prime'    => $variationN['prime'],
                'eval'     => $variationN['eval'],
                'equiv'    => $variationN['equiv'],
                'result'   => $variationN['result'],
                'autcpro'  => $variationN['autcpro'],
                'total'    => ($variationN['capital'] + $variationN['prime'] + $variationN['eval'] + $variationN['equiv'] + $variationN['autcpro']),
                'isDetail' => true
            ],
            [
                'label'    => "Solde à la fin N",
                'capital'  => $capN,
                'prime'    => $primeN,
                'eval'     => $evalN,
                'equiv'    => $equivN,
                'result'   => $resultN,
                'autcpro'  => $autcproN,
                'total'    => $capN + $primeN + $evalN + $equivN + $autcproN,
                'isTotal'  => true
            ]
        ];

        return response()->json($structure);
    }
}
