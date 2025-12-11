<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Carbon\Carbon;

class DiagnosticService
{
private $aspectWeights = [
        'rentabilite' => 0.30,
        'solvabilite' => 0.25, 
        'liquidite' => 0.20,
        'pedagogique' => 0.25
    ];
    
    private $aspectConfig = [
        'rentabilite' => [
            'code' => 'RENTABILITE',
            'nom' => 'Rentabilité',
            'kpi_names' => [
                'marge_brute' => 'Marge Brute',
                'marge_nette' => 'Marge Nette',
                'roe' => 'ROE',
                'roa' => 'ROA'
            ]
        ],
        'solvabilite' => [
            'code' => 'SOLVABILITE',
            'nom' => 'Solvabilité',
            'kpi_names' => [
                'autonomie_financiere' => 'Autonomie Financière',
                'ratio_endettement' => 'Ratio d\'Endettement',
                'capacite_remboursement' => 'Capacité Remboursement'
            ]
        ],
        'liquidite' => [
            'code' => 'LIQUIDITE',
            'nom' => 'Liquidité',
            'kpi_names' => [
                'tresorerie_nette' => 'Trésorerie Nette',
                'ratio_liquidite_generale' => 'Ratio Liquidité',
                'bfr' => 'Besoin Fonds Roulement'
            ]
        ],
        'pedagogique' => [
            'code' => 'PEDAGOGIQUE',
            'nom' => 'Performance Pédagogique',
            'kpi_names' => [
                'cout_fonctionnement_par_eleve' => 'Coût par Élève',
                'chiffre_affaires_par_eleve' => 'CA par Élève',
                'part_masse_salariale_enseignante' => 'Part Masse Salariale',
                'marge_par_eleve' => 'Marge par Élève'
            ]
        ]
    ];

    public function calculerDiagnosticGlobal($dateDebut, $dateFin)
    {
        $cacheKey = "diagnostic_global_v2_{$dateDebut}_{$dateFin}";
        
        return Cache::remember($cacheKey, 3600, function() use ($dateDebut, $dateFin) {
            return $this->calculerDiagnosticV2($dateDebut, $dateFin);
        });
    }

    /**
     * NOUVELLE VERSION : Utilise le contrôleur unifié
     */
    private function calculerDiagnosticV2($dateDebut, $dateFin)
    {
        try {
            // Appeler le contrôleur unifié
            $controller = app(\App\Http\Controllers\Analyse\DiagnosticControllerUnifie::class);
            $request = new \Illuminate\Http\Request([
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ]);
            
            $response = $controller->getTousIndicateurs($request);
            $data = json_decode($response->getContent(), true);
            
            if (!$data['success']) {
                throw new \Exception("Erreur dans la collecte des indicateurs");
            }
            
            return $this->analyserAspects($data['aspects']);
            
        } catch (\Exception $e) {
            return $this->getDiagnosticErreur($e->getMessage(), $dateDebut, $dateFin);
        }
    }

    private function analyserAspects($aspectsData)
    {
        $aspects = [];
        $totalScore = 0;
        $aspectCount = 0;
        
        foreach ($this->aspectConfig as $aspectKey => $config) {
            if (isset($aspectsData[$aspectKey]) && $aspectsData[$aspectKey]['success']) {
                $aspectData = $this->analyserAspect($aspectKey, $aspectsData[$aspectKey]);
                $aspects[$aspectKey] = $aspectData;
                
                if ($aspectData['score'] > 0) {
                    $totalScore += $aspectData['score'] * $this->aspectWeights[$aspectKey];
                    $aspectCount++;
                }
            } else {
                // Aspect en erreur
                $aspects[$aspectKey] = [
                    'code' => $config['code'],
                    'nom' => $config['nom'],
                    'score' => 0,
                    'niveau' => 'error',
                    'kpis' => [],
                    'diagnostic' => "Données non disponibles"
                ];
            }
        }
        
        $scoreGlobal = $aspectCount > 0 ? round($totalScore) : 0;
        
        return [
            'score_global' => $scoreGlobal,
            'aspects' => $aspects,
            'recommandations' => $this->genererRecommandations($aspects),
            'periode' => [
                'date_debut' => request('date_debut'),
                'date_fin' => request('date_fin')
            ],
            'generated_at' => now()->toIso8601String()
        ];
    }

    private function analyserAspect($aspectKey, $data)
    {
        $config = $this->aspectConfig[$aspectKey];
        $kpis = [];
        $scores = [];
        
        // Pour pédagogique, structure différente
        if ($aspectKey === 'pedagogique' && isset($data['indicateurs_pedagogiques'])) {
            foreach ($data['indicateurs_pedagogiques'] as $key => $kpiData) {
                $kpi = $this->creerKpi($key, $kpiData, $config);
                if ($kpi) {
                    $kpis[] = $kpi;
                    $scores[] = $this->calculerScoreFromNiveau($kpi['niveau']);
                }
            }
        } else {
            // Pour les autres aspects
            foreach ($config['kpi_names'] as $dataKey => $nomKpi) {
                if (isset($data[$dataKey])) {
                    $kpi = $this->creerKpi($dataKey, $data[$dataKey], $config);
                    if ($kpi) {
                        $kpis[] = $kpi;
                        $scores[] = $this->calculerScoreFromNiveau($kpi['niveau']);
                    }
                }
            }
        }
        
        $scoreMoyen = !empty($scores) ? array_sum($scores) / count($scores) : 0;
        
        return [
            'code' => $config['code'],
            'nom' => $config['nom'],
            'score' => round($scoreMoyen),
            'niveau' => $this->getNiveauGlobal($scoreMoyen),
            'kpis' => $kpis,
            'diagnostic' => $this->getDiagnosticAspect($aspectKey, $scoreMoyen, $kpis),
            'raw_data' => $data
        ];
    }

    private function creerKpi($key, $kpiData, $config)
    {
        if (!is_array($kpiData) || !isset($kpiData['valeur'])) {
            return null;
        }
        
        $nom = $config['kpi_names'][$key] ?? ucfirst(str_replace('_', ' ', $key));
        
        return [
            'nom' => $nom,
            'valeur' => $kpiData['valeur'],
            'unite' => $kpiData['unite'] ?? '',
            'interpretation' => $kpiData['interpretation'] ?? '',
            'niveau' => strtolower($kpiData['niveau_alerte']['libelle'] ?? 'inconnu'),
            'couleur' => $kpiData['niveau_alerte']['couleur'] ?? '#cccccc'
        ];
    }    
    /**
     * CORRECTION DES DATES: Convertit 2025-12-01-01 -> 2025-12-01
     */
    private function formatDateForSql($dateString)
    {
        if (empty($dateString)) {
            return null;
        }
        
        // 1. Si format YYYY-MM-DD-HH -> extraire YYYY-MM-DD
        if (preg_match('/^(\d{4}-\d{2}-\d{2})-\d{2}$/', $dateString, $matches)) {
            return $matches[1];
        }
        
        // 2. Si déjà YYYY-MM-DD
        if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateString)) {
            return $dateString;
        }
        
        // 3. Essayer avec Carbon
        try {
            return Carbon::parse($dateString)->format('Y-m-d');
        } catch (\Exception $e) {
            return null;
        }
    }

    private function formaterAspect($aspectKey, $controllerData)
    {
        $config = $this->aspectConfig[$aspectKey];
        
        switch ($aspectKey) {
            case 'rentabilite':
                return $this->formaterRentabilite($controllerData, $config);
            case 'solvabilite':
                return $this->formaterSolvabilite($controllerData, $config);
            case 'liquidite':
                return $this->formaterLiquidite($controllerData, $config); // AJOUTÉ
            case 'pedagogique':
                return $this->formaterPedagogique($controllerData, $config);
            default:
                return $this->formaterGenerique($controllerData, $config);
        }
    }

    // AJOUT DE LA MÉTHODE MANQUANTE
    private function formaterLiquidite($data, $config)
    {
        $kpis = [];
        $scores = [];
        
        // Trésorerie nette
        if (isset($data['tresorerie_nette'])) {
            $kpi = $data['tresorerie_nette'];
            $score = $this->calculerScoreFromNiveau($kpi['niveau_alerte']['libelle'] ?? 'inconnu');
            $scores[] = $score;
            
            $kpis[] = [
                'nom' => 'Trésorerie Nette',
                'valeur' => $kpi['valeur'],
                'unite' => $kpi['unite'] ?? 'Ar',
                'interpretation' => $kpi['interpretation'],
                'niveau' => strtolower($kpi['niveau_alerte']['libelle'] ?? 'inconnu'),
                'couleur' => $kpi['niveau_alerte']['couleur'] ?? '#cccccc'
            ];
        }
        
        // Ratio de liquidité générale
        if (isset($data['ratio_liquidite_generale'])) {
            $kpi = $data['ratio_liquidite_generale'];
            $score = $this->calculerScoreFromNiveau($kpi['niveau_alerte']['libelle'] ?? 'inconnu');
            $scores[] = $score;
            
            $kpis[] = [
                'nom' => 'Ratio Liquidité',
                'valeur' => $kpi['valeur'],
                'unite' => $kpi['unite'] ?? '%',
                'interpretation' => $kpi['interpretation'],
                'niveau' => strtolower($kpi['niveau_alerte']['libelle'] ?? 'inconnu'),
                'couleur' => $kpi['niveau_alerte']['couleur'] ?? '#cccccc'
            ];
        }
        
        // BFR
        if (isset($data['bfr'])) {
            $kpi = $data['bfr'];
            $score = $this->calculerScoreFromNiveau($kpi['niveau_alerte']['libelle'] ?? 'inconnu');
            $scores[] = $score;
            
            $kpis[] = [
                'nom' => 'Besoin Fonds Roulement',
                'valeur' => $kpi['valeur'],
                'interpretation' => $kpi['interpretation'],
                'niveau' => strtolower($kpi['niveau_alerte']['libelle'] ?? 'inconnu'),
                'couleur' => $kpi['niveau_alerte']['couleur'] ?? '#cccccc'
            ];
        }
        
        $scoreMoyen = !empty($scores) ? array_sum($scores) / count($scores) : 0;
        
        return [
            'code' => $config['code'],
            'nom' => $config['nom'],
            'score' => round($scoreMoyen),
            'niveau' => $this->getNiveauGlobal($scoreMoyen),
            'kpis' => $kpis,
            'diagnostic' => $this->getDiagnosticLiquidite($scoreMoyen, $kpis),
            'raw_data' => $data
        ];
    }

    // AJOUT DE LA MÉTHODE MANQUANTE
    private function formaterGenerique($data, $config)
    {
        $kpis = [];
        $scores = [];
        
        // Essayer de détecter les KPI dans la réponse
        foreach ($data as $key => $value) {
            if (is_array($value) && isset($value['valeur']) && isset($value['interpretation'])) {
                $score = $this->calculerScoreFromNiveau($value['niveau_alerte']['libelle'] ?? 'inconnu');
                $scores[] = $score;
                
                $kpis[] = [
                    'nom' => ucfirst(str_replace('_', ' ', $key)),
                    'valeur' => $value['valeur'],
                    'unite' => $value['unite'] ?? '',
                    'interpretation' => $value['interpretation'],
                    'niveau' => strtolower($value['niveau_alerte']['libelle'] ?? 'inconnu'),
                    'couleur' => $value['niveau_alerte']['couleur'] ?? '#cccccc'
                ];
            }
        }
        
        $scoreMoyen = !empty($scores) ? array_sum($scores) / count($scores) : 0;
        
        return [
            'code' => $config['code'],
            'nom' => $config['nom'],
            'score' => round($scoreMoyen),
            'niveau' => $this->getNiveauGlobal($scoreMoyen),
            'kpis' => $kpis,
            'diagnostic' => "Analyse générique - " . ($scoreMoyen >= 60 ? "Performance correcte" : "À améliorer"),
            'raw_data' => $data
        ];
    }

    // CONSERVEZ LES MÉTHODES EXISTANTES (elles sont correctes)
    private function formaterRentabilite($data, $config)
    {
        $kpis = [];
        $scores = [];
        
        // Marge brute
        if (isset($data['marge_brute'])) {
            $kpi = $data['marge_brute'];
            $score = $this->calculerScoreFromNiveau($kpi['niveau_alerte']['libelle'] ?? 'inconnu');
            $scores[] = $score;
            
            $kpis[] = [
                'nom' => 'Marge Brute',
                'valeur' => $kpi['valeur'],
                'unite' => $kpi['unite'] ?? '%',
                'interpretation' => $kpi['interpretation'],
                'niveau' => strtolower($kpi['niveau_alerte']['libelle'] ?? 'inconnu'),
                'couleur' => $kpi['niveau_alerte']['couleur'] ?? '#cccccc'
            ];
        }
        
        // Marge nette
        if (isset($data['marge_nette'])) {
            $kpi = $data['marge_nette'];
            $score = $this->calculerScoreFromNiveau($kpi['niveau_alerte']['libelle'] ?? 'inconnu');
            $scores[] = $score;
            
            $kpis[] = [
                'nom' => 'Marge Nette',
                'valeur' => $kpi['valeur'],
                'unite' => $kpi['unite'] ?? '%',
                'interpretation' => $kpi['interpretation'],
                'niveau' => strtolower($kpi['niveau_alerte']['libelle'] ?? 'inconnu'),
                'couleur' => $kpi['niveau_alerte']['couleur'] ?? '#cccccc'
            ];
        }
        
        // ROE
        if (isset($data['roe'])) {
            $kpi = $data['roe'];
            $score = $this->calculerScoreFromNiveau($kpi['niveau_alerte']['libelle'] ?? 'inconnu');
            $scores[] = $score;
            
            $kpis[] = [
                'nom' => 'ROE',
                'valeur' => $kpi['valeur'],
                'unite' => $kpi['unite'] ?? '%',
                'interpretation' => $kpi['interpretation'],
                'niveau' => strtolower($kpi['niveau_alerte']['libelle'] ?? 'inconnu'),
                'couleur' => $kpi['niveau_alerte']['couleur'] ?? '#cccccc'
            ];
        }
        
        $scoreMoyen = !empty($scores) ? array_sum($scores) / count($scores) : 0;
        
        return [
            'code' => $config['code'],
            'nom' => $config['nom'],
            'score' => round($scoreMoyen),
            'niveau' => $this->getNiveauGlobal($scoreMoyen),
            'kpis' => $kpis,
            'diagnostic' => $this->getDiagnosticRentabilite($scoreMoyen, $kpis),
            'raw_data' => $data
        ];
    }

    private function formaterSolvabilite($data, $config)
    {
        $kpis = [];
        $scores = [];
        
        // Ratio d'endettement
        if (isset($data['ratio_endettement'])) {
            $kpi = $data['ratio_endettement'];
            $score = $this->calculerScoreFromNiveau($kpi['niveau_alerte']['libelle'] ?? 'inconnu');
            $scores[] = $score;
            
            $kpis[] = [
                'nom' => 'Ratio d\'Endettement',
                'valeur' => $kpi['valeur'],
                'interpretation' => $kpi['interpretation'],
                'niveau' => strtolower($kpi['niveau_alerte']['libelle'] ?? 'inconnu'),
                'couleur' => $kpi['niveau_alerte']['couleur'] ?? '#cccccc'
            ];
        }
        
        // Autonomie financière
        if (isset($data['autonomie_financiere'])) {
            $kpi = $data['autonomie_financiere'];
            $score = $this->calculerScoreFromNiveau($kpi['niveau_alerte']['libelle'] ?? 'inconnu');
            $scores[] = $score;
            
            $kpis[] = [
                'nom' => 'Autonomie Financière',
                'valeur' => $kpi['valeur'],
                'unite' => $kpi['unite'] ?? '%',
                'interpretation' => $kpi['interpretation'],
                'niveau' => strtolower($kpi['niveau_alerte']['libelle'] ?? 'inconnu'),
                'couleur' => $kpi['niveau_alerte']['couleur'] ?? '#cccccc'
            ];
        }
        
        $scoreMoyen = !empty($scores) ? array_sum($scores) / count($scores) : 0;
        
        return [
            'code' => $config['code'],
            'nom' => $config['nom'],
            'score' => round($scoreMoyen),
            'niveau' => $this->getNiveauGlobal($scoreMoyen),
            'kpis' => $kpis,
            'diagnostic' => $this->getDiagnosticSolvabilite($scoreMoyen, $kpis),
            'raw_data' => $data
        ];
    }

    private function formaterPedagogique($data, $config)
    {
        $kpis = [];
        $scores = [];
        
        if (isset($data['indicateurs_pedagogiques'])) {
            $indicateurs = $data['indicateurs_pedagogiques'];
            
            foreach ($indicateurs as $key => $kpi) {
                $score = $this->calculerScoreFromNiveau($kpi['niveau_alerte']['libelle'] ?? 'inconnu');
                $scores[] = $score;
                
                $nom = $this->getNomKpiPedagogique($key);
                
                $kpis[] = [
                    'nom' => $nom,
                    'valeur' => $kpi['valeur'],
                    'unite' => $kpi['unite'] ?? '',
                    'interpretation' => $kpi['interpretation'],
                    'niveau' => strtolower($kpi['niveau_alerte']['libelle'] ?? 'inconnu'),
                    'couleur' => $kpi['niveau_alerte']['couleur'] ?? '#cccccc'
                ];
            }
        }
        
        $scoreMoyen = !empty($scores) ? array_sum($scores) / count($scores) : 0;
        
        return [
            'code' => $config['code'],
            'nom' => $config['nom'],
            'score' => round($scoreMoyen),
            'niveau' => $this->getNiveauGlobal($scoreMoyen),
            'kpis' => $kpis,
            'diagnostic' => $this->getDiagnosticPedagogique($scoreMoyen, $kpis),
            'raw_data' => $data
        ];
    }

    private function getNomKpiPedagogique($key)
    {
        $noms = [
            'cout_fonctionnement_par_eleve' => 'Coût par Élève',
            'chiffre_affaires_par_eleve' => 'CA par Élève',
            'part_masse_salariale_enseignante' => 'Part Masse Salariale',
            'marge_par_eleve' => 'Marge par Élève'
        ];
        
        return $noms[$key] ?? $key;
    }

    private function calculerScoreFromNiveau($niveau)
    {
        $niveau = strtolower($niveau);
        
        $scores = [
            'bon' => 100,
            'moyen' => 50,
            'mauvais' => 0,
            'excellent' => 100,
            'tres bon' => 90,
            'correct' => 70
        ];
        
        return $scores[$niveau] ?? 50;
    }

    private function getNiveauGlobal($score)
    {
        if ($score >= 80) return 'excellent';
        if ($score >= 60) return 'bon';
        if ($score >= 40) return 'moyen';
        if ($score >= 20) return 'faible';
        return 'critique';
    }

    private function genererRecommandations($aspects)
    {
        $recommandations = [];
        
        // Détecter les aspects critiques (score < 40)
        foreach ($aspects as $key => $aspect) {
            if ($aspect['score'] < 40) {
                $recommandations[] = [
                    'priorite' => 'haute',
                    'titre' => "Corriger les problèmes dans {$aspect['nom']}",
                    'description' => $aspect['diagnostic'],
                    'actions' => $this->getActionsConcretes($key, $aspect)
                ];
            }
        }
        
        // Si pas de problèmes critiques, suggérer des améliorations
        if (empty($recommandations)) {
            foreach ($aspects as $key => $aspect) {
                if ($aspect['score'] < 70) {
                    $recommandations[] = [
                        'priorite' => 'moyenne',
                        'titre' => "Améliorer la performance dans {$aspect['nom']}",
                        'description' => $aspect['diagnostic'],
                        'actions' => $this->getActionsConcretes($key, $aspect)
                    ];
                }
            }
        }
        
        // Limiter à 3 recommandations max
        return array_slice($recommandations, 0, 3);
    }

    private function getActionsConcretes($aspectKey, $aspect)
    {
        $actions = [];
        
        foreach ($aspect['kpis'] as $kpi) {
            if (in_array($kpi['niveau'], ['mauvais', 'faible'])) {
                $actions[] = "Améliorer le KPI '{$kpi['nom']}' (actuel: {$kpi['valeur']})";
            }
        }
        
        return !empty($actions) ? $actions : ["Analyser en détail les données de l'aspect {$aspect['nom']}"];
    }

    // AJOUT DES MÉTHODES DE DIAGNOSTIC MANQUANTES
    private function getDiagnosticRentabilite($score, $kpis)
    {
        if ($score >= 80) return "Excellente rentabilité, l'établissement génère des bénéfices solides.";
        if ($score >= 60) return "Rentabilité satisfaisante, mais peut être améliorée.";
        if ($score >= 40) return "Rentabilité fragile, nécessite une attention particulière.";
        return "Rentabilité critique, risque de pertes.";
    }
    
    private function getDiagnosticSolvabilite($score, $kpis)
    {
        if ($score >= 80) return "Structure financière solide, faible endettement.";
        if ($score >= 60) return "Structure acceptable, surveiller l'endettement.";
        if ($score >= 40) return "Structure fragile, endettement élevé.";
        return "Structure critique, risque financier important.";
    }
    
    private function getDiagnosticLiquidite($score, $kpis) // AJOUTÉ
    {
        if ($score >= 80) return "Trésorerie excellente, bonne capacité à faire face aux dettes.";
        if ($score >= 60) return "Liquidité satisfaisante, surveiller les échéances.";
        if ($score >= 40) return "Liquidité tendue, risque de problèmes de paiement.";
        return "Liquidité critique, besoin urgent de financement.";
    }
    
    private function getDiagnosticPedagogique($score, $kpis)
    {
        if ($score >= 80) return "Excellente efficience pédagogique, coûts bien maîtrisés.";
        if ($score >= 60) return "Performance pédagogique satisfaisante.";
        if ($score >= 40) return "Performance pédagogique à améliorer, coûts élevés.";
        return "Performance pédagogique critique, revoir le modèle économique.";
    }
}