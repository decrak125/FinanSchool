<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\calcul\FonctionEconomiques;

class FonctionEconomiquesSeeder extends Seeder
{
    public function run(): void
    {
        $fonctions = [
            ['code' => 'FINANCE', 'libelle' => 'Financement'],
            ['code' => 'INVEST', 'libelle' => 'Investissement'],
            ['code' => 'EXPLOIT', 'libelle' => 'Exploitation'],
            ['code' => 'TRESO', 'libelle' => 'Trésorerie'],
            ['code' => 'EXCEPT', 'libelle' => 'Exceptionnel'],
        ];

        foreach ($fonctions as $fonction) {
            FonctionEconomiques::create($fonction);
        }
    }
}
