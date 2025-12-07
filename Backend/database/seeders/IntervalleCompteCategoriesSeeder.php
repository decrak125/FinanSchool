<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class IntervalleCompteCategoriesSeeder extends Seeder
{
    public function run()
    {
        $datas = [
    // --- CLASSE 1 : CAPITAUX PROPRES ---
    ['compte_debut' => '100', 'compte_fin' => '103', 'code_cat' => 'CAPITAL'],
    ['compte_debut' => '104', 'compte_fin' => '109', 'code_cat' => 'RESERVES'],
    ['compte_debut' => '110', 'compte_fin' => '119', 'code_cat' => 'REPORTNOUV'],
    ['compte_debut' => '120', 'compte_fin' => '129', 'code_cat' => 'RESULT'],
    ['compte_debut' => '130', 'compte_fin' => '139', 'code_cat' => 'SUBVINVEST'],
    ['compte_debut' => '140', 'compte_fin' => '149', 'code_cat' => 'PROVREG'],
    ['compte_debut' => '150', 'compte_fin' => '159', 'code_cat' => 'PROVNCOUR'],
    ['compte_debut' => '160', 'compte_fin' => '169', 'code_cat' => 'EMPRUNT'],
    ['compte_debut' => '170', 'compte_fin' => '179', 'code_cat' => 'DETTECT'],
    ['compte_debut' => '180', 'compte_fin' => '189', 'code_cat' => 'CPTLIAISON'],
    ['compte_debut' => '190', 'compte_fin' => '199', 'code_cat' => 'PROVRISQUE'], // ⭐ AJOUTÉ

    // --- CLASSE 2 : IMMOBILISATIONS ---
    ['compte_debut' => '200', 'compte_fin' => '209', 'code_cat' => 'IMMOINC'],
    ['compte_debut' => '210', 'compte_fin' => '219', 'code_cat' => 'IMMOCO'],
    ['compte_debut' => '220', 'compte_fin' => '229', 'code_cat' => 'IMMOCONCESS'],
    ['compte_debut' => '230', 'compte_fin' => '239', 'code_cat' => 'IMMOCOURS'],
    ['compte_debut' => '240', 'compte_fin' => '259', 'code_cat' => 'TERR_CONST'], // ⭐ AJOUTÉ (CRITIQUE)
    ['compte_debut' => '260', 'compte_fin' => '279', 'code_cat' => 'IMMOFIN'],
    ['compte_debut' => '280', 'compte_fin' => '280', 'code_cat' => 'AMORT_IMMOINC'],
    ['compte_debut' => '281', 'compte_fin' => '289', 'code_cat' => 'AMORT_IMMOCO'],
    ['compte_debut' => '290', 'compte_fin' => '299', 'code_cat' => 'PERTEVAL_IMMO'],

    // --- CLASSE 3 : STOCKS ---
    ['compte_debut' => '310', 'compte_fin' => '379', 'code_cat' => 'STOCKS'],
    ['compte_debut' => '390', 'compte_fin' => '399', 'code_cat' => 'PERTEVAL_STOCK'],

    // --- CLASSE 4 : TIERS ---
    ['compte_debut' => '400', 'compte_fin' => '409', 'code_cat' => 'FOURN'],
    ['compte_debut' => '410', 'compte_fin' => '419', 'code_cat' => 'CLIENTS'],
    ['compte_debut' => '420', 'compte_fin' => '429', 'code_cat' => 'PERS_CRED'],
    ['compte_debut' => '430', 'compte_fin' => '439', 'code_cat' => 'AUTCREANCES'],
    ['compte_debut' => '440', 'compte_fin' => '449', 'code_cat' => 'ETAT'],
    ['compte_debut' => '450', 'compte_fin' => '459', 'code_cat' => 'DETTE_ASSOC'],
    ['compte_debut' => '460', 'compte_fin' => '469', 'code_cat' => 'SOCGEN'],
    ['compte_debut' => '470', 'compte_fin' => '479', 'code_cat' => 'AUTCREC'],
    ['compte_debut' => '480', 'compte_fin' => '489', 'code_cat' => 'PROVC'],
    ['compte_debut' => '490', 'compte_fin' => '499', 'code_cat' => 'PERTEVAL_TIERS'],

    // --- CLASSE 5 : TRÉSORERIE ---
    ['compte_debut' => '500', 'compte_fin' => '509', 'code_cat' => 'FINPLACEMENT'],
    ['compte_debut' => '510', 'compte_fin' => '519', 'code_cat' => 'TRESO'],
    ['compte_debut' => '520', 'compte_fin' => '529', 'code_cat' => 'PLACEMENTS'],
    ['compte_debut' => '530', 'compte_fin' => '539', 'code_cat' => 'TRESOFONDS'],
    ['compte_debut' => '540', 'compte_fin' => '549', 'code_cat' => 'REGIES'],
    ['compte_debut' => '550', 'compte_fin' => '579', 'code_cat' => 'CPTCOURANT'], // ⭐ AJOUTÉ
    ['compte_debut' => '580', 'compte_fin' => '589', 'code_cat' => 'VIRINT'],
    ['compte_debut' => '590', 'compte_fin' => '599', 'code_cat' => 'PERTEVAL_FIN'],

    // --- CLASSE 6 : CHARGES ---
    ['compte_debut' => '600', 'compte_fin' => '609', 'code_cat' => 'ACHATCONSOM'],
    ['compte_debut' => '610', 'compte_fin' => '629', 'code_cat' => 'SERVEXT'],
    ['compte_debut' => '630', 'compte_fin' => '639', 'code_cat' => 'IMPTAX'],
    ['compte_debut' => '640', 'compte_fin' => '649', 'code_cat' => 'CHPERS'],
    ['compte_debut' => '650', 'compte_fin' => '659', 'code_cat' => 'AUTCHOP'],
    ['compte_debut' => '660', 'compte_fin' => '669', 'code_cat' => 'CHARGEFIN'],
    ['compte_debut' => '670', 'compte_fin' => '679', 'code_cat' => 'CHAREXCEPT'],
    ['compte_debut' => '680', 'compte_fin' => '689', 'code_cat' => 'AMORTPROV'],
    ['compte_debut' => '690', 'compte_fin' => '699', 'code_cat' => 'IMPOT'],

    // --- CLASSE 7 : PRODUITS ---
    ['compte_debut' => '700', 'compte_fin' => '709', 'code_cat' => 'CA'],
    ['compte_debut' => '710', 'compte_fin' => '719', 'code_cat' => 'PRODVENDU'],
    ['compte_debut' => '720', 'compte_fin' => '729', 'code_cat' => 'PRODIMMO'],
    ['compte_debut' => '730', 'compte_fin' => '739', 'code_cat' => 'PRODLTTERM'],
    ['compte_debut' => '740', 'compte_fin' => '749', 'code_cat' => 'SUBVENT'],
    ['compte_debut' => '750', 'compte_fin' => '759', 'code_cat' => 'AUTPRODOP'],
    ['compte_debut' => '760', 'compte_fin' => '769', 'code_cat' => 'PRODFIN'],
    ['compte_debut' => '770', 'compte_fin' => '779', 'code_cat' => 'PRODEXCEPT'],
    ['compte_debut' => '780', 'compte_fin' => '789', 'code_cat' => 'REPRISEPROV'],
    ['compte_debut' => '790', 'compte_fin' => '799', 'code_cat' => 'TRANSFCHARG'],
];

        // $datas = [
        //     // --- PRODUITS (Classe 7) ---
        //     ['compte_debut' => '700', 'compte_fin' => '709', 'code_cat' => 'CA'],
        //     ['compte_debut' => '710', 'compte_fin' => '719', 'code_cat' => 'PRODVENDU'],    // ✅ CORRIGÉ
        //     ['compte_debut' => '720', 'compte_fin' => '729', 'code_cat' => 'PRODIMMO'],
        //     ['compte_debut' => '730', 'compte_fin' => '739', 'code_cat' => 'PRODLTTERM'],   // ✅ AJOUTÉ
        //     ['compte_debut' => '740', 'compte_fin' => '749', 'code_cat' => 'SUBVENT'],
        //     ['compte_debut' => '750', 'compte_fin' => '759', 'code_cat' => 'AUTPRODOP'],
        //     ['compte_debut' => '760', 'compte_fin' => '769', 'code_cat' => 'PRODFIN'],
        //     ['compte_debut' => '770', 'compte_fin' => '779', 'code_cat' => 'PRODEXCEPT'],
        //     ['compte_debut' => '780', 'compte_fin' => '789', 'code_cat' => 'REPRISEPROV'],
        //     ['compte_debut' => '790', 'compte_fin' => '799', 'code_cat' => 'TRANSFCHARG'], // ✅ AJOUTÉ

        //     // --- CHARGES (Classe 6) ---
        //     ['compte_debut' => '600', 'compte_fin' => '609', 'code_cat' => 'ACHATCONSOM'],
        //     ['compte_debut' => '610', 'compte_fin' => '629', 'code_cat' => 'SERVEXT'],
        //     ['compte_debut' => '630', 'compte_fin' => '639', 'code_cat' => 'IMPTAX'],
        //     ['compte_debut' => '640', 'compte_fin' => '649', 'code_cat' => 'CHPERS'],
        //     ['compte_debut' => '650', 'compte_fin' => '659', 'code_cat' => 'AUTCHOP'],
        //     ['compte_debut' => '660', 'compte_fin' => '669', 'code_cat' => 'CHARGEFIN'],
        //     ['compte_debut' => '670', 'compte_fin' => '679', 'code_cat' => 'CHAREXCEPT'],
        //     ['compte_debut' => '680', 'compte_fin' => '689', 'code_cat' => 'AMORTPROV'],
        //     ['compte_debut' => '690', 'compte_fin' => '699', 'code_cat' => 'IMPOT'],

        //     // --- BILAN ACTIF - IMMOBILISATIONS ---
        //     ['compte_debut' => '200', 'compte_fin' => '209', 'code_cat' => 'IMMOINC'],
        //     ['compte_debut' => '210', 'compte_fin' => '219', 'code_cat' => 'IMMOCO'],      // ✅ CORRIGÉ
        //     ['compte_debut' => '220', 'compte_fin' => '229', 'code_cat' => 'IMMOCONCESS'], // ✅ AJOUTÉ
        //     ['compte_debut' => '230', 'compte_fin' => '239', 'code_cat' => 'IMMOCOURS'],
        //     ['compte_debut' => '260', 'compte_fin' => '279', 'code_cat' => 'IMMOFIN'],
        //     ['compte_debut' => '280', 'compte_fin' => '280', 'code_cat' => 'AMORT_IMMOINC'],
        //     ['compte_debut' => '281', 'compte_fin' => '289', 'code_cat' => 'AMORT_IMMOCO'],
        //     ['compte_debut' => '290', 'compte_fin' => '299', 'code_cat' => 'PERTEVAL_IMMO'], // ✅ AJOUTÉ

        //     // --- STOCKS ---
        //     ['compte_debut' => '310', 'compte_fin' => '379', 'code_cat' => 'STOCKS'],      // ✅ CORRIGÉ
        //     ['compte_debut' => '390', 'compte_fin' => '399', 'code_cat' => 'PERTEVAL_STOCK'], // ✅ AJOUTÉ

        //     // --- TIERS (Classe 4) ---
        //     ['compte_debut' => '400', 'compte_fin' => '409', 'code_cat' => 'FOURN'],
        //     ['compte_debut' => '410', 'compte_fin' => '419', 'code_cat' => 'CLIENTS'],
        //     ['compte_debut' => '420', 'compte_fin' => '429', 'code_cat' => 'PERS_CRED'],
        //     ['compte_debut' => '440', 'compte_fin' => '449', 'code_cat' => 'ETAT'],
            
        //     ['compte_debut' => '450', 'compte_fin' => '459', 'code_cat' => 'DETTE_ASSOC'],  // ✅ AJOUTÉ
        //     ['compte_debut' => '460', 'compte_fin' => '469', 'code_cat' => 'SOCGEN'],     // ✅ AJOUTÉ
        //     ['compte_debut' => '470', 'compte_fin' => '479', 'code_cat' => 'AUTCREC'],    // ✅ CORRIGÉ
        //     ['compte_debut' => '430', 'compte_fin' => '439', 'code_cat' => 'AUTCREANCES'],
        //     ['compte_debut' => '480', 'compte_fin' => '489', 'code_cat' => 'PROVC'],
        //     ['compte_debut' => '490', 'compte_fin' => '499', 'code_cat' => 'PERTEVAL_TIERS'], // ✅ AJOUTÉ

        //     // --- TRÉSORERIE (Classe 5) ---
        //     ['compte_debut' => '500', 'compte_fin' => '509', 'code_cat' => 'FINPLACEMENT'],
        //     ['compte_debut' => '510', 'compte_fin' => '519', 'code_cat' => 'TRESO'],
        //     ['compte_debut' => '520', 'compte_fin' => '529', 'code_cat' => 'PLACEMENTS'],
        //     ['compte_debut' => '530', 'compte_fin' => '539', 'code_cat' => 'TRESOFONDS'],
        //     ['compte_debut' => '540', 'compte_fin' => '549', 'code_cat' => 'REGIES'],      // ✅ AJOUTÉ
        //     ['compte_debut' => '580', 'compte_fin' => '589', 'code_cat' => 'VIRINT'],      // ✅ AJOUTÉ
        //     ['compte_debut' => '590', 'compte_fin' => '599', 'code_cat' => 'PERTEVAL_FIN'], // ✅ AJOUTÉ

        //     // --- CAPITAUX PROPRES (Classe 1) ---
        //     ['compte_debut' => '100', 'compte_fin' => '103', 'code_cat' => 'CAPITAL'],
        //     ['compte_debut' => '104', 'compte_fin' => '109', 'code_cat' => 'RESERVES'],    // ✅ AJOUTÉ
        //     ['compte_debut' => '110', 'compte_fin' => '119', 'code_cat' => 'REPORTNOUV'],  // ✅ AJOUTÉ
        //     ['compte_debut' => '120', 'compte_fin' => '129', 'code_cat' => 'RESULT'],
        //     ['compte_debut' => '130', 'compte_fin' => '139', 'code_cat' => 'SUBVINVEST'],  // ✅ CORRIGÉ
        //     ['compte_debut' => '140', 'compte_fin' => '149', 'code_cat' => 'PROVREG'],     // ✅ CORRIGÉ
        //     ['compte_debut' => '150', 'compte_fin' => '159', 'code_cat' => 'PROVNCOUR'],
        //     ['compte_debut' => '160', 'compte_fin' => '169', 'code_cat' => 'EMPRUNT'],
        //     ['compte_debut' => '170', 'compte_fin' => '179', 'code_cat' => 'DETTECT'],     // ✅ CORRIGÉ
        //     ['compte_debut' => '180', 'compte_fin' => '189', 'code_cat' => 'CPTLIAISON'],  // ✅ AJOUTÉ
        // ];

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
