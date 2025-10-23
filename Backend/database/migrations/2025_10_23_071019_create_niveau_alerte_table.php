<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('niveau_alerte', function (Blueprint $table) {
            $table->id('id_niveau_alerte');
            $table->string('libelle', 100); // ex: Faible, Moyen, Élevé
            $table->string('couleur', 20);  // ex: #ff0000 ou 'rouge'
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('niveau_alerte');
    }
};
