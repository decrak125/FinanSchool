<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Http\Controllers\calcul\UtilesController;
use App\Models\ParametresAnalytique\IndicateurAnalytique;
use App\Models\ParametresAnalytique\InterpretationIndicateur;
use App\Models\exercice\ExerciceComptable;
use App\Models\EffectifEleve;

class IndicateurPedagogiqueController extends Controller
{
    /**
     * Helper: Récupère l'effectif pour un exercice donné
     * Si l'exercice n'a pas d'effectif, utilise l'effectif de l'exercice actuellement ouvert
     */
    private function getEffectifForExercice($dateDebut, $dateFin)
    {
        // Trouver l'exercice comptable par dates
        $exercice = ExerciceComptable::where('Date_debut', $dateDebut)
            ->where('Date_fin', $dateFin)
            ->first();

        if (!$exercice) {
            return $this->getEffectifFromCurrentOpenExercice();
        }

        // Récupérer l'effectif pour cet exercice
        $effectif = EffectifEleve::where('Id_Exercice_comptable', $exercice->Id_Exercice_comptable)
            ->first();

        // Si l'exercice a un effectif, le retourner
        if ($effectif) {
            return $effectif->nombre_eleves;
        }

        // Sinon, chercher l'effectif de l'exercice actuellement ouvert
        return $this->getEffectifFromCurrentOpenExercice();
    }

    /**
     * Helper: Récupère l'effectif de l'exercice actuellement ouvert
     */
    private function getEffectifFromCurrentOpenExercice()
    {
        // Trouver l'exercice actuellement ouvert (statut = OUVERT)
        $currentExercice = ExerciceComptable::where('Statut', 'OUVERT')
            ->orderBy('Date_debut', 'desc')
            ->first();

        if (!$currentExercice) {
            // Si aucun exercice ouvert, chercher le dernier exercice (PROVISOIRE ou CLOTURE)
            $currentExercice = ExerciceComptable::orderBy('Date_debut', 'desc')
                ->first();
        }

        if (!$currentExercice) {
            return null;
        }

        // Récupérer l'effectif de l'exercice actuel
        $effectif = EffectifEleve::where('Id_Exercice_comptable', $currentExercice->Id_Exercice_comptable)
            ->first();

        return $effectif ? $effectif->nombre_eleves : null;
    }

    /**
     * Helper: Récupère l'effectif ou retourne une erreur avec suggestion
     */
    private function getEffectifOrError($dateDebut, $dateFin)
    {
        $effectifEleves = $this->getEffectifForExercice($dateDebut, $dateFin);
        
        if ($effectifEleves === null) {
            // Trouver l'exercice actuel pour le message d'erreur
            $currentExercice = ExerciceComptable::where('Statut', 'OUVERT')
                ->orderBy('Date_debut', 'desc')
                ->first();
            
            if (!$currentExercice) {
                $currentExercice = ExerciceComptable::orderBy('Date_debut', 'desc')->first();
            }
            
            $message = 'Aucun effectif trouvé. ';
            
            if ($currentExercice) {
                $currentExerciceId = $currentExercice->Id_Exercice_comptable;
                $hasEffectif = EffectifEleve::where('Id_Exercice_comptable', $currentExerciceId)->exists();
                
                if ($hasEffectif) {
                    $message .= "L'effectif de l'exercice actuel (ID: {$currentExerciceId}) sera utilisé.";
                } else {
                    $message .= "Veuillez d'abord créer un effectif pour un exercice.";
                }
            }
            
            return [
                'success' => false,
                'message' => $message
            ];
        }

        if ($effectifEleves <= 0) {
            return [
                'success' => false,
                'message' => 'L\'effectif doit être supérieur à 0 pour calculer cet indicateur.'
            ];
        }

        return [
            'success' => true,
            'effectif' => $effectifEleves
        ];
    }

    /**
     * Calcule le Coût de Fonctionnement par élève
     */
    public function calculCoutFonctionnementParEleve(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // Récupérer l'effectif
        $effectifResult = $this->getEffectifOrError($dateDebut, $dateFin);
        
        if (!$effectifResult['success']) {
            return response()->json($effectifResult, 400);
        }

        $effectifEleves = $effectifResult['effectif'];

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
            'definition' => 'Donne le "prix de revient" moyen d\'un élève. KPI de base essentiel.',
            'source_effectif' => $this->getEffectifSourceInfo($dateDebut, $dateFin, $effectifEleves)
        ]);
    }

    /**
     * Calcule le Chiffre d'Affaires par Élève
     */
    public function calculChiffreAffairesParEleve(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // Récupérer l'effectif
        $effectifResult = $this->getEffectifOrError($dateDebut, $dateFin);
        
        if (!$effectifResult['success']) {
            return response()->json($effectifResult, 400);
        }

        $effectifEleves = $effectifResult['effectif'];

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
            'definition' => 'Montant moyen des ressources générées par élève.',
            'source_effectif' => $this->getEffectifSourceInfo($dateDebut, $dateFin, $effectifEleves)
        ]);
    }

    /**
     * Calcule la Marge par Élève
     */
    public function calculMargeParEleve(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // Récupérer l'effectif
        $effectifResult = $this->getEffectifOrError($dateDebut, $dateFin);
        
        if (!$effectifResult['success']) {
            return response()->json($effectifResult, 400);
        }

        $effectifEleves = $effectifResult['effectif'];

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
            'definition' => 'Marge nette dégagée par élève. Le moteur de la rentabilité.',
            'source_effectif' => $this->getEffectifSourceInfo($dateDebut, $dateFin, $effectifEleves)
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
    
    // Masse salariale enseignante via code analytique SAL01
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
     * Calcule tous les indicateurs pédagogiques en une seule requête
     */
    public function calculTousIndicateursPedagogiques(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut',
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // Récupérer l'effectif
        $effectifResult = $this->getEffectifOrError($dateDebut, $dateFin);
        
        if (!$effectifResult['success']) {
            return response()->json($effectifResult, 400);
        }

        $effectifEleves = $effectifResult['effectif'];

        $masseSalarialeEnseignante = UtilesController::SommeCodeAnalytique($dateDebut, $dateFin, 'SAL01');
        
        // Calcul de tous les indicateurs
        $coutFonctionnement = $this->calculCoutFonctionnementParEleveDirect($dateDebut, $dateFin, $effectifEleves);
        $chiffreAffaires = $this->calculChiffreAffairesParEleveDirect($dateDebut, $dateFin, $effectifEleves);
        $partMasseSalariale = $this->calculPartMasseSalarialeEnseignanteDirect($dateDebut, $dateFin, $masseSalarialeEnseignante);
        $margeParEleve = $this->calculMargeParEleveDirect($dateDebut, $dateFin, $effectifEleves);

        // Récupérer les interprétations
        $interpretationCout = $this->getInterpretation('Coût de Fonctionnement par élève', $coutFonctionnement);
        $interpretationCA = $this->getInterpretation('Chiffre d\'Affaires par élève', $chiffreAffaires);
        $interpretationMasse = $this->getInterpretation('Part de la Masse Salariale Enseignante', $partMasseSalariale);
        $interpretationMarge = $this->getInterpretation('Marge par élève', $margeParEleve);

        return response()->json([
            'success' => true,
            'indicateurs_pedagogiques' => [
                'cout_fonctionnement_par_eleve' => [
                    'valeur' => round($coutFonctionnement, 2),
                    'unite' => '€',
                    'interpretation' => $interpretationCout['interpretation'],
                    'niveau_alerte' => $interpretationCout['niveau_alerte']
                ],
                'chiffre_affaires_par_eleve' => [
                    'valeur' => round($chiffreAffaires, 2),
                    'unite' => '€',
                    'interpretation' => $interpretationCA['interpretation'],
                    'niveau_alerte' => $interpretationCA['niveau_alerte']
                ],
                'part_masse_salariale_enseignante' => [
                    'valeur' => round($partMasseSalariale, 2),
                    'unite' => '%',
                    'interpretation' => $interpretationMasse['interpretation'],
                    'niveau_alerte' => $interpretationMasse['niveau_alerte']
                ],
                'marge_par_eleve' => [
                    'valeur' => round($margeParEleve, 2),
                    'unite' => '€',
                    'interpretation' => $interpretationMarge['interpretation'],
                    'niveau_alerte' => $interpretationMarge['niveau_alerte']
                ]
            ],
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'parametres' => [
                'effectif_eleves' => $effectifEleves,
                'masse_salariale_enseignante' => $masseSalarialeEnseignante
            ],
            'source_effectif' => $this->getEffectifSourceInfo($dateDebut, $dateFin, $effectifEleves)
        ]);
    }

    /**
     * Helper: Retourne les informations sur la source de l'effectif utilisé
     */
    private function getEffectifSourceInfo($dateDebut, $dateFin, $effectifValue)
    {
        // Chercher l'exercice demandé
        $requestedExercice = ExerciceComptable::where('Date_debut', $dateDebut)
            ->where('Date_fin', $dateFin)
            ->first();

        if (!$requestedExercice) {
            return [
                'type' => 'unknown',
                'message' => 'Exercice demandé non trouvé'
            ];
        }

        // Vérifier si l'exercice demandé a un effectif
        $requestedEffectif = EffectifEleve::where('Id_Exercice_comptable', $requestedExercice->Id_Exercice_comptable)->first();
        
        if ($requestedEffectif && $requestedEffectif->nombre_eleves == $effectifValue) {
            return [
                'type' => 'requested_exercice',
                'exercice_id' => $requestedExercice->Id_Exercice_comptable,
                'annee_fiscale' => $requestedExercice->Annee_fiscale,
                'message' => "Effectif utilisé depuis l'exercice demandé"
            ];
        }

        // Sinon, trouver de quel exercice vient l'effectif
        $effectifRecord = EffectifEleve::where('nombre_eleves', $effectifValue)
            ->with('exerciceComptable')
            ->first();

        if ($effectifRecord) {
            return [
                'type' => 'current_open_exercice',
                'exercice_id' => $effectifRecord->Id_Exercice_comptable,
                'annee_fiscale' => $effectifRecord->exerciceComptable->Annee_fiscale,
                'statut' => $effectifRecord->exerciceComptable->Statut,
                'message' => "Effectif utilisé depuis l'exercice actuellement ouvert ({$effectifRecord->exerciceComptable->Annee_fiscale})"
            ];
        }

        return [
            'type' => 'unknown',
            'message' => 'Source de l\'effectif inconnue'
        ];
    }

    /**
     * Méthodes internes pour les calculs directs
     */
    private function calculCoutFonctionnementParEleveDirect($dateDebut, $dateFin, $effectifEleves)
    {
        $chargesExploitation = UtilesController::calculerTotalCategorieGroupe([
            'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 'AMORTPROV'
        ], $dateDebut, $dateFin);

        return $effectifEleves > 0 ? $chargesExploitation / $effectifEleves : 0;
    }

    private function calculChiffreAffairesParEleveDirect($dateDebut, $dateFin, $effectifEleves)
    {
        $produitsExploitation = UtilesController::calculerTotalCategorieGroupe([
            'CA', 'PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP', 'REPRISEPROV'
        ], $dateDebut, $dateFin);

        return $effectifEleves > 0 ? $produitsExploitation / $effectifEleves : 0;
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
        return $effectifEleves > 0 ? $resultatNet / $effectifEleves : 0;
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