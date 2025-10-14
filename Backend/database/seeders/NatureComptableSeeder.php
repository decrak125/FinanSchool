<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\calcul\NatureComptable;

class NatureComptableSeeder extends Seeder
{
    public function run(): void
    {
        $natures = [
            ['code_nature' => 'ACTIF', 'libelle' => 'Actif'],
            ['code_nature' => 'PASSIF', 'libelle' => 'Passif'],
            ['code_nature' => 'CHARGE', 'libelle' => 'Charge'],
            ['code_nature' => 'PRODUIT', 'libelle' => 'Produit'],
            ['code_nature' => 'CP', 'libelle' => 'Capitaux propres'],
        ];

        foreach ($natures as $nature) {
            NatureComptable::create($nature);
        }
    }
}