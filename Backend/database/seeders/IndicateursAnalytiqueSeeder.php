<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class IndicateursAnalytiqueSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $indicateurs = [
            // 0. Indicateurs Généraux
            [
                'libelle' => 'Total Produits',
                'description' => 'Tous les revenus de l\'école',
                'formule' => 'Somme des comptes de classe 7'
            ],
            [
                'libelle' => 'Total Charges',
                'description' => 'Ensemble des dépenses',
                'formule' => 'Somme des comptes de classe 6'
            ],
            [
                'libelle' => 'Résultat net',
                'description' => 'Bénéfice ou perte de l\'exercice',
                'formule' => 'Produits – Charges'
            ],
            [
                'libelle' => 'Marge d\'exploitation',
                'description' => 'Capacité de l\'école à dégager une marge sur son activité',
                'formule' => '(Produits d\'exploitation – Charges d\'exploitation) / Produits d\'exploitation × 100'
            ],
            [
                'libelle' => 'Nombre d\'élèves',
                'description' => 'Sert à calculer les ratios par élève',
                'formule' => 'Donnée administrative'
            ],

            // 1.1 Indicateurs de rentabilité
            [
                'libelle' => 'Marge brute',
                'description' => 'Mesure la rentabilité opérationnelle de base',
                'formule' => '(Chiffre d\'affaires – Coût des ventes) / Chiffre d\'affaires'
            ],
            [
                'libelle' => 'Marge d\'exploitation (EBIT)',
                'description' => 'Évalue la performance des activités principales',
                'formule' => 'Résultat d\'exploitation / Chiffre d\'affaires'
            ],
            [
                'libelle' => 'Marge nette',
                'description' => 'Montre le bénéfice final par euro de ventes',
                'formule' => 'Résultat net / Chiffre d\'affaires'
            ],
            [
                'libelle' => 'ROE (Return on Equity)',
                'description' => 'Rendement des fonds propres',
                'formule' => 'Résultat net / Capitaux propres'
            ],
            [
                'libelle' => 'ROA (Return on Assets)',
                'description' => 'Efficacité globale des actifs',
                'formule' => 'Résultat net / Total actif'
            ],

            // 2. Indicateurs de liquidité
            [
                'libelle' => 'Ratio de liquidité générale',
                'description' => '> 1 indique une bonne solvabilité à court terme',
                'formule' => 'Actif circulant / Passif à court terme'
            ],
            [
                'libelle' => 'Trésorerie Nette',
                'description' => 'Solde de trésorerie',
                'formule' => 'Encaissements - Décaissements'
            ],
            [
                'libelle' => 'Besoin en fonds de roulement (BFR)',
                'description' => 'Permet d\'évaluer le besoin financier d\'exploitation',
                'formule' => '(Stocks + Créances clients) - Dettes fournisseurs'
            ],

            // 3. Indicateurs de solvabilité et d'indépendance
            [
                'libelle' => 'Ratio d\'endettement',
                'description' => 'Plus il est faible, plus la structure est solide',
                'formule' => 'Dettes financières / Capitaux propres'
            ],
            [
                'libelle' => 'Autonomie financière',
                'description' => '> 30% = bonne autonomie financière',
                'formule' => 'Capitaux propres / Total bilan'
            ],
            [
                'libelle' => 'Capacité de remboursement',
                'description' => 'Nombre d\'années nécessaires pour rembourser la dette',
                'formule' => 'Endettement net / CAF (Cash Flow)'
            ],
            [
                'libelle' => 'Coût de Fonctionnement par élève',
                'description' => 'Donne le "prix de revient" moyen d\'un élève. KPI de base essentiel.',
                'formule' => 'Total des Charges d\'Exploitation / Effectif total des élèves'
            ],
            [
                'libelle' => 'Chiffre d\'Affaires par élève',
                'description' => 'Montant moyen des ressources générées par élève.',
                'formule' => 'Total des Produits d\'Exploitation / Effectif total des élèves'
            ],
            [
                'libelle' => 'Part de la Masse Salariale Enseignante',
                'description' => 'Poids du coût des enseignants dans le budget total.',
                'formule' => '(Masse Salariale Enseignante / Total des Charges) * 100'
            ],
            [
                'libelle' => 'Marge par élève',
                'description' => 'Marge nette dégagée par élève. Le moteur de la rentabilité.',
                'formule' => '(Total Produits - Total Charges) / Effectif total des élèves'
            ],
        ];

        foreach ($indicateurs as $indicateur) {
            DB::table('indicateurs_analytique')->insert([
                'libelle' => $indicateur['libelle'],
                'description' => $indicateur['description'],
                'formule' => $indicateur['formule'],
            ]);
        }
    }
}