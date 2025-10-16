<?php
namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class CompteResultatFonctionController extends Controller
{
    /**
     * Renvoie le compte de résultat par fonction complet (structure PCG Madagascar),
     * avec toutes les formules et agrégats calculés.
     * Appel : GET /api/compte-resultat/fonction?date_debut=YYYY-MM-DD&date_fin=YYYY-MM-DD
     */
    public function index(Request $request)
    {
        // Validation des paramètres de date
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);
        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

        // Helper pour chaque poste simple
        $get = function ($code) use ($dateDebut, $dateFin) {
            $resultat = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return $resultat && $resultat->montant_total ? floatval($resultat->montant_total) : 0;
        };

        // Les montants de chaque poste (codes catégories fonctionnelles par fonction)
        $ventesActivOrdinaires = $get('VENTES');
        $coutVentes            = $get('COUTVENTE');
        $autProdOp             = $get('AUTPRODOP');
        $coutsCommerciaux      = $get('CHARGECOMM');
        $chargesAdministratives= $get('CHARGEADM');
        $autChOp               = $get('AUTCHOP');
        $prodFin               = $get('PRODFIN');
        $chargeFin             = $get('CHARGEFIN');
        $impot                 = $get('IMPOT');
        $impotDiff             = $get('IMPOTDIFF');
        $prodExcept            = $get('PRODEXCEPT');
        $chargExcept           = $get('CHAREXCEPT');

        // Formules agrégées selon PCG par fonction
        $margeBrute            = $ventesActivOrdinaires - $coutVentes;
        $resOp                 = $margeBrute + $autProdOp - $coutsCommerciaux - $chargesAdministratives - $autChOp;
        $resAvantImpot         = $resOp + $prodFin - $chargeFin;
        $resNetActivOrdin      = $resAvantImpot - $impot - $impotDiff;
        $resNetExercice        = $resNetActivOrdin + ($prodExcept - $chargExcept);

        $structure = [
            ['label'=>'Produit des activités ordinaires',       'note'=>'', 'montant'=>$ventesActivOrdinaires],
            ['label'=>'Coût des ventes',                        'note'=>'', 'montant'=>$coutVentes],
            ['label'=>'I – MARGE BRUTE',                        'note'=>'', 'montant'=>$margeBrute, 'isTotal'=>true],
            ['label'=>'Autres produits opérationnels',          'note'=>'', 'montant'=>$autProdOp],
            ['label'=>'Coûts commerciaux',                      'note'=>'', 'montant'=>$coutsCommerciaux],
            ['label'=>'Charges administratives',                'note'=>'', 'montant'=>$chargesAdministratives],
            ['label'=>'Autres charges opérationnelles',         'note'=>'', 'montant'=>$autChOp],
            ['label'=>'II – RÉSULTAT OPÉRATIONNEL',             'note'=>'', 'montant'=>$resOp, 'isTotal'=>true],
            ['label'=>'Produits financiers',                    'note'=>'', 'montant'=>$prodFin],
            ['label'=>'Charges financières',                    'note'=>'', 'montant'=>$chargeFin],
            ['label'=>'III – RÉSULTAT AVANT IMPÔT',             'note'=>'', 'montant'=>$resAvantImpot, 'isTotal'=>true],
            ['label'=>'Impôts exigibles sur résultats',         'note'=>'', 'montant'=>$impot],
            ['label'=>'Impôts différés',                        'note'=>'', 'montant'=>$impotDiff],
            ['label'=>'IV – RÉSULTAT NET DES ACTIVITÉS ORDINAIRES', 'note'=>'', 'montant'=>$resNetActivOrdin, 'isTotal'=>true],
            ['label'=>'Charges extraordinaires',                'note'=>'', 'montant'=>$chargExcept],
            ['label'=>'Produits extraordinaires',               'note'=>'', 'montant'=>$prodExcept],
            ['label'=>'V – RÉSULTAT NET DE L`EXERCICE',         'note'=>'', 'montant'=>$resNetExercice, 'isTotal'=>true]
        ];

        return response()->json($structure);
    }
}
