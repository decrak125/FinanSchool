<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class TypesEvenementSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $types = [
            [
                'code' => 'ERREUR_IMPORT',
                'nom' => 'Erreur Import',
                'description' => 'Erreur lors de l\'import de fichiers',
                'est_actif' => true,
            ],
            [
                'code' => 'SUCCES_IMPORT',
                'nom' => 'Succès Import', 
                'description' => 'Import terminé avec succès',
                'est_actif' => true,
            ],
            [
                'code' => 'ALERTE_SYSTEME',
                'nom' => 'Alerte Système',
                'description' => 'Alerte système critique',
                'est_actif' => true,
            ],
            [
                'code' => 'NOTIFICATION_METIER',
                'nom' => 'Notification Métier',
                'description' => 'Notification concernant le métier',
                'est_actif' => true,
            ],
            [
                'code' => 'CLOTURE_EXERCICE_PROCHE',
                'nom' => 'Clôture Exercice Proche',
                'description' => 'Alerte à l\'approche de la clôture de l\'exercice comptable',
                'est_actif' => true,
            ],
        ];

        DB::table('types_evenement')->insert($types);
        
        $this->command->info('Types d\'événement créés avec succès!');
    }
}