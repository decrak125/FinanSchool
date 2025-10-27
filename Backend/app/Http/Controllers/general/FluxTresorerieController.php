<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class FluxTresorerieController extends Controller
{
    /**
     * Tableau des flux de trésorerie - Méthode INDIRECTE
     * Conforme au template officiel PCG Madagascar 2005
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

        // Helper pour variations (à implémenter selon ta logique)
        $getVariation = function ($code) use ($dateDebut, $dateFin) {
            // Calcule la variation N - N-1 pour les postes de bilan
            return 0; // Placeholder
        };

        // ============ CALCUL DU RÉSULTAT NET ============
        $ca = $get('CA');
        $prodStock = $get('PRODSTOCK');
        $prodImmo = $get('PRODIMMO');
        $subvent = $get('SUBVENT');
        $autProdOp = $get('AUTPRODOP');
        $prodFin = $get('PRODFIN');
        $prodExcept = $get('PRODEXCEPT');
        $repriseProv = $get('REPRISEPROV');
        
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

        // ============ AJUSTEMENTS ET VARIATIONS ============
        $amortissements = $amortProv;
        $provisions = $amortProv; // Provisions comprises dans AMORTPROV
        $impotsDifferes = 0; // À implémenter si nécessaire
        $variationStocks = $getVariation('STOCKS');
        $variationClients = $getVariation('CLIENTS');
        $variationFournisseurs = $getVariation('FOURN');
        $plusMoinsValues = 0; // À calculer si nécessaire

        // ============ FLUX ACTIVITÉ (A) ============
        $fluxActivite = $resultatNet + $amortissements + $provisions + $impotsDifferes 
                      + $variationStocks + $variationClients + $variationFournisseurs + $plusMoinsValues;

        // ============ FLUX INVESTISSEMENT (B) ============
        $acquisImmo = $getVariation('IMMOINC') + $getVariation('IMMOCO') + $getVariation('IMMOFIN');
        $cessionImmo = 0; // À implémenter
        $variationPerimetre = 0; // Consolidation si applicable
        $fluxInvestissement = -$acquisImmo + $cessionImmo + $variationPerimetre;

        // ============ FLUX FINANCEMENT (C) ============
        $dividendesVerses = 0; // À implémenter
        $augmentationCapital = $getVariation('CAPITAL') + $getVariation('PRIME');
        $emissionEmprunt = $getVariation('EMPRUNT');
        $remboursementEmprunt = 0; // À calculer selon les remboursements
        $fluxFinancement = -$dividendesVerses + $augmentationCapital + $emissionEmprunt - $remboursementEmprunt;

        // ============ VARIATION TRÉSORERIE ============
        $variationTresorerie = $fluxActivite + $fluxInvestissement + $fluxFinancement;
        $tresorerieOuverture = 0; // Solde N-1
        $tresoreririeClot = $get('TRESO') + $get('PLACEMENTS') + $get('TRESOFONDS');
        $incidenceDevises = 0; // Si applicable

        // Structure exacte selon template PCG Madagascar 2005
        $structure = [
            ['label' => 'Résultat net de l\'exercice', 'note' => '', 'montant' => $resultatNet],
            ['label' => 'Ajustements pour :', 'note' => '', 'montant' => null, 'isSubtitle' => true],
            ['label' => '- Amortissements et provisions', 'note' => '', 'montant' => $amortissements + $provisions],
            ['label' => '- Variation des impôts différés', 'note' => '', 'montant' => $impotsDifferes],
            ['label' => '- Variation des stocks', 'note' => '', 'montant' => $variationStocks],
            ['label' => '- Variation des clients et autres créances', 'note' => '', 'montant' => $variationClients],
            ['label' => '- Variation des fournisseurs et autres dettes', 'note' => '', 'montant' => $variationFournisseurs],
            ['label' => '- Plus ou moins values de cession, nettes d\'impôts', 'note' => '', 'montant' => $plusMoinsValues],
            ['label' => 'Flux de trsorerie générés par l\'activité', 'note' => 'A', 'montant' => $fluxActivite, 'isTotal' => true],
            
            ['label' => 'Flux de trsorerie liés aux opérations d\'investissement', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Décaissements sur acquisitions d\'immobilisations', 'note' => '', 'montant' => -$acquisImmo],
            ['label' => 'Encaissements sur cessions d\'immobilisations', 'note' => '', 'montant' => $cessionImmo],
            ['label' => 'Incidence des variations de périmètre de consolidation', 'note' => '1', 'montant' => $variationPerimetre],
            ['label' => 'Flux de trsorerie liés aux opérations d\'investissement', 'note' => 'B', 'montant' => $fluxInvestissement, 'isTotal' => true],
            
            ['label' => 'Flux de trsorerie liés aux activités de financement', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Dividendes versés aux actionnaires', 'note' => '', 'montant' => -$dividendesVerses],
            ['label' => 'Augmentation de capital en numéraire', 'note' => '', 'montant' => $augmentationCapital],
            ['label' => 'Émission d\'emprunt', 'note' => '', 'montant' => $emissionEmprunt],
            ['label' => 'Remboursement d\'emprunt', 'note' => '', 'montant' => -$remboursementEmprunt],
            ['label' => 'Flux de trsorerie liés aux opérations de financement', 'note' => 'C', 'montant' => $fluxFinancement, 'isTotal' => true],
            
            ['label' => 'Variation de trsorerie de la période (A+B+C)', 'note' => '', 'montant' => $variationTresorerie, 'isTotal' => true],
            ['label' => 'Trsorerie d\'ouverture', 'note' => '', 'montant' => $tresorerieOuverture],
            ['label' => 'Trsorerie de clôture', 'note' => '', 'montant' => $tresoreririeClot],
            ['label' => 'Incidence des variations de cours des devises', 'note' => '', 'montant' => $incidenceDevises],
            ['label' => 'Variation de trsorerie', 'note' => '', 'montant' => $variationTresorerie, 'isTotal' => true]
        ];

        return response()->json($structure);
    }
}
