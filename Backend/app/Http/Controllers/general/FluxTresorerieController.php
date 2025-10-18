<?php

namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class FluxTresorerieController extends Controller
{
    /**
     * Tableau des flux de trésorerie - Méthode INDIRECTE
     * Conforme PCG Madagascar 2005
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

        // ============ FLUX LIÉS AUX ACTIVITÉS OPÉRATIONNELLES ============
        $resultatNet = $get('RESULT');
        
        // Ajustements pour éliminer les éléments non-cash
        $dotationsAmort = $get('AMORTPROV');
        $reprisesAmort = $get('REPRISEPROV');
        $impotsDifferes = $get('IMPTDIFF');
        
        // Variations du BFR (besoin en fonds de roulement)
        // Pour calculer les variations, on compare N et N-1 (à implémenter selon ta logique)
        $variationStocks = 0; // $get('STOCKS') N-1 - N
        $variationClients = 0; // $get('CLIENTS') N-1 - N
        $variationFournisseurs = 0; // $get('FOURN') N - N-1
        $variationAutresCreances = 0;
        $variationAutresDettes = 0;
        
        $fluxOperationnels = $resultatNet 
            + $dotationsAmort 
            - $reprisesAmort 
            + $impotsDifferes
            - $variationStocks
            - $variationClients
            + $variationFournisseurs
            - $variationAutresCreances
            + $variationAutresDettes;

        // ============ FLUX LIÉS AUX ACTIVITÉS D'INVESTISSEMENT ============
        $acquisitionsImmo = $get('IMMOCO') + $get('IMMOINC') + $get('IMMOFIN'); // Acquisitions
        $cessionsImmo = 0; // À implémenter si tu gères les cessions
        $subventionsInvestissement = $get('SUBVINV');
        
        $fluxInvestissement = - $acquisitionsImmo + $cessionsImmo + $subventionsInvestissement;

        // ============ FLUX LIÉS AUX ACTIVITÉS DE FINANCEMENT ============
        $augmentationCapital = 0; // Variation capital N - N-1
        $empruntsNouveaux = 0; // Nouveaux emprunts
        $remboursementsEmprunts = 0; // Remboursements
        $dividendesVerses = 0; // Si applicable
        
        $fluxFinancement = $augmentationCapital + $empruntsNouveaux - $remboursementsEmprunts - $dividendesVerses;

        // ============ VARIATION DE TRÉSORERIE ============
        $variationTresorerie = $fluxOperationnels + $fluxInvestissement + $fluxFinancement;
        
        // Trésorerie début et fin de période
        $tresoDebut = 0; // Solde N-1
        $tresoFin = $get('TRESO') + $get('PLACEMENTS') + $get('TRESOFONDS') - $get('DECOUV');
        $variationCalculee = $tresoFin - $tresoDebut;

        $structure = [
            // ACTIVITÉS OPÉRATIONNELLES
            ['label' => 'FLUX DE TRÉSORERIE LIÉS AUX ACTIVITÉS OPÉRATIONNELLES', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Résultat net de l\'exercice', 'note' => '', 'montant' => $resultatNet, 'isTotal' => false],
            ['label' => 'Ajustements pour :', 'note' => '', 'montant' => null, 'isSubtitle' => true],
            ['label' => 'Dotations aux amortissements et provisions', 'note' => '', 'montant' => $dotationsAmort, 'isTotal' => false],
            ['label' => 'Reprises sur provisions', 'note' => '', 'montant' => -$reprisesAmort, 'isTotal' => false],
            ['label' => 'Variation des impôts différés', 'note' => '', 'montant' => $impotsDifferes, 'isTotal' => false],
            ['label' => 'Variation du besoin en fonds de roulement :', 'note' => '', 'montant' => null, 'isSubtitle' => true],
            ['label' => '- Stocks et en-cours', 'note' => '', 'montant' => -$variationStocks, 'isTotal' => false],
            ['label' => '- Créances clients', 'note' => '', 'montant' => -$variationClients, 'isTotal' => false],
            ['label' => '- Dettes fournisseurs', 'note' => '', 'montant' => $variationFournisseurs, 'isTotal' => false],
            ['label' => '- Autres créances et dettes', 'note' => '', 'montant' => $variationAutresDettes - $variationAutresCreances, 'isTotal' => false],
            ['label' => 'FLUX NET DE TRÉSORERIE GÉNÉRÉ PAR L\'ACTIVITÉ', 'note' => '', 'montant' => $fluxOperationnels, 'isTotal' => true],
            
            // ACTIVITÉS D'INVESTISSEMENT
            ['label' => 'FLUX DE TRÉSORERIE LIÉS AUX ACTIVITÉS D\'INVESTISSEMENT', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Acquisitions d\'immobilisations', 'note' => '', 'montant' => -$acquisitionsImmo, 'isTotal' => false],
            ['label' => 'Cessions d\'immobilisations', 'note' => '', 'montant' => $cessionsImmo, 'isTotal' => false],
            ['label' => 'Subventions d\'investissement reçues', 'note' => '', 'montant' => $subventionsInvestissement, 'isTotal' => false],
            ['label' => 'FLUX NET DE TRÉSORERIE LIÉ AUX OPÉRATIONS D\'INVESTISSEMENT', 'note' => '', 'montant' => $fluxInvestissement, 'isTotal' => true],
            
            // ACTIVITÉS DE FINANCEMENT
            ['label' => 'FLUX DE TRÉSORERIE LIÉS AUX ACTIVITÉS DE FINANCEMENT', 'note' => '', 'montant' => null, 'isTitle' => true],
            ['label' => 'Augmentation de capital', 'note' => '', 'montant' => $augmentationCapital, 'isTotal' => false],
            ['label' => 'Nouveaux emprunts', 'note' => '', 'montant' => $empruntsNouveaux, 'isTotal' => false],
            ['label' => 'Remboursements d\'emprunts', 'note' => '', 'montant' => -$remboursementsEmprunts, 'isTotal' => false],
            ['label' => 'Dividendes versés', 'note' => '', 'montant' => -$dividendesVerses, 'isTotal' => false],
            ['label' => 'FLUX NET DE TRÉSORERIE LIÉ AUX OPÉRATIONS DE FINANCEMENT', 'note' => '', 'montant' => $fluxFinancement, 'isTotal' => true],
            
            // VARIATION TOTALE
            ['label' => 'VARIATION DE LA TRÉSORERIE', 'note' => '', 'montant' => $variationTresorerie, 'isTotal' => true],
            ['label' => 'Trésorerie à l\'ouverture', 'note' => '', 'montant' => $tresoDebut, 'isTotal' => false],
            ['label' => 'Trésorerie à la clôture', 'note' => '', 'montant' => $tresoFin, 'isTotal' => false],
            ['label' => 'Variation de trésorerie (contrôle)', 'note' => '', 'montant' => $variationCalculee, 'isTotal' => true]
        ];

        return response()->json($structure);
    }
}
