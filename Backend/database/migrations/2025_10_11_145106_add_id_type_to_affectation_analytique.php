<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

class AddIdTypeToAffectationAnalytique extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Étape 1 : Ajouter la colonne id_type
        Schema::table('affectationanalytique', function (Blueprint $table) {
            $table->integer('id_type')->nullable()->after('id_centre');
        });

        // Étape 2 : Copier les id_type depuis CentreAnalytique
        DB::statement('
            UPDATE affectationanalytique 
            SET id_type = centreanalytique.id_type
            FROM centreanalytique 
            WHERE affectationanalytique.id_centre = centreanalytique.id_centre
        ');

        // Étape 3 : Rendre la colonne obligatoire
        Schema::table('affectationanalytique', function (Blueprint $table) {
            $table->integer('id_type')->nullable(false)->change();
            
            // Ajouter la clé étrangère
            $table->foreign('id_type')->references('id_type')->on('typecentre');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('affectationanalytique', function (Blueprint $table) {
            // Supprimer la clé étrangère d'abord
            $table->dropForeign(['id_type']);
            
            // Supprimer la colonne
            $table->dropColumn('id_type');
        });
    }
}