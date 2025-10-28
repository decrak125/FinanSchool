<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('amortissements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('Id_Sous_compte')
                  ->constrained('sous_comptes', 'Id_Sous_compte')
                  ->onDelete('cascade');
            $table->foreignId('taux_amortissement_id')
                  ->constrained('taux_amortissement')
                  ->onDelete('restrict');
            $table->date('date_amortissement');
            $table->integer('exercice');
            $table->decimal('montant', 19, 2);
            $table->decimal('cumul', 19, 2)->default(0);
            $table->boolean('is_exceptionnel')->default(false);
            $table->text('commentaire')->nullable();
            $table->timestamps();
        });
    }
    public function down(): void
    {
        Schema::dropIfExists('amortissements');
    }
};
