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
        Schema::create('sous_comptes', function (Blueprint $table) {
            $table->id('Id_Sous_compte');
            $table->string('Code_sous_compte', 6)->unique();
            $table->string('Libelle', 255);
            $table->foreignId('Id_Compte')
                ->constrained('comptes', 'Id_Compte')
                ->onDelete('cascade');
            $table->timestamps();
        });

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('sous_comptes');
    }
};
