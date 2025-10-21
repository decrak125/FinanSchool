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
        Schema::create('import_histories', function (Blueprint $table) {
    $table->id();
    $table->string('nom_fichier');
    $table->timestamp('imported_at')->useCurrent();
    $table->unsignedBigInteger('imported_by')->nullable(); // user_id
    $table->integer('nombre_mouvements')->default(0);
    $table->integer('nombre_lignes')->default(0);
    $table->enum('statut', ['réussi', 'échec']);
    $table->text('erreur')->nullable();
    $table->timestamps();
});

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('import_histories');
    }
};
