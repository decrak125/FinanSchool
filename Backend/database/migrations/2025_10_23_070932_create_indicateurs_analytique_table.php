<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('indicateurs_analytique', function (Blueprint $table) {
            $table->id('id_indicateur_analytique');
            $table->string('libelle', 255);
            $table->text('description');
            $table->text('formule');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('indicateurs_analytique');
    }
};
