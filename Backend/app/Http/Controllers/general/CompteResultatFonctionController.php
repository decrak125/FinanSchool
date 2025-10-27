<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class CompteResultatFonctionController extends Controller
{
    /**
     * Renvoie le compte de résultat par fonction complet (PCG Madagascar),
     * utilisant uniquement les codes catégories du seeder existant.
     * GET /api/compte-resultat/fonction?date_debut=YYYY-MM-DD&date_fin=YYYY-MM-DD
     */
    public function index(Request $request)
    {
        // Validation des dates
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);
        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

        // Helper pour chaque poste (utilise la méthode existante)
        $get = function ($code) use ($dateDebut, $dateFin) {
            $resultat = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return $resultat && $resultat->montant_total ? floatval($resultat->montant_total) : 0;
        };

        // Récupération des montants selon les codes du seeder UNIQUEMENT
        $ca               = $get('CA');               // 700-709
        $prodStock        = $get('PRODSTOCK');        // 710-719
        $prodImmo         = $get('PRODIMMO');         // 720-729
        $subvent          = $get('SUBVENT');          // 740-749
        $autProdOp        = $get('AUTPRODOP');        // 750-759
        $prodFin          = $get('PRODFIN');          // 760-769
        $prodExcept       = $get('PRODEXCEPT');       // 770-779
        $repriseProv      = $get('REPRISEPROV');      // 780-789
        
        $achatConsom      = $get('ACHATCONSOM');      // 601-609
        $servExt          = $get('SERVEXT');          // 611-619 + 620-629
        $impTax           = $get('IMPTAX');           // 630-639
        $chPers           = $get('CHPERS');           // 640-649
        $autChOp          = $get('AUTCHOP');          // 651-659
        $chargeFin        = $get('CHARGEFIN');        // 660-669
        $charExcept       = $get('CHAREXCEPT');       // 670-679
        $amortProv        = $get('AMORTPROV');        // 680-689
        $impot            = $get('IMPOT');            // 690-699

        // Calculs des agrégats selon PCG par fonction
        $produitsActivOrd = $ca + $prodStock + $prodImmo + $subvent;
        $coutVentes       = $achatConsom + $amortProv; // Simplifié pour coût des ventes
        $margeBrute       = $produitsActivOrd - $coutVentes;
        $chargesExploit   = $servExt + $impTax + $chPers + $autChOp;
        $resOp            = $margeBrute + $autProdOp + $repriseProv - $chargesExploit;
        $resAvantImpot    = $resOp + $prodFin - $chargeFin;
        $resNetActivOrd   = $resAvantImpot - $impot;
        $resNetExercice   = $resNetActivOrd + ($prodExcept - $charExcept);

        $structure = [
            ['label'=>'Produit des activités ordinaires',       'note'=>'', 'montant'=>$produitsActivOrd],
            ['label'=>'Coût des ventes',                        'note'=>'', 'montant'=>$coutVentes],
            ['label'=>'I – MARGE BRUTE',                        'note'=>'', 'montant'=>$margeBrute, 'isTotal'=>true],
            ['label'=>'Autres produits opérationnels',          'note'=>'', 'montant'=>$autProdOp],
            ['label'=>'Reprises sur provisions',                'note'=>'', 'montant'=>$repriseProv],
            ['label'=>'Services extérieurs',                    'note'=>'', 'montant'=>$servExt],
            ['label'=>'Impôts et taxes',                        'note'=>'', 'montant'=>$impTax],
            ['label'=>'Charges de personnel',                   'note'=>'', 'montant'=>$chPers],
            ['label'=>'Autres charges opérationnelles',         'note'=>'', 'montant'=>$autChOp],
            ['label'=>'II – RÉSULTAT OPÉRATIONNEL',             'note'=>'', 'montant'=>$resOp, 'isTotal'=>true],
            ['label'=>'Produits financiers',                    'note'=>'', 'montant'=>$prodFin],
            ['label'=>'Charges financières',                    'note'=>'', 'montant'=>$chargeFin],
            ['label'=>'III – RÉSULTAT AVANT IMPÔT',             'note'=>'', 'montant'=>$resAvantImpot, 'isTotal'=>true],
            ['label'=>'Impôts sur résultats',                   'note'=>'', 'montant'=>$impot],
            ['label'=>'IV – RÉSULTAT NET DES ACTIVITÉS ORDINAIRES', 'note'=>'', 'montant'=>$resNetActivOrd, 'isTotal'=>true],
            ['label'=>'Charges exceptionnelles',                'note'=>'', 'montant'=>$charExcept],
            ['label'=>'Produits exceptionnels',                 'note'=>'', 'montant'=>$prodExcept],
            ['label'=>'V – RÉSULTAT NET DE L\'EXERCICE',        'note'=>'', 'montant'=>$resNetExercice, 'isTotal'=>true]
        ];

        return response()->json($structure);
    }
}
