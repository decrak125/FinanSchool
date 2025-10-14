<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('intervalle_comptes_categorie', function (Blueprint $table) {
            $table->id();
            $table->string('compte_debut', 10);
            $table->string('compte_fin', 10);
            $table->foreignId('id_categorie_fonctionelle')
                  ->constrained('categorie_fonctionelles', 'id_categorie_fonctionelle');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('intervalle_comptes_categorie');
    }
};
