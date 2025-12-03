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
        Schema::create('effectif_eleve', function (Blueprint $table) {
            $table->id();
            $table->foreignId('Id_Exercice_comptable')
                    ->constrained('exercice_comptable', 'Id_Exercice_comptable')
                  ->onDelete('cascade')
                  ->onUpdate('cascade');
            $table->integer('nombre_eleves')->default(0);
            $table->unique('Id_Exercice_comptable');

            // Index pour la clé étrangère
            $table->index('Id_Exercice_comptable');
        });

        // Optionnel : Ajouter une contrainte pour nombre_eleves >= 0
         DB::statement('ALTER TABLE effectif_eleve ADD CONSTRAINT chk_nombre_eleves CHECK (nombre_eleves >= 0)');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('effectif_eleve');
    }
};