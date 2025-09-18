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
        Schema::create('comptes', function (Blueprint $table) {
            $table->id('Id_Compte');
            $table->string('Code_compte', 3)->unique();
            $table->string('Libelle', 255);
            $table->foreignId('Id_Rubrique')
                ->constrained('rubriques', 'Id_Rubrique')
                ->onDelete('cascade');
            // $table->timestamps();
});

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('comptes');
    }
};
