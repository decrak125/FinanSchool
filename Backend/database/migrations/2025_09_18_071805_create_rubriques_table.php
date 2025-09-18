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
        Schema::create('rubriques', function (Blueprint $table) {
            $table->id('Id_Rubrique');
            $table->string('Code_rubrique', 2)->unique();
            $table->string('Libelle', 255);
            $table->foreignId('Id_Classe')
                ->constrained('classes', 'Id_Classe')
                ->onDelete('cascade');
            $table->timestamps();
    });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rubriques');
    }
};
