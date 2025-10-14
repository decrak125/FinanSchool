<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\calcul\Duree;

class DureeSeeder extends Seeder
{
    public function run(): void
    {
        $durees = [
            ['code' => 'CT', 'libelle' => 'Court terme'],
            ['code' => 'LT', 'libelle' => 'Long terme'],
            ['code' => 'MIXTE', 'libelle' => 'Mixte'],
        ];

        foreach ($durees as $duree) {
            Duree::create($duree);
        }
    }
}