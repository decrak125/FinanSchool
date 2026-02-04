<?php

namespace App\Services;

use App\Models\exercice\ExerciceComptable;
use App\Http\Controllers\Analyse\DiagnosticControllerUnifie;
use App\Http\Controllers\Analyse\CoutEtProfitController;

class ExportDiagnosticDataService
{
    protected $diagnosticController;
    protected $coutProfitController;
    
    public function __construct()
    {
        $this->diagnosticController = new DiagnosticControllerUnifie();
        $this->coutProfitController = new CoutEtProfitController();
    }
    
    /**
     * Prépare toutes les données pour l'export
     */
    public function preparerDonneesExport($anneeExercice)
    {
        // 1. Récupérer l'exercice comptable
        $exercice = ExerciceComptable::where('Annee_fiscale', $anneeExercice)
            ->orWhere('Annee_fiscale', 'LIKE', '%' . $anneeExercice . '%')
            ->first();
        
        if (!$exercice) {
            throw new \Exception("Aucun exercice comptable trouvé pour l'année : " . $anneeExercice);
        }
        
        $dateDebut = $exercice->Date_debut;
        $dateFin = $exercice->Date_fin;
        
        // 2. Récupérer les données
        $request = new \Illuminate\Http\Request([
            'date_start' => $dateDebut,
            'date_end' => $dateFin
        ]);
        
        $coutProfitData = $this->coutProfitController->AnalyseCoutEtProfit($request);
        $coutProfitData = json_decode($coutProfitData->getContent(), true);
        
        $diagnosticData = $this->diagnosticController->getDashboardCompletLocal($dateDebut, $dateFin);
        
        // 3. Organiser les données pour l'export
        return [
            'metadata' => [
                'annee_exercice' => $anneeExercice,
                'date_periode' => $dateDebut . ' au ' . $dateFin,
                'date_generation' => now()->format('d/m/Y H:i'),
                'exercice' => [
                    'id' => $exercice->Id_Exercice_comptable,
                    'statut' => $exercice->Statut,
                    'annee_fiscale' => $exercice->Annee_fiscale,
                    'date_debut' => $dateDebut,
                    'date_fin' => $dateFin
                ]
            ],
            'tableau_couts_profits' => $this->preparerTableauCoutsProfits($coutProfitData),
            'tableau_indicateurs' => $this->preparerTableauIndicateurs($diagnosticData),
            'donnees_brutes' => [
                'couts_profits' => $coutProfitData,
                'diagnostic' => $diagnosticData
            ]
        ];
    }
    
    /**
     * Préparer le tableau des coûts et profits
     */
    private function preparerTableauCoutsProfits($coutProfitData)
    {
        $centres = [];
        $chargesParCentre = [];
        $produitsParCentre = [];
        
        // Organiser par centre
        foreach ($coutProfitData as $item) {
            $centreId = $item['id_centre'];
            $centreNom = $item['centre'];
            $type = $item['id_type']; // 1 = charges, 2 = produits
            $montant = $item['montant_ventile'];
            
            if (!isset($centres[$centreId])) {
                $centres[$centreId] = [
                    'id' => $centreId,
                    'nom' => $centreNom,
                    'charges' => 0,
                    'produits' => 0,
                    'marge' => 0,
                    'pourcentage_marge' => 0
                ];
            }
            
            if ($type == 1) { // Charges
                $centres[$centreId]['charges'] += $montant;
            } elseif ($type == 2) { // Produits
                $centres[$centreId]['produits'] += $montant;
            }
        }
        
        // Calculer les marges
        foreach ($centres as &$centre) {
            $centre['marge'] = $centre['produits'] - $centre['charges'];
            $centre['pourcentage_marge'] = $centre['produits'] > 0 ? 
                round(($centre['marge'] / $centre['produits']) * 100, 2) : 0;
        }
        
        // Trier par marge décroissante
        usort($centres, function($a, $b) {
            return $b['marge'] <=> $a['marge'];
        });
        
        // Calculer les totaux
        $totaux = [
            'charges' => array_sum(array_column($centres, 'charges')),
            'produits' => array_sum(array_column($centres, 'produits')),
            'marge' => array_sum(array_column($centres, 'marge'))
        ];
        
        return [
            'lignes' => $centres,
            'totaux' => $totaux,
            'colonnes' => [
                ['key' => 'nom', 'label' => 'Centre Analytique', 'width' => '200px'],
                ['key' => 'charges', 'label' => 'Charges (Ar)', 'type' => 'montant', 'align' => 'right'],
                ['key' => 'produits', 'label' => 'Produits (Ar)', 'type' => 'montant', 'align' => 'right'],
                ['key' => 'marge', 'label' => 'Marge (Ar)', 'type' => 'montant', 'align' => 'right'],
                ['key' => 'pourcentage_marge', 'label' => 'Marge (%)', 'type' => 'pourcentage', 'align' => 'right']
            ]
        ];
    }
    
    /**
     * Préparer le tableau des indicateurs
     */
    private function preparerTableauIndicateurs($diagnosticData)
    {
        $indicateurs = [];
        
        if (!isset($diagnosticData['aspects'])) {
            return [
                'lignes' => [],
                'colonnes' => [],
                'groupes' => []
            ];
        }
        
        $aspects = $diagnosticData['aspects'];
        
        // Fonction pour ajouter un indicateur
        $ajouterIndicateur = function($aspect, $cle, $data, $nomCustom = null) use (&$indicateurs) {
            if (isset($data[$cle])) {
                $indic = $data[$cle];
                $indicateurs[] = [
                    'aspect' => $aspect,
                    'nom' => $nomCustom ?? $cle,
                    'valeur' => $indic['valeur'] ?? 0,
                    'unite' => $indic['unite'] ?? '',
                    'interpretation' => $indic['interpretation'] ?? '',
                    'niveau_alerte' => $indic['niveau_alerte'] ?? null,
                    'formule' => $indic['formule'] ?? '',
                    'definition' => $indic['definition'] ?? ''
                ];
            }
        };
        
        // RENTABILITÉ
        if (isset($aspects['rentabilite']) && $aspects['rentabilite']['success']) {
            $rentabilite = $aspects['rentabilite'];
            $ajouterIndicateur('Rentabilité', 'marge_brute', $rentabilite, 'Marge brute');
            $ajouterIndicateur('Rentabilité', 'marge_nette', $rentabilite, 'Marge nette');
            $ajouterIndicateur('Rentabilité', 'roe', $rentabilite, 'ROE (Return on Equity)');
            $ajouterIndicateur('Rentabilité', 'roa', $rentabilite, 'ROA (Return on Assets)');
        }
        
        // SOLVABILITÉ
        if (isset($aspects['solvabilite']) && $aspects['solvabilite']['success']) {
            $solvabilite = $aspects['solvabilite'];
            $ajouterIndicateur('Solvabilité', 'autonomie_financiere', $solvabilite, 'Autonomie financière');
            $ajouterIndicateur('Solvabilité', 'ratio_endettement', $solvabilite, 'Ratio d\'endettement');
            $ajouterIndicateur('Solvabilité', 'capacite_remboursement', $solvabilite, 'Capacité de remboursement');
        }
        
        // LIQUIDITÉ
        if (isset($aspects['liquidite']) && $aspects['liquidite']['success']) {
            $liquidite = $aspects['liquidite'];
            $ajouterIndicateur('Liquidité', 'tresorerie_nette', $liquidite, 'Trésorerie nette');
            $ajouterIndicateur('Liquidité', 'ratio_liquidite_generale', $liquidite, 'Ratio de liquidité générale');
            $ajouterIndicateur('Liquidité', 'bfr', $liquidite, 'Besoin en fonds de roulement (BFR)');
        }
        
        // PÉDAGOGIQUE
        if (isset($aspects['pedagogique']) && $aspects['pedagogique']['success']) {
            $pedagogique = $aspects['pedagogique'];
            if (isset($pedagogique['indicateurs_pedagogiques'])) {
                $pedago = $pedagogique['indicateurs_pedagogiques'];
                $ajouterIndicateur('Pédagogique', 'cout_fonctionnement_par_eleve', $pedago, 'Coût de fonctionnement par élève');
                $ajouterIndicateur('Pédagogique', 'chiffre_affaires_par_eleve', $pedago, 'Chiffre d\'affaires par élève');
                $ajouterIndicateur('Pédagogique', 'part_masse_salariale_enseignante', $pedago, 'Part de la masse salariale enseignante');
                $ajouterIndicateur('Pédagogique', 'marge_par_eleve', $pedago, 'Marge par élève');
            }
        }
        
        // Groupes par aspect
        $groupes = [
            'Rentabilité' => [],
            'Solvabilité' => [],
            'Liquidité' => [],
            'Pédagogique' => []
        ];
        
        foreach ($indicateurs as $indic) {
            $groupes[$indic['aspect']][] = $indic;
        }
        
        return [
            'lignes' => $indicateurs,
            'colonnes' => [
                ['key' => 'aspect', 'label' => 'Aspect', 'width' => '120px'],
                ['key' => 'nom', 'label' => 'Indicateur', 'width' => '200px'],
                ['key' => 'valeur', 'label' => 'Valeur', 'type' => 'valeur', 'align' => 'right'],
                ['key' => 'interpretation', 'label' => 'Interprétation', 'width' => '250px'],
                ['key' => 'niveau_alerte', 'label' => 'Niveau', 'type' => 'niveau', 'align' => 'center']
            ],
            'groupes' => $groupes
        ];
    }
    
    /**
     * Formatage des nombres pour affichage
     */
    public function formaterMontant($montant)
    {
        return number_format($montant, 2, ',', ' ');
    }
    
    /**
     * Formatage des pourcentages
     */
    public function formaterPourcentage($valeur)
    {
        return number_format($valeur, 2, ',', ' ') . ' %';
    }
}