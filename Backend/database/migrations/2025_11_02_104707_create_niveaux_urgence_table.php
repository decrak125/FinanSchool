<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
{
    Schema::create('niveaux_urgence', function (Blueprint $table) {
        $table->id();
        $table->string('code', 50)->unique();
        $table->string('nom', 100);
        $table->string('icone', 50);
        $table->string('couleur', 20);
        $table->integer('ordre');
        // $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('niveaux_urgence');
    }
};
