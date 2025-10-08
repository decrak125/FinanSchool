<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('affectationanalytique', function (Blueprint $table) {
            // Supprimer la contrainte unique sur Id_Sous_compte
            $table->dropUnique(['Id_Sous_compte']);

            // Ajouter la colonne taux avec une valeur par défaut de 100
            $table->decimal('taux', 5, 2)->comment('Pourcentage du coût affecté (0-100)');
        });
    }

    public function down(): void
    {
        Schema::table('affectationanalytique', function (Blueprint $table) {
            $table->dropColumn('taux');
            $table->unique('Id_Sous_compte');
        });
    }
};
