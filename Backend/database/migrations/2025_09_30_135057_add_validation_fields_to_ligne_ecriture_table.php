<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('ligne_ecritures', function (Blueprint $table) {
            // ✅ Nouveau champ pour le statut
            $table->enum('statut', ['brouillon', 'valide', 'annule'])
                  ->default('brouillon')
                  ->after('Id_Sous_compte');

            // ✅ Date de validation
            $table->timestamp('date_validation')
                  ->nullable()
                  ->after('statut');

            // ✅ Utilisateur qui a validé (optionnel)
            $table->unsignedBigInteger('valide_par')
                  ->nullable()
                  ->after('date_validation');

            // Clé étrangère vers table users
            $table->foreign('valide_par')
                  ->references('id')
                  ->on('users')
                  ->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('Ligne_ecriture', function (Blueprint $table) {
            $table->dropForeign(['valide_par']);
            $table->dropColumn(['statut', 'date_validation', 'valide_par']);
        });
    }
};
