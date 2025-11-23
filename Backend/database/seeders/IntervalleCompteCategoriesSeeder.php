<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class IntervalleCompteCategoriesSeeder extends Seeder
{
    public function run()
    {
        $datas = [
            // --- PRODUITS (Classe 7) ---
            ['compte_debut' => '700', 'compte_fin' => '709', 'code_cat' => 'CA'],           // Chiffre d'affaires
            ['compte_debut' => '710', 'compte_fin' => '719', 'code_cat' => 'PRODSTOCK'],    // Production stockée
            ['compte_debut' => '720', 'compte_fin' => '729', 'code_cat' => 'PRODIMMO'],     // Production immobilisée
            ['compte_debut' => '740', 'compte_fin' => '749', 'code_cat' => 'SUBVENT'],      // Subventions d'exploitation
            ['compte_debut' => '750', 'compte_fin' => '759', 'code_cat' => 'AUTPRODOP'],    // Autres produits opérationnels
            ['compte_debut' => '760', 'compte_fin' => '769', 'code_cat' => 'PRODFIN'],      // Produits financiers
            ['compte_debut' => '770', 'compte_fin' => '779', 'code_cat' => 'PRODEXCEPT'],   // Produits exceptionnels
            ['compte_debut' => '780', 'compte_fin' => '789', 'code_cat' => 'REPRISEPROV'],  // Reprises sur provisions

            // --- CHARGES (Classe 6) ---
            ['compte_debut' => '600', 'compte_fin' => '609', 'code_cat' => 'ACHATCONSOM'],
            ['compte_debut' => '610', 'compte_fin' => '629', 'code_cat' => 'SERVEXT'],
            ['compte_debut' => '630', 'compte_fin' => '639', 'code_cat' => 'IMPTAX'],
            ['compte_debut' => '640', 'compte_fin' => '649', 'code_cat' => 'CHPERS'],
            ['compte_debut' => '650', 'compte_fin' => '659', 'code_cat' => 'AUTCHOP'],
            ['compte_debut' => '660', 'compte_fin' => '669', 'code_cat' => 'CHARGEFIN'],
            ['compte_debut' => '670', 'compte_fin' => '679', 'code_cat' => 'CHAREXCEPT'],
            ['compte_debut' => '680', 'compte_fin' => '689', 'code_cat' => 'AMORTPROV'],
            ['compte_debut' => '690', 'compte_fin' => '699', 'code_cat' => 'IMPOT'],

            // --- BILAN ACTIF ---
            ['compte_debut' => '200', 'compte_fin' => '209', 'code_cat' => 'IMMOINC'],
            ['compte_debut' => '210', 'compte_fin' => '229', 'code_cat' => 'IMMOCO'],
            ['compte_debut' => '230', 'compte_fin' => '239', 'code_cat' => 'IMMOCOURS'],
            ['compte_debut' => '260', 'compte_fin' => '279', 'code_cat' => 'IMMOFIN'],
            ['compte_debut' => '280', 'compte_fin' => '280', 'code_cat' => 'AMORT_IMMOINC'],
            ['compte_debut' => '281', 'compte_fin' => '289', 'code_cat' => 'AMORT_IMMOCO'],
            ['compte_debut' => '310', 'compte_fin' => '399', 'code_cat' => 'STOCKS'],

            ['compte_debut' => '400', 'compte_fin' => '409', 'code_cat' => 'FOURN'],
            ['compte_debut' => '410', 'compte_fin' => '419', 'code_cat' => 'CLIENTS'],
            ['compte_debut' => '420', 'compte_fin' => '479', 'code_cat' => 'AUTCREANCES'],

            ['compte_debut' => '500', 'compte_fin' => '509', 'code_cat' => 'FINPLACEMENT'],
            ['compte_debut' => '510', 'compte_fin' => '519', 'code_cat' => 'TRESO'],
            ['compte_debut' => '520', 'compte_fin' => '529', 'code_cat' => 'PLACEMENTS'],
            ['compte_debut' => '530', 'compte_fin' => '539', 'code_cat' => 'TRESOFONDS'],

            // --- CAPITAUX PROPRES PCG 2005 ---
            // Capital social, souscriptions, actions propres
            ['compte_debut' => '100', 'compte_fin' => '103', 'code_cat' => 'CAPITAL'],
            ['compte_debut' => '107', 'compte_fin' => '107', 'code_cat' => 'CAPITAL'],

            // Primes d'émission, réserves (légales, statutaires, autres), report à nouveau
            ['compte_debut' => '104', 'compte_fin' => '119', 'code_cat' => 'PRIME'],

            // Écarts d'évaluation
            ['compte_debut' => '130', 'compte_fin' => '139', 'code_cat' => 'EVAL'],

            // Écart d'équivalence
            ['compte_debut' => '140', 'compte_fin' => '149', 'code_cat' => 'EQUIV'],

            // Résultat de l'exercice
            ['compte_debut' => '120', 'compte_fin' => '129', 'code_cat' => 'RESULT'],

            // --- PASSIF SPÉCIFIQUE ---
            ['compte_debut' => '150', 'compte_fin' => '159', 'code_cat' => 'PROVNCOUR'],
            ['compte_debut' => '160', 'compte_fin' => '169', 'code_cat' => 'EMPRUNT'],
            ['compte_debut' => '170', 'compte_fin' => '189', 'code_cat' => 'DETTECT'],
            ['compte_debut' => '480', 'compte_fin' => '489', 'code_cat' => 'PROVC'],
            ['compte_debut' => '450', 'compte_fin' => '479', 'code_cat' => 'AUTDETTE'],
        ];

        foreach ($datas as $data) {
            DB::table('intervalle_comptes_categorie')->insert([
                'compte_debut' => $data['compte_debut'],
                'compte_fin'   => $data['compte_fin'],
                'id_categorie_fonctionelle' => DB::table('categorie_fonctionelles')
                    ->where('code', $data['code_cat'])
                    ->value('id_categorie_fonctionelle'),
            ]);
        }
    }
}
