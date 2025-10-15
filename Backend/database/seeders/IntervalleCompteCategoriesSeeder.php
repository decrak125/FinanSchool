<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class IntervalleCompteCategoriesSeeder extends Seeder
{
    public function run()
    {
        $datas = [
            // Résultat : chiffre d'affaires
            ['compte_debut' => '700', 'compte_fin' => '709', 'code_cat' => 'CA'],
            // Production stockée
            ['compte_debut' => '710', 'compte_fin' => '715', 'code_cat' => 'PRODSTOCK'],
            // Production immobilisée
            ['compte_debut' => '720', 'compte_fin' => '729', 'code_cat' => 'PRODIMMO'],
            // Subventions d'exploitation
            ['compte_debut' => '740', 'compte_fin' => '749', 'code_cat' => 'SUBVENT'],
            // Achats consommés : Achats et variations de stocks
            ['compte_debut' => '601', 'compte_fin' => '609', 'code_cat' => 'ACHATCONSOM'],
            // Services extérieurs
            ['compte_debut' => '611', 'compte_fin' => '619', 'code_cat' => 'SERVEXT'],
            // Charges de personnel
            ['compte_debut' => '620', 'compte_fin' => '629', 'code_cat' => 'CHPERS'],
            // Impôts, taxes (TSY MISY AO)
            // ['compte_debut' => '630', 'compte_fin' => '639', 'code_cat' => 'IMPTAX'],
            // Autres produits d'exploitation
            ['compte_debut' => '750', 'compte_fin' => '759', 'code_cat' => 'AUTPRODOP'],
            // Autres charges d'exploitation
            ['compte_debut' => '650', 'compte_fin' => '659', 'code_cat' => 'AUTCHOP'],
            // Dotations aux amortissements/provisions
            ['compte_debut' => '640', 'compte_fin' => '649', 'code_cat' => 'AMORTPROV'],
            // Reprises sur provisions 
            ['compte_debut' => '780', 'compte_fin' => '789', 'code_cat' => 'REPRISEPROV'],
            // Produits financiers
            ['compte_debut' => '760', 'compte_fin' => '769', 'code_cat' => 'PRODFIN'],
            // Charges financières
            ['compte_debut' => '650', 'compte_fin' => '659', 'code_cat' => 'CHARGEFIN'],
            // Impôts sur les résultats (TSISY)
            // ['compte_debut' => '690', 'compte_fin' => '699', 'code_cat' => 'IMPOT'],
            // Impôts différés
            // Optionnelle selon structure
            // Produits exceptionnels
            ['compte_debut' => '770', 'compte_fin' => '779', 'code_cat' => 'PRODEXCEPT'],
            // Charges exceptionnelles
            ['compte_debut' => '670', 'compte_fin' => '679', 'code_cat' => 'CHAREXCEPT'],
            
            // Bilan : Immobilisations incorporelles
            ['compte_debut' => '200', 'compte_fin' => '209', 'code_cat' => 'IMMOINC'],
            // Immobilisations corporelles
            ['compte_debut' => '210', 'compte_fin' => '219', 'code_cat' => 'IMMOCO'],
            // Immobilisations en cours
            ['compte_debut' => '230', 'compte_fin' => '239', 'code_cat' => 'IMMOCOURS'],
            // Immobilisations financières & titres mis en équivalence
            ['compte_debut' => '260', 'compte_fin' => '279', 'code_cat' => 'IMMOFIN'],
            // Stocks et en-cours
            ['compte_debut' => '310', 'compte_fin' => '399', 'code_cat' => 'STOCKS'],
            // Clients et autres débiteurs
            ['compte_debut' => '410', 'compte_fin' => '419', 'code_cat' => 'CLIENTS'],
            // Autres créances
            ['compte_debut' => '420', 'compte_fin' => '499', 'code_cat' => 'AUTCREANCES'],
            // Capitaux propres
            ['compte_debut' => '100', 'compte_fin' => '119', 'code_cat' => 'CAPITAL'],
            ['compte_debut' => '120', 'compte_fin' => '129', 'code_cat' => 'PRIME'],
            ['compte_debut' => '130', 'compte_fin' => '139', 'code_cat' => 'EVAL'],
            ['compte_debut' => '140', 'compte_fin' => '149', 'code_cat' => 'EQUIV'],
            // Résultat, report à nouveau...
            ['compte_debut' => '120', 'compte_fin' => '129', 'code_cat' => 'RESULT'], // à affiner selon usage
            // Provisions (passif)
            ['compte_debut' => '150', 'compte_fin' => '159', 'code_cat' => 'PROVNCOUR'],
            // Subventions d'investissement
            ['compte_debut' => '131', 'compte_fin' => '139', 'code_cat' => 'SUBVINV'],
            // Emprunts et dettes financières (LT)
            ['compte_debut' => '160', 'compte_fin' => '169', 'code_cat' => 'EMPRUNT'],
            // Fournisseurs
            ['compte_debut' => '400', 'compte_fin' => '409', 'code_cat' => 'FOURN'],
            // Dettes court terme
            ['compte_debut' => '420', 'compte_fin' => '449', 'code_cat' => 'DETTECT'],
            // Provisions et produits constatés d'avance passif
            ['compte_debut' => '480', 'compte_fin' => '489', 'code_cat' => 'PROVC'],
            // Autres dettes
            ['compte_debut' => '450', 'compte_fin' => '499', 'code_cat' => 'AUTDETTE'],
            // Trésorerie : banque (peut affiner code banque/placement...)
            ['compte_debut' => '512', 'compte_fin' => '512', 'code_cat' => 'TRESO'],
            // Comptes de trésorerie découverts bancaires
            ['compte_debut' => '519', 'compte_fin' => '519', 'code_cat' => 'DECOUV'],

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
