<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class ExerciceComptableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     * Exercices comptables du 1er juillet au 30 juin, de 2018 à 2038
     * Seul l'exercice courant (contenant la date actuelle) est OUVERT
     */
    public function run(): void
    {
        $exercices = [];
        $dateActuelle = Carbon::now();

        // Générer les exercices de 2018 à 2038
        for ($annee = 2018; $annee <= 2038; $annee++) {
            $dateDebut = Carbon::create($annee, 7, 1);
            $dateFin = Carbon::create($annee + 1, 6, 30);

            // Déterminer le statut : OUVERT si la date actuelle est dans la période, sinon CLOTURE
            $statut = ($dateActuelle->between($dateDebut, $dateFin)) ? 'OUVERT' : 'CLOTURE';

            $exercices[] = [
                'Date_debut' => $dateDebut->format('Y-m-d'),
                'Date_fin' => $dateFin->format('Y-m-d'),
                'Statut' => $statut,
                'Annee_fiscale' => $annee,
                'created_at' => now(),
                'updated_at' => now(),
            ];
        }

        // Insertion en base
        DB::table('exercice_comptable')->insert($exercices);

        // Afficher l'exercice ouvert
        $exerciceOuvert = collect($exercices)->firstWhere('Statut', 'OUVERT');
        if ($exerciceOuvert) {
            $this->command->info('✅ ' . count($exercices) . ' exercices comptables créés (2018-2038)');
            $this->command->info('📅 Exercice OUVERT : ' . $exerciceOuvert['Annee_fiscale'] . 
                ' (' . $exerciceOuvert['Date_debut'] . ' → ' . $exerciceOuvert['Date_fin'] . ')');
        } else {
            $this->command->warn('⚠️ Aucun exercice ouvert (date actuelle hors période)');
        }
    }
}
