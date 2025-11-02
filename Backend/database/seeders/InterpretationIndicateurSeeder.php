<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class InterpretationIndicateurSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Récupérer les IDs des indicateurs analytiques
        $indicateurs = DB::table('indicateurs_analytique')->get()->keyBy('libelle');
        
        // Récupérer les IDs des niveaux d'alerte
        $niveauxAlerte = DB::table('niveau_alerte')->get()->keyBy('libelle');

        $interpretations = [
            // TOTAL PRODUITS (indicateur général - pas d'interprétation spécifique)
            [
                'id_indicateur_analytique' => $indicateurs['Total Produits']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Tous les revenus de l\'école',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],

            // TOTAL CHARGES (indicateur général - pas d'interprétation spécifique)
            [
                'id_indicateur_analytique' => $indicateurs['Total Charges']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Ensemble des dépenses',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],

            // RÉSULTAT NET
            [
                'id_indicateur_analytique' => $indicateurs['Résultat net']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Bénéfice de l\'exercice',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Résultat net']->id_indicateur_analytique,
                'valeur' => -1.00,
                'interpretation' => 'Perte de l\'exercice',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // MARGE D'EXPLOITATION (générale)
            [
                'id_indicateur_analytique' => $indicateurs['Marge d\'exploitation']->id_indicateur_analytique,
                'valeur' => 20.00,
                'interpretation' => 'Excellente santé financière - Forte rentabilité',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge d\'exploitation']->id_indicateur_analytique,
                'valeur' => 10.00,
                'interpretation' => 'Bonne santé financière - Rentabilité satisfaisante',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge d\'exploitation']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Situation acceptable - Rentabilité faible',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge d\'exploitation']->id_indicateur_analytique,
                'valeur' => -1.00,
                'interpretation' => 'Déficit d\'exploitation - Situation préoccupante',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // NOMBRE D'ÉLÈVES (indicateur général - pas d'interprétation spécifique)
            [
                'id_indicateur_analytique' => $indicateurs['Nombre d\'élèves']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Sert à calculer les ratios par élève',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],

            // MARGE BRUTE
            [
                'id_indicateur_analytique' => $indicateurs['Marge brute']->id_indicateur_analytique,
                'valeur' => 40.00,
                'interpretation' => 'Excellente marge brute - Très bonne performance commerciale',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge brute']->id_indicateur_analytique,
                'valeur' => 25.00,
                'interpretation' => 'Bonne marge brute - Performance commerciale satisfaisante',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge brute']->id_indicateur_analytique,
                'valeur' => 15.00,
                'interpretation' => 'Marge brute acceptable - Performance commerciale moyenne',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge brute']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Marge brute faible - Revoir la stratégie commerciale ou les coûts',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // MARGE D'EXPLOITATION (EBIT)
            [
                'id_indicateur_analytique' => $indicateurs['Marge d\'exploitation (EBIT)']->id_indicateur_analytique,
                'valeur' => 15.00,
                'interpretation' => 'Excellente performance opérationnelle - Très bonne rentabilité',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge d\'exploitation (EBIT)']->id_indicateur_analytique,
                'valeur' => 8.00,
                'interpretation' => 'Bonne performance opérationnelle - Rentabilité satisfaisante',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge d\'exploitation (EBIT)']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Performance opérationnelle acceptable - Rentabilité modérée',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge d\'exploitation (EBIT)']->id_indicateur_analytique,
                'valeur' => -1.00,
                'interpretation' => 'Performance opérationnelle déficitaire - Situation à améliorer',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // MARGE NETTE
            [
                'id_indicateur_analytique' => $indicateurs['Marge nette']->id_indicateur_analytique,
                'valeur' => 10.00,
                'interpretation' => 'Excellente rentabilité nette - Très bon bénéfice final',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge nette']->id_indicateur_analytique,
                'valeur' => 5.00,
                'interpretation' => 'Bonne rentabilité nette - Bénéfice final satisfaisant',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge nette']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Rentabilité nette acceptable - Bénéfice final modéré',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge nette']->id_indicateur_analytique,
                'valeur' => -1.00,
                'interpretation' => 'Rentabilité nette négative - Déficit final',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // ROE (Return on Equity)
            [
                'id_indicateur_analytique' => $indicateurs['ROE (Return on Equity)']->id_indicateur_analytique,
                'valeur' => 15.00,
                'interpretation' => 'Excellente rentabilité des fonds propres',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['ROE (Return on Equity)']->id_indicateur_analytique,
                'valeur' => 8.00,
                'interpretation' => 'Bonne rentabilité des fonds propres',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['ROE (Return on Equity)']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Rentabilité modérée des fonds propres',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['ROE (Return on Equity)']->id_indicateur_analytique,
                'valeur' => -1.00,
                'interpretation' => 'Rentabilité insuffisante des fonds propres',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // ROA (Return on Assets)
            [
                'id_indicateur_analytique' => $indicateurs['ROA (Return on Assets)']->id_indicateur_analytique,
                'valeur' => 10.00,
                'interpretation' => 'Excellente efficacité des actifs',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['ROA (Return on Assets)']->id_indicateur_analytique,
                'valeur' => 5.00,
                'interpretation' => 'Bonne efficacité des actifs',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['ROA (Return on Assets)']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Efficacité modérée des actifs',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['ROA (Return on Assets)']->id_indicateur_analytique,
                'valeur' => -1.00,
                'interpretation' => 'Efficacité insuffisante des actifs',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // RATIO DE LIQUIDITÉ GÉNÉRALE
            [
                'id_indicateur_analytique' => $indicateurs['Ratio de liquidité générale']->id_indicateur_analytique,
                'valeur' => 1.50,
                'interpretation' => 'Très bonne solvabilité à court terme - Excédent de liquidité',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Ratio de liquidité générale']->id_indicateur_analytique,
                'valeur' => 1.00,
                'interpretation' => 'Bonne solvabilité à court terme - Situation saine',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Ratio de liquidité générale']->id_indicateur_analytique,
                'valeur' => 0.80,
                'interpretation' => 'Solvabilité acceptable - Surveillance recommandée',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Ratio de liquidité générale']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Solvabilité insuffisante - Risque de liquidité',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // TRÉSORERIE NETTE
            [
                'id_indicateur_analytique' => $indicateurs['Trésorerie Nette']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Excédent de trésorerie - Situation favorable',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Trésorerie Nette']->id_indicateur_analytique,
                'valeur' => -1.00,
                'interpretation' => 'Déficit de trésorerie - Attention nécessaire',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // BESOIN EN FONDS DE ROULEMENT (BFR)
            [
                'id_indicateur_analytique' => $indicateurs['Besoin en fonds de roulement (BFR)']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'BFR positif - Besoin de financement du cycle d\'exploitation',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Besoin en fonds de roulement (BFR)']->id_indicateur_analytique,
                'valeur' => -1.00,
                'interpretation' => 'BFR négatif - Ressource dégagée du cycle d\'exploitation',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],

            // RATIO D'ENDETTEMENT
            [
                'id_indicateur_analytique' => $indicateurs['Ratio d\'endettement']->id_indicateur_analytique,
                'valeur' => 0.50,
                'interpretation' => 'Structure financière très solide - Faible endettement',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Ratio d\'endettement']->id_indicateur_analytique,
                'valeur' => 1.00,
                'interpretation' => 'Structure financière saine - Endettement modéré',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Ratio d\'endettement']->id_indicateur_analytique,
                'valeur' => 2.00,
                'interpretation' => 'Endettement élevé - Surveillance nécessaire',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Ratio d\'endettement']->id_indicateur_analytique,
                'valeur' => 3.00,
                'interpretation' => 'Endettement très élevé - Situation risquée',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // AUTONOMIE FINANCIÈRE
            [
                'id_indicateur_analytique' => $indicateurs['Autonomie financière']->id_indicateur_analytique,
                'valeur' => 50.00,
                'interpretation' => 'Très forte autonomie financière - Structure excellente',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Autonomie financière']->id_indicateur_analytique,
                'valeur' => 30.00,
                'interpretation' => 'Bonne autonomie financière - Structure saine',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Autonomie financière']->id_indicateur_analytique,
                'valeur' => 20.00,
                'interpretation' => 'Autonomie acceptable - Surveillance recommandée',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Autonomie financière']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Autonomie insuffisante - Dépendance financière élevée',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // CAPACITÉ DE REMBOURSEMENT
            [
                'id_indicateur_analytique' => $indicateurs['Capacité de remboursement']->id_indicateur_analytique,
                'valeur' => 3.00,
                'interpretation' => 'Très bonne capacité de remboursement - Dette facilement remboursable',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Capacité de remboursement']->id_indicateur_analytique,
                'valeur' => 5.00,
                'interpretation' => 'Bonne capacité de remboursement - Dette gérable',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Capacité de remboursement']->id_indicateur_analytique,
                'valeur' => 7.00,
                'interpretation' => 'Capacité de remboursement acceptable - Surveillance nécessaire',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Capacité de remboursement']->id_indicateur_analytique,
                'valeur' => 10.00,
                'interpretation' => 'Capacité de remboursement faible - Risque élevé',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // ---------------------------------------------------------------------
            // INDICATEURS PEDAGOGIQUES
            // COÛT DE FONCTIONNEMENT PAR ÉLÈVE
            [
                'id_indicateur_analytique' => $indicateurs['Coût de Fonctionnement par élève']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Coût de fonctionnement très faible - Efficacité optimale',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Coût de Fonctionnement par élève']->id_indicateur_analytique,
                'valeur' => 1000.00,
                'interpretation' => 'Coût de fonctionnement faible - Bonne efficacité',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Coût de Fonctionnement par élève']->id_indicateur_analytique,
                'valeur' => 2000.00,
                'interpretation' => 'Coût de fonctionnement acceptable - Efficacité moyenne',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Coût de Fonctionnement par élève']->id_indicateur_analytique,
                'valeur' => 3000.00,
                'interpretation' => 'Coût de fonctionnement élevé - Nécessite une optimisation',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // CHIFFRE D'AFFAIRES PAR ÉLÈVE
            [
                'id_indicateur_analytique' => $indicateurs['Chiffre d\'Affaires par élève']->id_indicateur_analytique,
                'valeur' => 4000.00,
                'interpretation' => 'Très bon chiffre d\'affaires par élève - Excellente valorisation',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Chiffre d\'Affaires par élève']->id_indicateur_analytique,
                'valeur' => 3000.00,
                'interpretation' => 'Bon chiffre d\'affaires par élève - Valorisation satisfaisante',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Chiffre d\'Affaires par élève']->id_indicateur_analytique,
                'valeur' => 2000.00,
                'interpretation' => 'Chiffre d\'affaires par élève acceptable - Valorisation moyenne',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Chiffre d\'Affaires par élève']->id_indicateur_analytique,
                'valeur' => 1000.00,
                'interpretation' => 'Chiffre d\'affaires par élève faible - Revoir la stratégie tarifaire',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // PART DE LA MASSE SALARIALE ENSEIGNANTE
            [
                'id_indicateur_analytique' => $indicateurs['Part de la Masse Salariale Enseignante']->id_indicateur_analytique,
                'valeur' => 40.00,
                'interpretation' => 'Part enseignante optimale - Équilibre budgétaire excellent',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Part de la Masse Salariale Enseignante']->id_indicateur_analytique,
                'valeur' => 50.00,
                'interpretation' => 'Part enseignante raisonnable - Équilibre budgétaire bon',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Part de la Masse Salariale Enseignante']->id_indicateur_analytique,
                'valeur' => 60.00,
                'interpretation' => 'Part enseignante élevée - Surveillance recommandée',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Part de la Masse Salariale Enseignante']->id_indicateur_analytique,
                'valeur' => 70.00,
                'interpretation' => 'Part enseignante très élevée - Déséquilibre budgétaire',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],

            // MARGE PAR ÉLÈVE
            [
                'id_indicateur_analytique' => $indicateurs['Marge par élève']->id_indicateur_analytique,
                'valeur' => 1000.00,
                'interpretation' => 'Excellente marge par élève - Rentabilité très forte',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge par élève']->id_indicateur_analytique,
                'valeur' => 500.00,
                'interpretation' => 'Bonne marge par élève - Rentabilité satisfaisante',
                'id_niveau_alerte' => $niveauxAlerte['Bon']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge par élève']->id_indicateur_analytique,
                'valeur' => 0.00,
                'interpretation' => 'Marge par élève nulle - Équilibre précaire',
                'id_niveau_alerte' => $niveauxAlerte['Moyen']->id_niveau_alerte
            ],
            [
                'id_indicateur_analytique' => $indicateurs['Marge par élève']->id_indicateur_analytique,
                'valeur' => -500.00,
                'interpretation' => 'Marge par élève négative - Situation déficitaire',
                'id_niveau_alerte' => $niveauxAlerte['Mauvais']->id_niveau_alerte
            ],
        ];

        foreach ($interpretations as $interpretation) {
            DB::table('interpretation_indicateur')->insert([
                'id_indicateur_analytique' => $interpretation['id_indicateur_analytique'],
                'valeur' => $interpretation['valeur'],
                'interpretation' => $interpretation['interpretation'],
                'id_niveau_alerte' => $interpretation['id_niveau_alerte'],
            ]);
        }
    }
}