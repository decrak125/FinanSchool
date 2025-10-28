<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\PlanCompte\TauxAmortissement;

class TauxAmortissementSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        TauxAmortissement::create([
            'intitule' => 'Matériel informatique',
            'taux' => 20.00,
            'duree' => 5,
            'unite_duree' => 'ans'
        ]);

        TauxAmortissement::create([
            'intitule' => 'Immobilier',
            'taux' => 2.50,
            'duree' => 40,
            'unite_duree' => 'ans'
        ]);

        TauxAmortissement::create([
            'intitule' => 'Mobilier de bureau',
            'taux' => 10.00,
            'duree' => 10,
            'unite_duree' => 'ans'
        ]);
    }
}
