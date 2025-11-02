<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class NiveauxUrgenceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run()
{
    DB::table('niveaux_urgence')->insert([
        [
            'code' => 'info',
            'nom' => 'Information',
            'icone' => 'bi bi-bell-fill',
            'couleur' => '#01CC00',
            'ordre' => 1,
            'created_at' => now(),
            'updated_at' => now(),
        ],
        [
            'code' => 'avertissement',
            'nom' => 'Avertissement',
            'icone' => 'bi bi-exclamation-circle-fill',
            'couleur' => '#F89400',
            'ordre' => 2,
            'created_at' => now(),
            'updated_at' => now(),
        ],
        [
            'code' => 'urgent',
            'nom' => 'Urgent',
            'icone' => 'bi bi-x-circle-fill',
            'couleur' => '#FE0000',
            'ordre' => 3,
            'created_at' => now(),
            'updated_at' => now(),
        ],
    ]);
}
}
