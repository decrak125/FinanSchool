<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('taux_amortissement', function (Blueprint $table) {
            $table->id();
            $table->string('intitule', 255); // Nom/type du taux (ex: Informatique, Véhicule...)
            $table->decimal('taux', 5, 2);   // Pourcentage d’amortissement annuel, ex: 20.00
            $table->integer('duree');        // Durée d’amortissement (années)
            $table->string('unite_duree')->default('ans'); // Unité, par défaut 'ans'
            $table->timestamps();            // Dates de création/modification
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('taux_amortissement');
    }
};
