<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\calcul\UtilesController;
use App\Models\ParametresAnalytique\IndicateurAnalytique;
use App\Models\ParametresAnalytique\InterpretationIndicateur;

class IndicateurPedagogiqueController extends Controller
{
    /**
     * Calcule le Coût de Fonctionnement par élève
     * Formule : Total des Charges d'Exploitation / Effectif total des élèves
     */
    public function calculCoutFonctionnementParEleve(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut',
            'effectif_eleves' => 'required|numeric|min:1'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $effectifEleves = $request->effectif_eleves;

        // TOTAL DES CHARGES D'EXPLOITATION
        $chargesExploitation = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 'AMORTPROV'
        ], $dateDebut, $dateFin);

        // CALCUL DU COÛT PAR ÉLÈVE
        $coutParEleve = $chargesExploitation / $effectifEleves;

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Coût de Fonctionnement par élève', $coutParEleve);

        return response()->json([
            'success' => true,
            'cout_fonctionnement_par_eleve' => [
                'valeur' => round($coutParEleve, 2),
                'unite' => '€',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'total_charges_exploitation' => $chargesExploitation,
                'effectif_eleves' => $effectifEleves,
                'charges_par_categorie' => [
                    'achats_consommes' => UtilesController::calculerTotalCategorieGroupe(['ACHATCONSOM'], $dateDebut, $dateFin),
                    'services_exterieurs' => UtilesController::calculerTotalCategorieGroupe(['SERVEXT'], $dateDebut, $dateFin),
                    'charges_personnel' => UtilesController::calculerTotalCategorieGroupe(['CHPERS'], $dateDebut, $dateFin),
                    'autres_charges' => UtilesController::calculerTotalCategorieGroupe(['AUTCHOP'], $dateDebut, $dateFin),
                    'dotations_amortissements' => UtilesController::calculerTotalCategorieGroupe(['AMORTPROV'], $dateDebut, $dateFin)
                ]
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Donne le "prix de revient" moyen d\'un élève. KPI de base essentiel.'
        ]);
    }

    /**
     * Calcule le Chiffre d'Affaires par Élève
     * Formule : Total des Produits d'Exploitation / Effectif total des élèves
     */
    public function calculChiffreAffairesParEleve(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut',
            'effectif_eleves' => 'required|numeric|min:1'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $effectifEleves = $request->effectif_eleves;

        // TOTAL DES PRODUITS D'EXPLOITATION
        $produitsExploitation = UtilesController::calculerTotalCategorieGroupe([
            'CA', 'PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP', 'REPRISEPROV'
        ], $dateDebut, $dateFin);

        // CALCUL DU CHIFFRE D'AFFAIRES PAR ÉLÈVE
        $caParEleve = $produitsExploitation / $effectifEleves;

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Chiffre d\'Affaires par élève', $caParEleve);

        return response()->json([
            'success' => true,
            'chiffre_affaires_par_eleve' => [
                'valeur' => round($caParEleve, 2),
                'unite' => '€',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'total_produits_exploitation' => $produitsExploitation,
                'effectif_eleves' => $effectifEleves,
                'produits_par_categorie' => [
                    'chiffre_affaires' => UtilesController::calculerTotalCategorieGroupe(['CA'], $dateDebut, $dateFin),
                    'production_stockee' => UtilesController::calculerTotalCategorieGroupe(['PRODSTOCK'], $dateDebut, $dateFin),
                    'production_immobilisee' => UtilesController::calculerTotalCategorieGroupe(['PRODIMMO'], $dateDebut, $dateFin),
                    'subventions' => UtilesController::calculerTotalCategorieGroupe(['SUBVENT'], $dateDebut, $dateFin),
                    'autres_produits' => UtilesController::calculerTotalCategorieGroupe(['AUTPRODOP'], $dateDebut, $dateFin)
                ]
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Montant moyen des ressources générées par élève.'
        ]);
    }

    /**
     * Calcule la Part de la Masse Salariale Enseignante
     * Formule : (Masse Salariale Enseignante / Total des Charges) * 100
     */
    public function calculPartMasseSalarialeEnseignante(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut',
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $masseSalarialeEnseignante = UtilesController::SommeCodeAnalytique($dateDebut, $dateFin, 'SAL01');

        // TOTAL DES CHARGES
        $totalCharges = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 'AMORTPROV', 'CHARGEFIN', 'CHAREXCEPT'
        ], $dateDebut, $dateFin);

        // CALCUL DE LA PART DE LA MASSE SALARIALE ENSEIGNANTE
        $partMasseSalariale = 0;

        if ($totalCharges > 0) {
            $partMasseSalariale = ($masseSalarialeEnseignante / $totalCharges) * 100;
        }

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Part de la Masse Salariale Enseignante', $partMasseSalariale);

        return response()->json([
            'success' => true,
            'part_masse_salariale_enseignante' => [
                'valeur' => round($partMasseSalariale, 2),
                'unite' => '%',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'masse_salariale_enseignante' => $masseSalarialeEnseignante,
                'total_charges' => $totalCharges,
                'autres_charges' => $totalCharges - $masseSalarialeEnseignante
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Poids du coût des enseignants dans le budget total.'
        ]);
    }

    /**
     * Calcule la Marge par Élève
     * Formule : (Total Produits - Total Charges) / Effectif total des élèves
     */
    public function calculMargeParEleve(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut',
            'effectif_eleves' => 'required|numeric|min:1'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $effectifEleves = $request->effectif_eleves;

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

        // CALCUL DE LA MARGE PAR ÉLÈVE
        $resultatNet = $totalProduits - $totalCharges;
        $margeParEleve = $resultatNet / $effectifEleves;

        // Récupérer l'interprétation depuis la table
        $interpretationData = $this->getInterpretation('Marge par élève', $margeParEleve);

        return response()->json([
            'success' => true,
            'marge_par_eleve' => [
                'valeur' => round($margeParEleve, 2),
                'unite' => '€',
                'interpretation' => $interpretationData['interpretation'],
                'niveau_alerte' => $interpretationData['niveau_alerte']
            ],
            'details_calcul' => [
                'total_produits' => $totalProduits,
                'total_charges' => $totalCharges,
                'resultat_net' => $resultatNet,
                'effectif_eleves' => $effectifEleves
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'formule' => $interpretationData['formule'],
            'definition' => 'Marge nette dégagée par élève. Le moteur de la rentabilité.'
        ]);
    }

    /**
     * Calcule tous les indicateurs pédagogiques en une seule requête
     */
    public function calculTousIndicateursPedagogiques(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut',
            'effectif_eleves' => 'required|numeric|min:1',
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;
        $effectifEleves = $request->effectif_eleves;
        $masseSalarialeEnseignante = UtilesController::calculerTotalCategorieGroupe(['CHPERS'], $dateDebut, $dateFin);
        // Calcul de tous les indicateurs
        $coutFonctionnement = $this->calculCoutFonctionnementParEleveDirect($dateDebut, $dateFin, $effectifEleves);
        $chiffreAffaires = $this->calculChiffreAffairesParEleveDirect($dateDebut, $dateFin, $effectifEleves);
        $partMasseSalariale = $this->calculPartMasseSalarialeEnseignanteDirect($dateDebut, $dateFin, $masseSalarialeEnseignante);
        $margeParEleve = $this->calculMargeParEleveDirect($dateDebut, $dateFin, $effectifEleves);

        return response()->json([
            'success' => true,
            'indicateurs_pedagogiques' => [
                'cout_fonctionnement_par_eleve' => $coutFonctionnement,
                'chiffre_affaires_par_eleve' => $chiffreAffaires,
                'part_masse_salariale_enseignante' => $partMasseSalariale,
                'marge_par_eleve' => $margeParEleve
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'parametres' => [
                'effectif_eleves' => $effectifEleves,
                // 'masse_salariale_enseignante' => $masseSalarialeEnseignante
            ]
        ]);
    }

    /**
     * Méthodes internes pour les calculs directs
     */
    private function calculCoutFonctionnementParEleveDirect($dateDebut, $dateFin, $effectifEleves)
    {
        $chargesExploitation = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 'AMORTPROV'
        ], $dateDebut, $dateFin);

        return $chargesExploitation / $effectifEleves;
    }

    private function calculChiffreAffairesParEleveDirect($dateDebut, $dateFin, $effectifEleves)
    {
        $produitsExploitation = UtilesController::calculerTotalCategorieGroupe([
            'CA', 'PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP', 'REPRISEPROV'
        ], $dateDebut, $dateFin);

        return $produitsExploitation / $effectifEleves;
    }

    private function calculPartMasseSalarialeEnseignanteDirect($dateDebut, $dateFin, $masseSalarialeEnseignante)
    {
        $totalCharges = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 'AMORTPROV', 'CHARGEFIN', 'CHAREXCEPT'
        ], $dateDebut, $dateFin);

        if ($totalCharges > 0) {
            return ($masseSalarialeEnseignante / $totalCharges) * 100;
        }

        return 0;
    }

    private function calculMargeParEleveDirect($dateDebut, $dateFin, $effectifEleves)
    {
        $totalProduits = UtilesController::calculerTotalCategorieGroupe([
            'CA', 'PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP', 
            'PRODFIN', 'PRODEXCEPT', 'REPRISEPROV'
        ], $dateDebut, $dateFin);

        $totalCharges = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 
            'AMORTPROV', 'CHARGEFIN', 'CHAREXCEPT'
        ], $dateDebut, $dateFin);

        $resultatNet = $totalProduits - $totalCharges;
        return $resultatNet / $effectifEleves;
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