<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Events\MouvementCreated;
use App\Http\Controllers\calcul\UtilesController;
use App\Models\ParametresAnalytique\IndicateurAnalytique;
use App\Models\ParametresAnalytique\InterpretationIndicateur;

class IndicateursGenerauxController extends Controller
{
    /**
     * Calcule le Total des Produits
     * Somme des comptes de classe 7
     */
    public function calculTotalProduits(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // TOTAL DES PRODUITS (Comptes de classe 7)
        $totalProduits = UtilesController::calculerTotalCategorieGroupe([
            'CA', 'PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP', 
            'PRODFIN', 'PRODEXCEPT', 'REPRISEPROV'
        ], $dateDebut, $dateFin);

        return response()->json([
            'success' => true,
            'total_produits' => [
                'valeur' => round($totalProduits, 2),
                'definition' => 'Tous les revenus de l\'école'
            ],
            'details_comptes' => [
                'chiffre_affaires' => UtilesController::calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin),
                'produits_exploitation' => UtilesController::calculerTotalCategorieGroupe(['PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP'], $dateDebut, $dateFin),
                'produits_financiers' => UtilesController::calculerTotalCategorieGroupe(['PRODFIN'], $dateDebut, $dateFin),
                'produits_exceptionnels' => UtilesController::calculerTotalCategorieGroupe(['PRODEXCEPT'], $dateDebut, $dateFin),
                'reprises_provisions' => UtilesController::calculerTotalCategorieGroupe(['REPRISEPROV'], $dateDebut, $dateFin)
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ]
        ]);
    }

    /**
     * Calcule le Total des Charges
     * Somme des comptes de classe 6
     */
    public function calculTotalCharges(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // TOTAL DES CHARGES (Comptes de classe 6)
        $totalCharges = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 
            'AMORTPROV', 'CHARGEFIN', 'CHAREXCEPT'
        ], $dateDebut, $dateFin);

        return response()->json([
            'success' => true,
            'total_charges' => [
                'valeur' => round($totalCharges, 2),
                'definition' => 'Ensemble des dépenses'
            ],
            'details_comptes' => [
                'achats_consommes' => UtilesController::calculerTotalCategorieGroupe(['ACHATCONSOM'], $dateDebut, $dateFin),
                'services_exterieurs' => UtilesController::calculerTotalCategorieGroupe(['SERVEXT'], $dateDebut, $dateFin),
                'charges_personnel' => UtilesController::calculerTotalCategorieGroupe(['CHPERS'], $dateDebut, $dateFin),
                'autres_charges_exploitation' => UtilesController::calculerTotalCategorieGroupe(['AUTCHOP'], $dateDebut, $dateFin),
                'dotations_amortissements' => UtilesController::calculerTotalCategorieGroupe(['AMORTPROV'], $dateDebut, $dateFin),
                'charges_financieres' => UtilesController::calculerTotalCategorieGroupe(['CHARGEFIN'], $dateDebut, $dateFin),
                'charges_exceptionnelles' => UtilesController::calculerTotalCategorieGroupe(['CHAREXCEPT'], $dateDebut, $dateFin)
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ]
        ]);
    }

    /**
     * Calcule le Résultat net
     * Formule : Produits – Charges
     */
    public function calculResultatNet(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // TOTAL PRODUITS
        $totalProduits = UtilesController::calculerTotalCategorieGroupe([
            'CA', 'PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP', 
            'PRODFIN', 'PRODEXCEPT', 'REPRISEPROV'
        ], $dateDebut, $dateFin);

        // TOTAL CHARGES
        $totalCharges = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 
            'AMORTPROV', 'CHARGEFIN', 'CHAREXCEPT'
        ], $dateDebut, $dateFin);

        // RÉSULTAT NET
        $resultatNet = $totalProduits - $totalCharges;
        
        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Résultat net', $resultatNet);

        return response()->json([
            'success' => true,
            'resultat_net' => [
                'valeur' => round($resultatNet, 2),
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte'],
                'definition' => 'Bénéfice ou perte de l\'exercice'
            ],
            'details_calcul' => [
                'total_produits' => $totalProduits,
                'total_charges' => $totalCharges
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule']
        ]);
    }

    /**
     * Calcule la marge d'exploitation
     * Formule : (Produits d'exploitation - Charges d'exploitation) / Produits d'exploitation × 100
     */
    public function calculMargeExploitation(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // PRODUITS D'EXPLOITATION
        $produitsExploitation = UtilesController::calculerTotalCategorieGroupe([
            'CA', 'PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP', 'REPRISEPROV'
        ], $dateDebut, $dateFin);

        // CHARGES D'EXPLOITATION
        $chargesExploitation = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 'CHAREXPL'
        ], $dateDebut, $dateFin);

        // CALCUL DE LA MARGE D'EXPLOITATION
        $margeExploitation = 0;

        if ($produitsExploitation > 0) {
            $margeExploitation = (($produitsExploitation - $chargesExploitation) / $produitsExploitation) * 100;
        }

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Marge d\'exploitation', $margeExploitation);

        return response()->json([
            'success' => true,
            'marge_exploitation' => [
                'valeur' => round($margeExploitation, 2),
                'unite' => '%',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'produits_exploitation' => $produitsExploitation,
                'charges_exploitation' => $chargesExploitation,
                'resultat_exploitation' => $produitsExploitation - $chargesExploitation
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'description' => 'Capacité de l\'école à dégager une marge sur son activité.',
            'formule' => $interpretationData['formule']
        ]);
    }

    /**
     * Récupère l'interprétation depuis la table interpretation_indicateur
     */
private function getInterpretation($libelleIndicateur, $valeur)
{
    $indicateur = IndicateurAnalytique::where('libelle', $libelleIndicateur)->first();
    
    if (!$indicateur) {
        return [
            'interpretation' => 'Interprétation non disponible',
            'niveau_alerte' => null,
            'formule' => 'Formule non disponible'
        ];
    }

    $interpretation = InterpretationIndicateur::with('niveauAlerte')
        ->where('id_indicateur_analytique', $indicateur->id_indicateur_analytique)
        ->where('valeur', '<=', $valeur)
        ->orderBy('valeur', 'desc')
        ->first();

    if (!$interpretation) {
        return [
            'interpretation' => 'Aucune interprétation trouvée pour cette valeur',
            'niveau_alerte' => null,
            'formule' => $indicateur->formule ?? 'Formule non définie'
        ];
    }

    return [
        'interpretation' => $interpretation->interpretation,
        'niveau_alerte' => $interpretation->niveauAlerte,
        'formule' => $indicateur->formule ?? 'Formule non définie'
    ];
}
}