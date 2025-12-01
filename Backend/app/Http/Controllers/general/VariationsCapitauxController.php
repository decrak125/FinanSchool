<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Models\exercice\ExerciceComptable;

class VariationsCapitauxController extends Controller
{
    /**
     * Tableau des variations des capitaux propres - PCG Madagascar 2005
     */
    public function index(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);

        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

        // 1. Récupérer les 3 exercices dont la Date_fin <= date_fin
        $exercices = ExerciceComptable::where('Date_fin', '<=', $dateFin)
            ->orderBy('Date_fin', 'desc')
            ->limit(3)
            ->get();

        if ($exercices->count() < 3) {
            return response()->json(['error' => 'Pas assez d\'exercices consécutifs pour ce rapport'], 422);
        }

        $exN   = $exercices[0]; // N
        $exN1  = $exercices[1]; // N-1
        $exN2  = $exercices[2]; // N-2

        // Helper pour obtenir le "solde" d'une catégorie sur un exercice
        $getSolde = function ($code, $debut, $fin) {
            $r = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $debut, $fin);
            return $r && property_exists($r, 'montant_total') ? floatval($r->montant_total) : 0;
        };

        // ================= SOLDE DES CAPITAUX PROPRES PAR EXERCICE =================

        // N-2
        $capitalN2    = $getSolde('CAPITAL',    $exN2->Date_debut, $exN2->Date_fin);
        $reservesN2   = $getSolde('RESERVES',   $exN2->Date_debut, $exN2->Date_fin);
        $reportN2     = $getSolde('REPORTNOUV',$exN2->Date_debut, $exN2->Date_fin);
        $subvInvN2    = $getSolde('SUBVINVEST',$exN2->Date_debut, $exN2->Date_fin);
        $provRegN2    = $getSolde('PROVREG',   $exN2->Date_debut, $exN2->Date_fin);
        $resultN2     = $this->getResultatExercice($exN2); // résultat net N-2

        // N-1
        $capitalN1    = $getSolde('CAPITAL',    $exN1->Date_debut, $exN1->Date_fin);
        $reservesN1   = $getSolde('RESERVES',   $exN1->Date_debut, $exN1->Date_fin);
        $reportN1     = $getSolde('REPORTNOUV',$exN1->Date_debut, $exN1->Date_fin);
        $subvInvN1    = $getSolde('SUBVINVEST',$exN1->Date_debut, $exN1->Date_fin);
        $provRegN1    = $getSolde('PROVREG',   $exN1->Date_debut, $exN1->Date_fin);
        $resultN1     = $this->getResultatExercice($exN1); // résultat net N-1

        // N
        $capitalN     = $getSolde('CAPITAL',    $exN->Date_debut, $exN->Date_fin);
        $reservesN    = $getSolde('RESERVES',   $exN->Date_debut, $exN->Date_fin);
        $reportN      = $getSolde('REPORTNOUV',$exN->Date_debut, $exN->Date_fin);
        $subvInvN     = $getSolde('SUBVINVEST',$exN->Date_debut, $exN->Date_fin);
        $provRegN     = $getSolde('PROVREG',   $exN->Date_debut, $exN->Date_fin);
        $resultN      = $this->getResultatExercice($exN); // résultat net N

        // ================= VARIATIONS (MOUVEMENTS) =================
        // Hypothèse PCG: le résultat N-2 est affecté en N-1 (vers réserves/report/autres), idem N-1 en N

        $variationN1 = [
            'capital'   => $capitalN1  - $capitalN2,
            'reserves'  => $reservesN1 - $reservesN2,
            'report'    => $reportN1   - $reportN2,
            'subvInv'   => $subvInvN1  - $subvInvN2,
            'provReg'   => $provRegN1  - $provRegN2,
            'result'    => $resultN2,  // résultat N-2 affecté pendant N-1
        ];

        $variationN = [
            'capital'   => $capitalN  - $capitalN1,
            'reserves'  => $reservesN - $reservesN1,
            'report'    => $reportN   - $reportN1,
            'subvInv'   => $subvInvN  - $subvInvN1,
            'provReg'   => $provRegN  - $provRegN1,
            'result'    => $resultN1, // résultat N-1 affecté pendant N
        ];

        // ================= STRUCTURE DU TABLEAU =================

        $structure = [
            // Ligne 1 : Solde au début N-1 (fin N-2)
            [
                'label'     => "Solde au début N-1",
                'capital'   => $capitalN2,
                'reserves'  => $reservesN2,
                'report'    => $reportN2,
                'subvInv'   => $subvInvN2,
                'provReg'   => $provRegN2,
                'result'    => null,
                'total'     => $capitalN2 + $reservesN2 + $reportN2 + $subvInvN2 + $provRegN2,
                'isTotal'   => true,
            ],

            // Ligne 2 : Mouvements N-1 (affectation résultat N-2 comprise)
            [
                'label'     => "Mouvements de l'exercice N-1 (affectation du résultat N-2)",
                'capital'   => $variationN1['capital'],
                'reserves'  => $variationN1['reserves'],
                'report'    => $variationN1['report'],
                'subvInv'   => $variationN1['subvInv'],
                'provReg'   => $variationN1['provReg'],
                'result'    => $variationN1['result'],
                'total'     => $variationN1['capital'] + $variationN1['reserves'] + $variationN1['report'] + $variationN1['subvInv'] + $variationN1['provReg'],
                'isDetail'  => true,
            ],

            // Ligne 3 : Solde fin N-1
            [
                'label'     => "Solde à la fin N-1",
                'capital'   => $capitalN1,
                'reserves'  => $reservesN1,
                'report'    => $reportN1,
                'subvInv'   => $subvInvN1,
                'provReg'   => $provRegN1,
                'result'    => $resultN1,
                'total'     => $capitalN1 + $reservesN1 + $reportN1 + $subvInvN1 + $provRegN1,
                'isTotal'   => true,
            ],

            // Ligne 4 : Mouvements N (affectation résultat N-1 comprise)
            [
                'label'     => "Mouvements de l'exercice N (affectation du résultat N-1)",
                'capital'   => $variationN['capital'],
                'reserves'  => $variationN['reserves'],
                'report'    => $variationN['report'],
                'subvInv'   => $variationN['subvInv'],
                'provReg'   => $variationN['provReg'],
                'result'    => $variationN['result'],
                'total'     => $variationN['capital'] + $variationN['reserves'] + $variationN['report'] + $variationN['subvInv'] + $variationN['provReg'],
                'isDetail'  => true,
            ],

            // Ligne 5 : Solde fin N
            [
                'label'     => "Solde à la fin N",
                'capital'   => $capitalN,
                'reserves'  => $reservesN,
                'report'    => $reportN,
                'subvInv'   => $subvInvN,
                'provReg'   => $provRegN,
                'result'    => $resultN,
                'total'     => $capitalN + $reservesN + $reportN + $subvInvN + $provRegN,
                'isTotal'   => true,
            ],
        ];

        return response()->json($structure);
    }

    /**
     * Calcule le résultat net d'un exercice donné (en réutilisant ton compte de résultat)
     */
    protected function getResultatExercice(ExerciceComptable $ex)
    {
        // Ici, tu peux réutiliser la même logique que ton CompteResultatFonctionController
        // ou une méthode dédiée dans UtilesController, par exemple:
        $dateDebut = $ex->Date_debut;
        $dateFin   = $ex->Date_fin;

        $get = function ($code) use ($dateDebut, $dateFin) {
            $r = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return $r && $r->montant_total ? floatval($r->montant_total) : 0;
        };

        // Reprends ici ta formule de résultat net (celle qui fonctionne déjà dans ton compte de résultat)
        $ca          = $get('CA');
        $prodVendu   = $get('PRODVENDU');
        $prodImmo    = $get('PRODIMMO');
        $prodLTTerm  = $get('PRODLTTERM');
        $subvent     = $get('SUBVENT');
        $autProdOp   = $get('AUTPRODOP');
        $prodFin     = $get('PRODFIN');
        $prodExcept  = $get('PRODEXCEPT');
        $repriseProv = $get('REPRISEPROV');
        $transfCharg = $get('TRANSFCHARG');

        $achatConsom = $get('ACHATCONSOM');
        $servExt     = $get('SERVEXT');
        $impTax      = $get('IMPTAX');
        $chPers      = $get('CHPERS');
        $autChOp     = $get('AUTCHOP');
        $chargeFin   = $get('CHARGEFIN');
        $charExcept  = $get('CHAREXCEPT');
        $amortProv   = $get('AMORTPROV');
        $impot       = $get('IMPOT');

        $totalProduits =
              $ca + $prodVendu + $prodImmo + $prodLTTerm
            + $subvent + $autProdOp + $prodFin
            + $prodExcept + $repriseProv + $transfCharg;

        $totalCharges =
              $achatConsom + $servExt + $impTax + $chPers
            + $autChOp + $chargeFin + $charExcept
            + $amortProv + $impot;

        return $totalProduits - $totalCharges;
    }
}
