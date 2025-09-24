<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('affectationanalytique', function (Blueprint $table) {
            $table->id('id_affectation');  // Clé primaire
            $table->string('description', 255)->nullable(); // Description optionnelle

            // Relations
            $table->foreignId('id_centre')->constrained('centreanalytique', 'id_centre')->onDelete('cascade');
            $table->foreignId('Id_Sous_compte')->constrained('sous_comptes', 'Id_Sous_compte')->onDelete('cascade');

            // Pas de timestamps
            // $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('affectationanalytique');
    }
};
