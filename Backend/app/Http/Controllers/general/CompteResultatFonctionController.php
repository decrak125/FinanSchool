<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class CompteResultatFonctionController extends Controller
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

        // PRODUITS
        $ca          = $get('CA');          // 700-709
        $prodVendu   = $get('PRODVENDU');   // 710-719
        $prodImmo    = $get('PRODIMMO');    // 720-729
        $prodLTTerm  = $get('PRODLTTERM');  // 730-739
        $subvent     = $get('SUBVENT');     // 740-749
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
        $impot       = $get('IMPOT');       // 690-699

        // Agrégats PCG Madagascar par fonction

        // Produit des activités ordinaires (ventes + production vendue + production immobilisée + subv d’exploitation)
        $produitsActivOrd =
              $ca
            + $prodVendu
            + $prodImmo
            + $prodLTTerm
            + $subvent;

        // Coût des ventes (simplifié: achats consommés + amort/prov liés à l’exploitation)
        $coutVentes = $achatConsom + $amortProv;

        $margeBrute = $produitsActivOrd - $coutVentes;

        // Charges d’exploitation (fonctionnelles)
        $chargesExploit = $servExt + $impTax + $chPers + $autChOp;

        // Résultat opérationnel (marge brute + autres prod op + transferts + reprises – charges d’exploitation)
        $resOp = $margeBrute + $autProdOp + $transfCharg + $repriseProv - $chargesExploit;

        // Résultat avant impôt
        $resAvantImpot = $resOp + $prodFin - $chargeFin;

        // Résultat net des activités ordinaires
        $resNetActivOrd = $resAvantImpot - $impot;

        // Résultat net de l’exercice
        $resNetExercice = $resNetActivOrd + ($prodExcept - $charExcept);

        $structure = [
            ['label' => 'Produit des activités ordinaires',             'note' => '', 'montant' => $produitsActivOrd],
            ['label' => 'Coût des ventes',                              'note' => '', 'montant' => $coutVentes],
            ['label' => 'I – MARGE BRUTE',                              'note' => '', 'montant' => $margeBrute, 'isTotal' => true],

            ['label' => 'Autres produits opérationnels',                'note' => '', 'montant' => $autProdOp],
            ['label' => 'Transferts de charges',                        'note' => '', 'montant' => $transfCharg],
            ['label' => 'Reprises sur provisions et pertes de valeur',  'note' => '', 'montant' => $repriseProv],
            ['label' => 'Services extérieurs',                          'note' => '', 'montant' => $servExt],
            ['label' => 'Impôts et taxes',                              'note' => '', 'montant' => $impTax],
            ['label' => 'Charges de personnel',                         'note' => '', 'montant' => $chPers],
            ['label' => 'Autres charges opérationnelles',               'note' => '', 'montant' => $autChOp],
            ['label' => 'II – RÉSULTAT OPÉRATIONNEL',                   'note' => '', 'montant' => $resOp, 'isTotal' => true],

            ['label' => 'Produits financiers',                          'note' => '', 'montant' => $prodFin],
            ['label' => 'Charges financières',                          'note' => '', 'montant' => $chargeFin],
            ['label' => 'III – RÉSULTAT AVANT IMPÔT',                   'note' => '', 'montant' => $resAvantImpot, 'isTotal' => true],

            ['label' => 'Impôts sur le résultat',                       'note' => '', 'montant' => $impot],
            ['label' => 'IV – RÉSULTAT NET DES ACTIVITÉS ORDINAIRES',   'note' => '', 'montant' => $resNetActivOrd, 'isTotal' => true],

            ['label' => 'Charges exceptionnelles',                      'note' => '', 'montant' => $charExcept],
            ['label' => 'Produits exceptionnels',                       'note' => '', 'montant' => $prodExcept],
            ['label' => 'V – RÉSULTAT NET DE L\'EXERCICE',              'note' => '', 'montant' => $resNetExercice, 'isTotal' => true],
        ];

        return response()->json($structure);
    }
}

