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
        Schema::create('axesanalytique', function (Blueprint $table) {
            $table->id('id_axe'); // clé primaire auto-incrémentée
            $table->string('axe', 100); // nom de l'axe
            $table->string('description', 255)->nullable(); // description optionnelle
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('axesanalytique');
    }
};
