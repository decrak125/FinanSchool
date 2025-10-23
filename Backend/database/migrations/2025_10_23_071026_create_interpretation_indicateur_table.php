<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('interpretation_indicateur', function (Blueprint $table) {
            $table->id('id_interpretation_indicateur');
            $table->foreignId('id_indicateur_analytique')
                ->constrained('indicateurs_analytique', 'id_indicateur_analytique')
                ->onDelete('cascade');

            $table->decimal('valeur', 10, 2);
            $table->text('interpretation');

            $table->foreignId('id_niveau_alerte')
                ->constrained('niveau_alerte', 'id_niveau_alerte')
                ->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('interpretation_indicateur');
    }
};
