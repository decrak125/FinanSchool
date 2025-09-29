<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
     public function up(): void {
        Schema::create('ligne_ecritures', function (Blueprint $table) {
            $table->id('Id_Ligne_ecriture');
            $table->string('Libelle', 255);
            $table->decimal('Debit', 15, 2);
            $table->decimal('Credit', 15, 2);
            $table->string('Reference', 50)->nullable();
            $table->integer('Quantite')->nullable();
            $table->foreignId('Id_Mode_paiement')->nullable()->constrained('mode_paiements', 'Id_Mode_paiement');
            $table->foreignId('Id_Mouvement_ecriture')->constrained('mouvement_ecritures', 'Id_Mouvement_ecriture');
            $table->foreignId('Id_Journal')->constrained('journals', 'Id_Journal');
            $table->foreignId('Id_Sous_compte')->constrained('sous_comptes', 'Id_Sous_compte');
            // $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ligne_ecritures');
    }
};
