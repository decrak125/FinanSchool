<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\calcul\UtilesController;
use App\Models\ParametresAnalytique\IndicateurAnalytique;
use App\Models\ParametresAnalytique\InterpretationIndicateur;
use App\Http\Controllers\general\CompteResultatNatureController;
use App\Http\Controllers\Analyse\IndicateurLiquiditeController;
use App\Http\Controllers\general\BilanPassifController;

class IndicateurSolvabiliteController extends Controller
{
    /**
     * Calcule le Ratio d'endettement
     * Formule : Dettes financières / Capitaux propres
     */
    public function calculRatioEndettement(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $resultatNet = CompteResultatNatureController::calculerCompteResultat($dateDebut, $dateFin);
        $bilanPassif = BilanPassifController::getBilanPassif($dateDebut, $dateFin);
        // RÉSULTAT NET
        $resultatNet = $resultatNet['structure'][29]['montant'];
        // DETTES FINANCIÈRES
        $dettesFinancieres = UtilesController::calculerTotalCategorieGroupe([
            'EMPRUNT'   // Emprunts et dettes financières (160-169)
        ], $dateDebut, $dateFin);

        // CAPITAUX PROPRES
        $capitauxPropres = $bilanPassif['structure'][7]['montant'];

        // CALCUL DU RATIO D'ENDETTEMENT
        $ratio = 0;

        if ($capitauxPropres > 0) {
            $ratio = ($dettesFinancieres / $capitauxPropres) * 100;
        }

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Ratio d\'endettement', $ratio);

        return response()->json([
            'success' => true,
            'ratio_endettement' => [
                'valeur' => round($ratio, 2),
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte'],
                'seuil_reference' => "Plus il est faible, plus la structure est solide"
            ],
            'details_calcul' => [
                'dettes_financieres' => $dettesFinancieres,
                'capitaux_propres' => $capitauxPropres
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Mesure le niveau d\'endettement de l\'établissement'
        ]);
    }

    /**
     * Calcule l'Autonomie financière
     * Formule : Capitaux propres / Total bilan × 100
     */
    public function calculAutonomieFinanciere(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        // CAPITAUX PROPRES
        $bilanPassif = BilanPassifController::getBilanPassif($dateDebut, $dateFin);
        $capitauxPropres = $bilanPassif['structure'][7]['montant'];

        // TOTAL BILAN (Actif total ou Passif total)
        $totalBilan = $bilanPassif['structure'][18]['montant'];

        // CALCUL DE L'AUTONOMIE FINANCIÈRE
        $autonomie = 0;

        if ($totalBilan > 0) {
            $autonomie = ($capitauxPropres / $totalBilan) * 100;
        }

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Autonomie financière', $autonomie);

        return response()->json([
            'success' => true,
            'autonomie_financiere' => [
                'valeur' => round($autonomie, 2),
                'unite' => '%',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte'],
                'seuil_reference' => "> 30% = bonne autonomie financière"
            ],
            'details_calcul' => [
                'capitaux_propres' => $capitauxPropres,
                'total_bilan' => $totalBilan
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Mesure l\'indépendance financière de l\'établissement'
        ]);
    }

    /**
     * Calcule la Capacité de remboursement
     * Formule : Endettement net / CAF (Cash Flow)
     */
    public function calculCapaciteRemboursement(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $tresorerieNette = IndicateurLiquiditeController::getTresorerieNette($dateDebut, $dateFin);
        // ENDETTEMENT NET (Dettes financières)
        $endettementNet = UtilesController::calculerTotalCategorieGroupe([
            'EMPRUNT'   // Emprunts et dettes financières (160-169)
        ], $dateDebut, $dateFin) - $tresorerieNette;

        // CAF (Cash Flow) - Approximation par le résultat net + dotations
        $caf = $this->calculerCAF($dateDebut, $dateFin);

        // CALCUL DE LA CAPACITÉ DE REMBOURSEMENT
        $capaciteRemboursement = 0;

        if ($caf > 0) {
            $capaciteRemboursement = $endettementNet / $caf;
        }

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Capacité de remboursement', $capaciteRemboursement);

        return response()->json([
            'success' => true,
            'capacite_remboursement' => [
                'valeur' => round($capaciteRemboursement, 2),
                'unite' => 'années',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte'],
                'seuil_reference' => "Nombre d'années nécessaires pour rembourser la dette"
            ],
            'details_calcul' => [
                'endettement_net' => $endettementNet,
                'caf' => $caf
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Mesure le temps nécessaire pour rembourser la dette avec la CAF'
        ]);
    }

    /**
     * Calcule la CAF (Cash Flow) approximative
     * Formule simplifiée : Résultat net + Dotations aux amortissements
     */
    private function calculerCAF($dateDebut, $dateFin)
    {
        // RÉSULTAT NET
        $CR = CompteResultatNatureController::calculerCompteResultat($dateDebut, $dateFin);
        
        // RÉSULTAT NET
        $resultatNet = $CR['structure'][29]['montant'];
        
        // DOTATIONS AUX AMORTISSEMENTS ET PROVISIONS
        $dotationsAmortissements = UtilesController::calculerTotalCategorieGroupe(['AMORTPROV'], $dateDebut, $dateFin);

        return $resultatNet + $dotationsAmortissements;
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