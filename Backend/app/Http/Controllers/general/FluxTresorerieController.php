<?php
namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use DateTime;

class FluxTresorerieController extends Controller
{
    /**
     * Tableau des flux de trésorerie - Méthode INDIRECTE (PCG Madagascar 2005)
     */
    public function index(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);
        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

        $get = function ($code, $dStart, $dEnd) {
            $resultat = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dStart, $dEnd);
            return $resultat && $resultat->montant_total ? floatval($resultat->montant_total) : 0;
        };

        $getVariation = function ($code, $dStart, $dEnd) {
            $variation = \App\Http\Controllers\calcul\UtilesController::calculerVariationCategorie($code, $dStart, $dEnd);
            return $variation !== null ? floatval($variation) : 0;
        };

        // Helper calcul du solde
        $getSoldeTresorerie = function($date) use ($get) {
            return $get('TRESO', $date, $date)
                 + $get('PLACEMENTS', $date, $date)
                 + $get('TRESOFONDS', $date, $date);
        };

        $dateFinN1 = (new DateTime($dateDebut))->modify('-1 day')->format('Y-m-d');

        // ==== Calculs de base par catégorie PCG (aucun zéro arbitraire) ====

        // Résultat et soldes du compte de résultat
        $produitsExploitation = $get('CA', $dateDebut, $dateFin)
                             + $get('PRODSTOCK', $dateDebut, $dateFin)
                             + $get('PRODIMMO', $dateDebut, $dateFin)
                             + $get('SUBVENT', $dateDebut, $dateFin)
                             + $get('AUTPRODOP', $dateDebut, $dateFin);
        $chargesExploitation  = $get('ACHATCONSOM', $dateDebut, $dateFin)
                             + $get('SERVEXT', $dateDebut, $dateFin)
                             + $get('IMPTAX', $dateDebut, $dateFin)
                             + $get('CHPERS', $dateDebut, $dateFin)
                             + $get('AUTCHOP', $dateDebut, $dateFin);
        
        $dotAmort = $get('AMORTPROV', $dateDebut, $dateFin);
        $prodFin = $get('PRODFIN', $dateDebut, $dateFin);
        $prodExcept = $get('PRODEXCEPT', $dateDebut, $dateFin);
        $reprises = $get('REPRISEPROV', $dateDebut, $dateFin);
        $chargeFin = $get('CHARGEFIN', $dateDebut, $dateFin);
        $charExcept = $get('CHAREXCEPT', $dateDebut, $dateFin);
        $impot = $get('IMPOT', $dateDebut, $dateFin);

        $totalProduits = $produitsExploitation + $prodFin + $prodExcept + $reprises;
        $totalCharges  = $chargesExploitation + $chargeFin + $charExcept + $dotAmort + $impot;
        $resultatNet   = $totalProduits - $totalCharges;

        // --- Ajustements flux non décaissés, non encaissés
        // Dotations/reprises = variat. sur AMORTPROV et REPRISEPROV
        $dotations = $get('AMORTPROV', $dateDebut, $dateFin); 
        $reprises  = $get('REPRISEPROV', $dateDebut, $dateFin); // à vérifier selon ta DB

        // Variation d’impôts différés (si tu as le compte 692 ou autres)
        $variationImpotsDifferes = $getVariation('IMPOT', $dateDebut, $dateFin); // ajuster si besoin

        // Variations d’éléments opérationnels (classe 3,4)
        $variationStocks = $getVariation('STOCKS', $dateDebut, $dateFin);
        $variationClients = $getVariation('CLIENTS', $dateDebut, $dateFin)
                          + $getVariation('AUTCREANCES', $dateDebut, $dateFin);
        $variationFournisseurs = $getVariation('FOURN', $dateDebut, $dateFin)
                              + $getVariation('DETTECT', $dateDebut, $dateFin)
                              + $getVariation('AUTDETTE', $dateDebut, $dateFin);

        // Plus ou moins-values de cession nettes
        $plusMoinsValues = ($get('PRODEXCEPT', $dateDebut, $dateFin) - $get('CHAREXCEPT', $dateDebut, $dateFin));

        // ---- FLUX ACTIVITE
        $fluxActivite = $resultatNet
            + $dotations
            - $reprises
            + $variationImpotsDifferes
            + $variationStocks
            + $variationClients
            + $variationFournisseurs
            + $plusMoinsValues;

        // ---- FLUX INVESTISSEMENT (acquisition/cession d’immobilisations)
        $acquisImmo = $getVariation('IMMOINC', $dateDebut, $dateFin)
                    + $getVariation('IMMOCO', $dateDebut, $dateFin)
                    + $getVariation('IMMOCOURS', $dateDebut, $dateFin)
                    + $getVariation('IMMOFIN', $dateDebut, $dateFin);
        // Cession = mouvement négatif sur comptes d'immos OU via produits de cession
        $cessionImmo = $get('PRODEXCEPT', $dateDebut, $dateFin); // à affiner (produits de cession réels...)
        $fluxInvestissement = - abs($acquisImmo) + abs($cessionImmo);

        // ---- FLUX FINANCEMENT
        // Augmentation de capital & primes
        $augmCapital    = $getVariation('CAPITAL', $dateDebut, $dateFin)
                        + $getVariation('PRIME', $dateDebut, $dateFin);
        // Emprunts > Variation sur 16x (emprunts) - on distingue émission/remboursement
        $variationEmprunt = $getVariation('EMPRUNT', $dateDebut, $dateFin);
        $emissionEmprunt = $variationEmprunt > 0 ? $variationEmprunt : 0;
        $remboursementEmprunt = $variationEmprunt < 0 ? abs($variationEmprunt) : 0;
        // Dividendes versés = Variation sur 457 (si applicable) ou sortie trésorerie liées aux CP
        $dividendesVerses = $get('DIVIDENDE', $dateDebut, $dateFin); // à adapter à ta structure

        $fluxFinancement = $augmCapital + $emissionEmprunt - $remboursementEmprunt - $dividendesVerses;

        // ============ VARIATION TRÉSORERIE ============
        $variationTresorerie = $fluxActivite + $fluxInvestissement + $fluxFinancement;

        // ----- Trésorerie ouverture/clôture
        $tresorerieOuverture = $getSoldeTresorerie($dateFinN1);
        $tresorerieCloture = $getSoldeTresorerie($dateFin);

        // ---- Incidence de change (à calculer si tu utilises des comptes en devises : ici laissé à 0)
        $incidenceDevises = 0;

        // === STRUCTURE EXPORT AVANCÉE ===
        $structure = [
            ['label' => "Résultat net de l'exercice", 'note' => '', 'montant' => $resultatNet],
            ['label' => "Ajustements pour :", 'note' => '', 'montant' => null, 'isSubtitle' => true],
            ['label' => "- Dotations nettes aux amortissements et provisions", 'note' => '', 'montant' => $dotations - $reprises],
            ['label' => "- Variation des impôts différés", 'note' => '', 'montant' => $variationImpotsDifferes],
            ['label' => "- Variation des stocks", 'note' => '', 'montant' => $variationStocks],
            ['label' => "- Variation des clients et autres créances", 'note' => '', 'montant' => $variationClients],
            ['label' => "- Variation des fournisseurs et autres dettes", 'note' => '', 'montant' => $variationFournisseurs],
            ['label' => "- Plus ou moins values de cession, nettes d'impôts", 'note' => '', 'montant' => $plusMoinsValues],
            ['label' => "Flux de trésorerie générés par l'activité", 'note' => 'A', 'montant' => $fluxActivite, 'isTotal' => true],

            ['label' => "Flux de trésorerie liés aux opérations d'investissement", 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => "Décaissements sur acquisitions d'immobilisations", 'note' => '', 'montant' => -abs($acquisImmo)],
            ['label' => "Encaissements sur cessions d'immobilisations", 'note' => '', 'montant' => abs($cessionImmo)],
            ['label' => "Flux de trésorerie liés aux opérations d'investissement", 'note' => 'B', 'montant' => $fluxInvestissement, 'isTotal' => true],

            ['label' => "Flux de trésorerie liés aux activités de financement", 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => "Dividendes versés aux actionnaires", 'note' => '', 'montant' => -$dividendesVerses],
            ['label' => "Augmentation de capital en numéraire", 'note' => '', 'montant' => $augmCapital],
            ['label' => "Émission d'emprunt", 'note' => '', 'montant' => $emissionEmprunt],
            ['label' => "Remboursement d'emprunt", 'note' => '', 'montant' => -$remboursementEmprunt],
            ['label' => "Flux de trésorerie liés aux activités de financement", 'note' => 'C', 'montant' => $fluxFinancement, 'isTotal' => true],

            ['label' => "Variation de trésorerie de la période (A+B+C)", 'note' => '', 'montant' => $variationTresorerie, 'isTotal' => true],
            ['label' => "Trésorerie d'ouverture", 'note' => '', 'montant' => $tresorerieOuverture],
            ['label' => "Trésorerie de clôture", 'note' => '', 'montant' => $tresorerieCloture],
            ['label' => "Incidence des variations de cours des devises", 'note' => '', 'montant' => $incidenceDevises],
            ['label' => "Variation de trésorerie", 'note' => '', 'montant' => $variationTresorerie, 'isTotal' => true]
        ];

        return response()->json($structure);
    }
}
