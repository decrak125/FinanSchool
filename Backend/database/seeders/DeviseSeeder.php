<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Saisie\Devise;

class DeviseSeeder extends Seeder
{
    public function run(): void
    {
        Devise::create([
            'Libelle' => 'Ariary',
            'Code' => 'MGA',
            'Sigle' => 'Ar',
        ]);
    }
}
