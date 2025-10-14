<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\calcul\TypeCategories;

class TypeCategoriesSeeder extends Seeder
{
    public function run(): void
    {
        $types = [
            ['code_type' => 'BILAN', 'libelle' => 'Comptes de bilan'],
            ['code_type' => 'GESTION', 'libelle' => 'Comptes de gestion'],
        ];

        foreach ($types as $type) {
            TypeCategories::create($type);
        }
    }
}
