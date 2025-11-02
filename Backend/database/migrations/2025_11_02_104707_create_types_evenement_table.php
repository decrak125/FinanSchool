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
    Schema::create('types_evenement', function (Blueprint $table) {
        $table->id();
        $table->string('code', 50)->unique();
        $table->string('nom', 100);
        $table->text('description')->nullable();
        $table->boolean('est_actif')->default(true);
        // $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('types_evenement');
    }
};
