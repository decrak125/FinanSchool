<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\calcul\UtilesController;
use App\Http\Controllers\general\CompteResultatNatureController;
use App\Models\ParametresAnalytique\IndicateurAnalytique;
use App\Models\ParametresAnalytique\InterpretationIndicateur;
use App\Http\Controllers\general\BilanActifController;
use App\Http\Controllers\general\BilanPassifController;


class IndicateurRentabiliteController extends Controller
{


    /**
     * Compare la marge brute sur deux périodes
     */
    public function comparerMargeBrute(Request $request)
    {
        $request->validate([
            'periode1_debut' => 'required|date',
            'periode1_fin' => 'required|date|after_or_equal:periode1_debut',
            'periode2_debut' => 'required|date',
            'periode2_fin' => 'required|date|after_or_equal:periode2_debut'
        ]);

        $margePeriode1 = $this->getMargeBruteDirect($request->periode1_debut, $request->periode1_fin);
        $margePeriode2 = $this->getMargeBruteDirect($request->periode2_debut, $request->periode2_fin);

        $evolution = $margePeriode2 - $margePeriode1;
        $tauxEvolution = $margePeriode1 > 0 ? ($evolution / $margePeriode1) * 100 : 0;

        return response()->json([
            'success' => true,
            'comparaison' => [
                'periode1' => [
                    'debut' => $request->periode1_debut,
                    'fin' => $request->periode1_fin,
                    'marge_brute' => round($margePeriode1, 2) . '%'
                ],
                'periode2' => [
                    'debut' => $request->periode2_debut,
                    'fin' => $request->periode2_fin,
                    'marge_brute' => round($margePeriode2, 2) . '%'
                ],
                'evolution' => [
                    'valeur_absolue' => round($evolution, 2) . '%',
                    'taux_evolution' => round($tauxEvolution, 2) . '%',
                    'interpretation' => $evolution >= 0 ? 'Amélioration' : 'Dégradation'
                ]
            ]
        ]);
    }

    /**
     * Version simplifiée pour usage interne
     */
    private function getMargeBruteDirect($dateDebut, $dateFin)
    {
        $chiffreAffaires = calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin);
        $coutVentes = calculerTotalCategorieGroupe(['ACHATCONSOM'], $dateDebut, $dateFin);

        if ($chiffreAffaires > 0) {
            return (($chiffreAffaires - $coutVentes) / $chiffreAffaires);
        }

        return 0;
    }

    /**
     * Version statique pour usage externe
     */
    public static function getMargeBrute($dateDebut, $dateFin)
    {
        $controller = new self();
        return $controller->getMargeBruteDirect($dateDebut, $dateFin);
    }


    /**
     * Calcule le résultat d'exploitation (Produits d'exploitation - Charges d'exploitation)
     */
    private function calculerResultatExploitation($dateDebut, $dateFin)
    {
        // PRODUITS D'EXPLOITATION
        $produitsExploitation = UtilesController::calculerTotalCategorieGroupe([
            'CA',           // Chiffre d'affaires (700-709)
            'PRODSTOCK',    // Production stockée (710-715)
            'PRODIMMO',     // Production immobilisée (720-729)
            'SUBVENT',      // Subventions d'exploitation (740-749)
            'AUTPRODOP',    // Autres produits d'exploitation (750-759)
            'REPRISEPROV'   // Reprises sur provisions (780-789)
        ], $dateDebut, $dateFin);

        // CHARGES D'EXPLOITATION
        $chargesExploitation = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM',  // Achats consommés (601-609)
            'SERVEXT',      // Services extérieurs (611-619)
            'CHPERS',       // Charges de personnel (620-629)
            'AUTCHOP',      // Autres charges d'exploitation (630-639)
            'AMORTPROV'     // Dotations aux amortissements/provisions (640-649)
        ], $dateDebut, $dateFin);

        return $produitsExploitation - $chargesExploitation;
    }

    /**
     * Calcule la Marge Brute
     * Formule : (Chiffre d'affaires – Coût des ventes) / Chiffre d'affaires × 100
     */
    public function calculMargeBrute(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // CHIFFRE D'AFFAIRES (Comptes 700-709)
        $chiffreAffaires = UtilesController::calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin);

        // COÛT DES VENTES (Achats consommés - Comptes 601-609)
        $coutVentes = UtilesController::calculerTotalCategorieGroupe(['ACHATCONSOM'], $dateDebut, $dateFin);

        // CALCUL DE LA MARGE BRUTE
        $margeBrute = 0;

        if ($chiffreAffaires > 0) {
            $margeBrute = (($chiffreAffaires - $coutVentes) / $chiffreAffaires) * 100;
        }

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Marge brute', $margeBrute);

        return response()->json([
            'success' => true,
            'marge_brute' => [
                'valeur' => round($margeBrute, 2),
                'unite' => '%',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'chiffre_affaires' => $chiffreAffaires,
                'cout_ventes' => $coutVentes,
                'marge_absolue' => $chiffreAffaires - $coutVentes
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'comptes_utilises' => [
                'chiffre_affaires' => 'Comptes 700-709 (CA)',
                'cout_ventes' => 'Comptes 601-609 (ACHATCONSOM)'
            ]
        ]);
    }

    /**
     * Calcule la Marge d'exploitation (EBIT)
     * Formule : Résultat d'exploitation / Chiffre d'affaires × 100
     */
    public function calculMargeExploitationEBIT(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // RÉSULTAT D'EXPLOITATION (Produits d'exploitation - Charges d'exploitation)
        $resultatExploitation = $this->calculerResultatExploitation($dateDebut, $dateFin);

        // CHIFFRE D'AFFAIRES (Comptes 700-709)
        $chiffreAffaires = UtilesController::calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin);

        // CALCUL DE LA MARGE D'EXPLOITATION (EBIT)
        $margeExploitation = 0;

        if ($chiffreAffaires > 0) {
            $margeExploitation = ($resultatExploitation / $chiffreAffaires) * 100;
        }

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Marge d\'exploitation (EBIT)', $margeExploitation);

        return response()->json([
            'success' => true,
            'marge_exploitation_ebit' => [
                'valeur' => round($margeExploitation, 2),
                'unite' => '%',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'resultat_exploitation' => $resultatExploitation,
                'chiffre_affaires' => $chiffreAffaires
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Mesure la performance des activités principales de l\'établissement'
        ]);
    }

    /**
     * Calcule la Marge nette
     * Formule : Résultat net / Chiffre d'affaires × 100
     */
    public function calculMargeNette(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $resultatNet = CompteResultatNatureController::calculerCompteResultat($dateDebut, $dateFin);

        // RÉSULTAT NET (après toutes les charges et produits)
        $resultatNet = $resultatNet['structure'][29]['montant'];

        // CHIFFRE D'AFFAIRES (Comptes 700-709)
        $chiffreAffaires = UtilesController::calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin);

        // CALCUL DE LA MARGE NETTE
        $margeNette = 0;

        if ($chiffreAffaires > 0) {
            $margeNette = ($resultatNet / $chiffreAffaires) * 100;
        }

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Marge nette', $margeNette);

        return response()->json([
            'success' => true,
            'marge_nette' => [
                'valeur' => round($margeNette, 2),
                'unite' => '%',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'resultat_net' => $resultatNet,
                'chiffre_affaires' => $chiffreAffaires
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Montre le bénéfice final par euro de ventes'
        ]);
    }

    /**
     * Calcule le ROE (Return on Equity)
     * Formule : Résultat net / Capitaux propres × 100
     */
    public function calculROE(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $bilanPassif = BilanPassifController::getBilanPassif($dateDebut, $dateFin);
        $resultatNet = CompteResultatNatureController::calculerCompteResultat($dateDebut, $dateFin);
        
        // RÉSULTAT NET
        $resultatNet = $resultatNet['structure'][29]['montant'];

        // CAPITAUX PROPRES (Comptes 100-149)
        $capitauxPropres = $bilanPassif['structure'][11]['montant'];

        // CALCUL DU ROE
        $roe = 0;

        if ($capitauxPropres > 0) {
            $roe = ($resultatNet / $capitauxPropres) * 100;
        }

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('ROE (Return on Equity)', $roe);

        return response()->json([
            'success' => true,
            'roe' => [
                'valeur' => round($roe, 2),
                'unite' => '%',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'resultat_net' => $resultatNet,
                'capitaux_propres' => $capitauxPropres
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Rendement des fonds propres'
        ]);
    }

    /**
     * Calcule le ROA (Return on Assets)
     * Formule : Résultat net / Total actif × 100
     */
    public function calculROA(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $bilanActif = BilanActifController::getBilanActif($request->date_debut, $request->date_fin);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $resultatNet = CompteResultatNatureController::calculerCompteResultat($dateDebut, $dateFin);
        
        // RÉSULTAT NET
        $resultatNet = $resultatNet['structure'][29]['montant'];

        // TOTAL ACTIF (Somme de tous les actifs)
        $totalActif = $bilanActif['structure'][21]['brut'];

        // CALCUL DU ROA
        $roa = 0;

        if ($totalActif > 0) {
            $roa = ($resultatNet / $totalActif) * 100;
        }

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('ROA (Return on Assets)', $roa);

        return response()->json([
            'success' => true,
            'roa' => [
                'valeur' => round($roa, 2),
                'unite' => '%',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'resultat_net' => $resultatNet,
                'total_actif' => $totalActif
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Efficacité globale des actifs'
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