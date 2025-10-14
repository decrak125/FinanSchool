<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('exercice_comptable', function (Blueprint $table) {
            $table->id('Id_Exercice_comptable');
            $table->date('Date_debut')->unique();
            $table->date('Date_fin')->unique();
            $table->enum('Statut', ['OUVERT', 'CLOTURE', 'PROVISOIRE'])->default('OUVERT');
            $table->smallInteger('Annee_fiscale');
            $table->timestamps();
            
            // Contrainte pour s'assurer que la date de fin est après la date de début
            $table->check('Date_fin > Date_debut');
        });

        // Contrainte d'année fiscale via DB::statement (pour PostgreSQL)
        DB::statement('ALTER TABLE exercice_comptable ADD CONSTRAINT chk_annee_fiscale CHECK (Annee_fiscale BETWEEN 2000 AND 2100)');
        
        // Index
        Schema::table('exercice_comptable', function (Blueprint $table) {
            $table->index('Annee_fiscale');
            $table->index('Statut');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('exercice_comptable');
    }
};