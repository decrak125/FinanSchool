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
        Schema::create('compte_categories', function (Blueprint $table) {
            $table->id('id_compte_categorie');
            $table->decimal('poids', 15, 2)->default(1);
            $table->date('date_debut');
            $table->date('date_fin')->nullable();
            $table->boolean('actif')->nullable();
            $table->foreignId('id_sous_compte')->constrained('sous_comptes','Id_Sous_compte');
            $table->foreignId('id_categorie_fonctionelle')->constrained('categorie_fonctionelles','id_categorie_fonctionelle');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('compte_categories');
    }
};
