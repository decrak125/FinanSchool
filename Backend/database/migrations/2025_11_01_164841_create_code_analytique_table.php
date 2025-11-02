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
        Schema::create('code_analytique', function (Blueprint $table) {
            $table->id('id_code');
            $table->string('code', 10)->unique();
            $table->string('libelle', 150);
            $table->string('plage_de_extension', 20)->nullable();
});

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('code_analytique');
    }
};
