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
    Schema::create('notifications', function (Blueprint $table) {
        $table->id();
        $table->foreignId('evenement_id')->constrained('evenements');
        $table->foreignId('niveau_urgence_id')->constrained('niveaux_urgence');
        $table->string('titre', 255);
        $table->text('message');
        $table->enum('statut', ['non_lu', 'lu', 'archive'])->default('non_lu');
        $table->timestamp('lu_a')->nullable();
        $table->timestamps();
    });
}

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
