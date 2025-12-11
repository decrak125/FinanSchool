<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\calcul\UtilesController;
use App\Models\ParametresAnalytique\IndicateurAnalytique;
use App\Models\ParametresAnalytique\InterpretationIndicateur;
use App\Http\Controllers\general\BilanActifController;
use App\Http\Controllers\general\BilanPassifController;


class IndicateurLiquiditeController extends Controller
{
    /**
     * Calcule le Ratio de liquidité générale
     * Formule : Actif circulant / Passif à court terme
     */
    public function calculRatioLiquiditeGenerale(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $bilanActif = BilanActifController::getBilanActif($dateDebut, $dateFin);
        $bilanPassif = BilanPassifController::getBilanPassif($dateDebut, $dateFin);
        // ACTIF CIRCULANT
        $actifCirculant = $bilanActif['structure'][19]['net'] + $bilanActif['structure'][18]['net'];

        // PASSIF À COURT TERME
        $passifCourtTerme = $bilanPassif['structure'][17]['montant'];
        // CALCUL DU RATIO
        $ratio = 0;
        $interpretation = "Non définie";
        $niveauAlerte = null;
        $interpretationData = $this->getInterpretation('Ratio de liquidité générale', $ratio);
        $formule = $interpretationData['formule'];

        if ($passifCourtTerme > 0) {
            $ratio = ($actifCirculant / $passifCourtTerme);
            $interpretationData = $this->getInterpretation('Ratio de liquidité générale', $ratio);
            // Récupérer l'interprétation depuis la table
            // $interpretationData = $this->getInterpretation('Ratio de liquidité générale', $ratio);
            $interpretation = $interpretationData['interpretation'];
            $niveauAlerte = $interpretationData['niveau_alerte'];
            $formule = $interpretationData['formule'];
        }

        return response()->json([
            'success' => true,
            'ratio_liquidite_generale' => [
                'valeur' => round($ratio, 2),
                'unite' =>'%',
                'interpretation' => $interpretation,
                'niveau_alerte' => $niveauAlerte,
                'seuil_reference' => "> 1 indique une bonne solvabilité à court terme"
            ],
            'details_calcul' => [
                'actif_circulant' => $actifCirculant,
                'passif_court_terme' => $passifCourtTerme
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $formule,
            'definition' => 'Mesure la capacité à honorer les dettes à court terme'
        ]);
    }

    /**
     * Calcule la Trésorerie Nette
     * Formule : Solde des comptes de trésorerie
     */
    public function calculTresorerieNette(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $encaissement = IndicateurLiquiditeController::getTresorerieNette($dateDebut, $dateFin);
        // SOLDE DES COMPTES DE TRÉSORERIE (Comptes 512 et 519)
        $tresorerieNette = $encaissement - UtilesController::calculerTotalCategorieGroupe(['DETTECT', 'DECOUV'], $dateDebut, $dateFin);
        
        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Trésorerie Nette', $tresorerieNette);
        
        return response()->json([
            'success' => true,
            'tresorerie_nette' => [
                'valeur' => round($tresorerieNette, 2),
                'unite' => 'Ar',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'comptes_tresorerie' => [
                    'banque' => $encaissement,
                    'decouverts' => UtilesController::calculerTotalCategorieGroupe(['DETTECT', 'DECOUV'], $dateDebut, $dateFin)
                ]
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Solde de trésorerie sur la période'
        ]);
    }

    public static function getTresorerieNette($dateDebut, $dateFin)
{
    return DB::table('vue_balance_generale')
        ->whereRaw('code_sous_compte::NUMERIC BETWEEN 500000 AND 599999')
        ->whereBetween('date_mouvement', [$dateDebut, $dateFin])
        ->selectRaw('SUM(total_debit - total_credit) as tresorerie_nette')
        ->value('tresorerie_nette') ?? 0;
}
    /**
     * Calcule le solde net des comptes de trésorerie
     */
    private function calculerSoldeTresorerie($dateDebut, $dateFin)
    {
        // Solde des comptes banque (positif = avoir, négatif = découvert)
        $soldeBanque = UtilesController::calculerTotalCategorieGroupe(['TRESO'], $dateDebut, $dateFin);
        $soldeDecouverts = UtilesController::calculerTotalCategorieGroupe(['DETTECT'], $dateDebut, $dateFin);

        return $soldeBanque + $soldeDecouverts;
    }

    /**
     * Calcule le Besoin en Fonds de Roulement (BFR)
     * Formule : (Stocks + Créances clients) - Dettes fournisseurs
     */
    public function calculBFR(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // STOCKS
        $stocks = UtilesController::calculerTotalCategorieGroupe(['STOCKS'], $dateDebut, $dateFin);

        // CRÉANCES CLIENTS
        $creancesClients = UtilesController::calculerTotalCategorieGroupe(['CLIENTS'], $dateDebut, $dateFin);

        // DETTES FOURNISSEURS
        $dettesFournisseurs = UtilesController::calculerTotalCategorieGroupe(['FOURN'], $dateDebut, $dateFin);

        // CALCUL DU BFR
        $bfr = ($stocks + $creancesClients) - $dettesFournisseurs;
        
        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Besoin en fonds de roulement (BFR)', $bfr);

        return response()->json([
            'success' => true,
            'bfr' => [
                'valeur' => round($bfr, 2),
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'stocks' => $stocks,
                'creances_clients' => $creancesClients,
                'dettes_fournisseurs' => $dettesFournisseurs,
                'actif_circulant_exploitation' => $stocks + $creancesClients
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Permet d\'évaluer le besoin financier d\'exploitation'
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