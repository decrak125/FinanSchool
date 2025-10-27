<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class IntervalleCompteCategoriesSeeder extends Seeder
{
    public function run()
    {
        $datas = [
            // Résultat - Produits (Classe 7)
            ['compte_debut' => '700', 'compte_fin' => '709', 'code_cat' => 'CA'],            // Chiffre d'affaires
            ['compte_debut' => '710', 'compte_fin' => '719', 'code_cat' => 'PRODSTOCK'],     // Production stockée
            ['compte_debut' => '720', 'compte_fin' => '729', 'code_cat' => 'PRODIMMO'],      // Production immobilisée
            ['compte_debut' => '740', 'compte_fin' => '749', 'code_cat' => 'SUBVENT'],       // Subventions d'exploitation
            ['compte_debut' => '750', 'compte_fin' => '759', 'code_cat' => 'AUTPRODOP'],     // Autres produits opérationnels
            ['compte_debut' => '760', 'compte_fin' => '769', 'code_cat' => 'PRODFIN'],       // Produits financiers
            ['compte_debut' => '770', 'compte_fin' => '779', 'code_cat' => 'PRODEXCEPT'],    // Produits exceptionnels
            ['compte_debut' => '780', 'compte_fin' => '789', 'code_cat' => 'REPRISEPROV'],   // Reprises sur provisions, pertes de valeur
            // Charges exploitation (Classe 6)
            ['compte_debut' => '601', 'compte_fin' => '609', 'code_cat' => 'ACHATCONSOM'],   // Achats et variations de stocks
            ['compte_debut' => '611', 'compte_fin' => '619', 'code_cat' => 'SERVEXT'],       // Services extérieurs
            ['compte_debut' => '620', 'compte_fin' => '629', 'code_cat' => 'SERVEXT'],       // Services extérieurs
            ['compte_debut' => '630', 'compte_fin' => '639', 'code_cat' => 'IMPTAX'],        // Impôts et taxes
            ['compte_debut' => '640', 'compte_fin' => '649', 'code_cat' => 'CHPERS'],        // Charges de personnel
            ['compte_debut' => '651', 'compte_fin' => '659', 'code_cat' => 'AUTCHOP'],        //  AUTRES CHARGES DES ACTIVITES ORDINAIRES
            ['compte_debut' => '660', 'compte_fin' => '669', 'code_cat' => 'CHARGEFIN'],     // Charges financières
            ['compte_debut' => '670', 'compte_fin' => '679', 'code_cat' => 'CHAREXCEPT'],    // Charges exceptionnelles
            ['compte_debut' => '680', 'compte_fin' => '689', 'code_cat' => 'AMORTPROV'],     // Dotations aux amortissements/provisions
            // ['compte_debut' => '643', 'compte_fin' => '644', 'code_cat' => 'CHAREXPL'],      // Charges exploitation spécifique
            ['compte_debut' => '690', 'compte_fin' => '699', 'code_cat' => 'IMPOT'],         // Impôts sur résultats

            // Bilan Actif
            ['compte_debut' => '200', 'compte_fin' => '209', 'code_cat' => 'IMMOINC'],       // Imm. incorporelles
            ['compte_debut' => '210', 'compte_fin' => '219', 'code_cat' => 'IMMOCO'],        // Imm. corporelles
            ['compte_debut' => '230', 'compte_fin' => '239', 'code_cat' => 'IMMOCOURS'],     // Imm. en cours
            ['compte_debut' => '260', 'compte_fin' => '279', 'code_cat' => 'IMMOFIN'],       // Imm. financières

            ['compte_debut' => '310', 'compte_fin' => '399', 'code_cat' => 'STOCKS'],        // Stocks/en-cours

            ['compte_debut' => '411', 'compte_fin' => '419', 'code_cat' => 'CLIENTS'],       // Clients
            ['compte_debut' => '420', 'compte_fin' => '499', 'code_cat' => 'AUTCREANCES'],   // Autres créances
            
            ['compte_debut' => '512', 'compte_fin' => '519', 'code_cat' => 'TRESO'],         // Trésorerie


            // Bilan Passif et Capitaux propres
            ['compte_debut' => '100', 'compte_fin' => '119', 'code_cat' => 'CAPITAL'],       // Capital
            ['compte_debut' => '110', 'compte_fin' => '119', 'code_cat' => 'AUTCPRO'],       // Autres capitaux propres - Report à nouveau
            ['compte_debut' => '104', 'compte_fin' => '104', 'code_cat' => 'PRIME'],         // Primes/Réserves
            ['compte_debut' => '106', 'compte_fin' => '106', 'code_cat' => 'PRIME'],         // Primes/Réserves
            ['compte_debut' => '120', 'compte_fin' => '129', 'code_cat' => 'RESULT'],         
            ['compte_debut' => '130', 'compte_fin' => '139', 'code_cat' => 'EVAL'],          // Ecarts d’évaluation
            ['compte_debut' => '140', 'compte_fin' => '149', 'code_cat' => 'EQUIV'],         // Ecart d’équivalence
            ['compte_debut' => '150', 'compte_fin' => '159', 'code_cat' => 'PROVNCOUR'],     // Provisions non courantes
            ['compte_debut' => '160', 'compte_fin' => '169', 'code_cat' => 'EMPRUNT'],       // Emprunts long terme
            ['compte_debut' => '170', 'compte_fin' => '189', 'code_cat' => 'DETTECT'],       // Dettes court terme
            ['compte_debut' => '480', 'compte_fin' => '489', 'code_cat' => 'PROVC'],         // Provisions courantes passif
            ['compte_debut' => '400', 'compte_fin' => '409', 'code_cat' => 'FOURN'],         // Fournisseurs
            ['compte_debut' => '420', 'compte_fin' => '449', 'code_cat' => 'DETTECT'],       // Dettes court terme
            ['compte_debut' => '450', 'compte_fin' => '499', 'code_cat' => 'AUTDETTE'],      // Autres dettes

            // Comptes de variations de capitaux propres et flux financiers selon besoin
            // ['compte_debut' => '100', 'compte_fin' => '199', 'code_cat' => 'VARCP'],         // Variation CP (groupement large pour suivi)
            // ['compte_debut' => '500', 'compte_fin' => '599', 'code_cat' => 'FLUXTRESO'],     // Flux de trésorerie
            ['compte_debut' => '501', 'compte_fin' => '529', 'code_cat' => 'PLACEMENTS'],
            ['compte_debut' => '530', 'compte_fin' => '539', 'code_cat' => 'TRESOFONDS'],
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

