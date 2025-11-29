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
       Schema::create('categorie_fonctionelles', function (Blueprint $table) {
            $table->id('id_categorie_fonctionelle');
            $table->string('code', 50)->unique();
            $table->string('libelle', 255);
            $table->boolean('calcul_auto')->default(true);
            $table->foreignId('id_duree')->constrained('durees','id_duree');
            $table->foreignId('id_fonction_economique')->constrained('fonction_economiques','id_fonction_economique');
            $table->foreignId('id_nature_comptable')->constrained('nature_comptables','id_nature_comptable');
            $table->foreignId('id_type_categorie')->constrained('type_categories','id_type_categorie');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('categorie_fonctionelles');
    }
};
