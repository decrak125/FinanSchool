<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ComptesMappingSeeder extends Seeder
{
    public function run()
    {
        // Vider les tables de mapping
        DB::table('compte_categories')->truncate();
        DB::table('sous_compte_categories')->truncate(); // Si vous en avez une

        // 1. Récupérer tous les intervalles avec leurs catégories
        $intervalles = DB::table('intervalle_comptes_categorie as ic')
            ->join('categorie_fonctionelles as cf', 'ic.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
            ->select([
                'ic.compte_debut',
                'ic.compte_fin', 
                'ic.id_categorie_fonctionelle',
                'cf.code as code_categorie',
                'cf.libelle as libelle_categorie'
            ])
            ->where('ic.actif', true)
            ->get();

        $totalComptesMappes = 0;
        $totalSousComptesMappes = 0;

        foreach ($intervalles as $intervalle) {
            // 2. Trouver tous les COMPTES dans cet intervalle
            // Code_compte est au format '21', '211', '2111', etc.
            $comptes = DB::table('comptes')
                ->whereRaw("Code_compte BETWEEN ? AND ?", [$intervalle->compte_debut, $intervalle->compte_fin])
                ->get();

            echo "📊 Catégorie '{$intervalle->code_categorie}' ({$intervalle->libelle_categorie}) : ";
            echo "{$comptes->count()} comptes trouvés dans [{$intervalle->compte_debut}-{$intervalle->compte_fin}]\n";

            // 3. Mapper chaque COMPTE à la catégorie
            foreach ($comptes as $compte) {
                DB::table('compte_categories')->insert([
                    'id_compte' => $compte->id_compte, // ← CHANGEMENT ICI
                    'id_categorie_fonctionelle' => $intervalle->id_categorie_fonctionelle,
                    'actif' => true,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);

                $totalComptesMappes++;

                // 4. Mapper tous les SOUS-COMPTES de ce compte
                $sousComptes = DB::table('sous_comptes')
                    ->where('id_compte', $compte->id_compte)
                    ->where('actif', true)
                    ->get();

                foreach ($sousComptes as $sousCompte) {
                    // Optionnel : Créer une table sous_compte_categories si nécessaire
                    // DB::table('sous_compte_categories')->insert([
                    //     'id_sous_compte' => $sousCompte->Id_Sous_compte,
                    //     'id_categorie_fonctionelle' => $intervalle->id_categorie_fonctionelle,
                    //     'actif' => true,
                    // ]);
                    
                    $totalSousComptesMappes++;
                }
            }
        }

        echo "\n🎉 MAPPING TERMINÉ !\n";
        echo "✅ {$totalComptesMappes} comptes mappés\n";
        echo "✅ {$totalSousComptesMappes} sous-comptes trouvés\n";
    }
}
