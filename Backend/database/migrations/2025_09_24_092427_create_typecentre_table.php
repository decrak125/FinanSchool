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
        Schema::create('typecentre', function (Blueprint $table) {
            $table->id('id_type'); // clé primaire auto-incrémentée
            $table->string('code', 50)->unique(); // code unique
            $table->string('libelle', 100); // libelle du type
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('typecentre');
    }
};
