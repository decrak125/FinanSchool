<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
       Schema::create('immobilisations', function (Blueprint $table) {
    $table->id();
    $table->string('libelle');
    $table->foreignId('Id_Sous_compte')->constrained('sous_comptes', 'Id_Sous_compte')->onDelete('cascade');
    $table->foreignId('taux_amortissement_id')->constrained('taux_amortissement')->onDelete('restrict');
    $table->decimal('valeur_brute', 19, 2);
    $table->date('date_acquisition');
    $table->date('date_debut_utilisation')->nullable();
    $table->timestamps();
});

    }
    public function down(): void
    {
        Schema::dropIfExists('amortissements');
    }
};
