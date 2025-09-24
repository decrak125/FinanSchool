<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('centreanalytique', function (Blueprint $table) {
            $table->id('id_centre');  // Clé primaire
            $table->string('nom', 100); // Nom du centre
            $table->string('description', 255)->nullable(); // Description optionnelle

            // Relations
            $table->foreignId('id_axe')->constrained('axesanalytique', 'id_axe')->onDelete('cascade');
            $table->foreignId('id_type')->constrained('typecentre', 'id_type')->onDelete('cascade');

            // Pas de timestamps
            // $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('centreanalytique');
    }
};
