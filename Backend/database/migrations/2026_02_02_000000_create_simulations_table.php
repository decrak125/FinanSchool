<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('simulations', function (Blueprint $table) {
            $table->id('id_simulation');
            $table->string('nom_simulation');
            $table->dateTime('date_simulation')->useCurrent();
            $table->text('description')->nullable();
            $table->foreignId('id_exercice_comptable')->constrained('exercice_comptable', 'Id_Exercice_comptable')->onDelete('cascade');
            $table->timestamps();
        });

        Schema::create('simulation_lignes', function (Blueprint $table) {
            $table->id('id_simulation_ligne');
            $table->foreignId('id_simulation')->constrained('simulations', 'id_simulation')->onDelete('cascade');
            $table->string('libelle');
            $table->enum('type', ['produit', 'charge']);
            $table->enum('nature_charge', ['fixe', 'variable'])->default('fixe');
            $table->decimal('moyenne_historique', 15, 2)->default(0);
            $table->decimal('coefficient', 5, 2)->default(1);
            $table->decimal('montant_simule', 15, 2);
            $table->foreignId('id_sous_compte')->nullable()->constrained('sous_comptes', 'Id_Sous_compte')->onDelete('set null');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('simulation_lignes');
        Schema::dropIfExists('simulations');
    }
};
