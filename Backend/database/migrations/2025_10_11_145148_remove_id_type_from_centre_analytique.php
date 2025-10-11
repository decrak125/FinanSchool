<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class RemoveIdTypeFromCentreAnalytique extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('centreanalytique', function (Blueprint $table) {
            // Supprimer la clé étrangère d'abord
            $table->dropForeign(['id_type']);
            
            // Supprimer la colonne
            $table->dropColumn('id_type');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('centreanalytique', function (Blueprint $table) {
            // Recréer la colonne
            $table->integer('id_type')->nullable();
            
            // Remettre la clé étrangère
            $table->foreign('id_type')->references('id_type')->on('typecentre');
            
            // Note: Tu devras peut-être re-remplir les données manuellement dans le down()
            // ou garder une sauvegarde des anciennes valeurs
        });
    }
}