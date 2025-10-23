<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class NiveauAlerteSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('niveau_alerte')->insert([
            ['libelle' => 'Mauvais', 'couleur' => '#FE0000'],
            ['libelle' => 'Moyen', 'couleur' => '#F89400'],
            ['libelle' => 'Bon', 'couleur' => '#01CC00'],
        ]);
    }
}
