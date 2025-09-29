<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void {
        Schema::create('journals', function (Blueprint $table) {
            $table->id('Id_Journal');
            $table->string('Code', 50)->unique();
            $table->string('Libelle', 50);
            $table->foreignId('Id_Type_Journal')->constrained('type_journals', 'Id_Type_Journal');
            $table->foreignId('Id_Sous_compte')->nullable()->constrained('sous_comptes', 'Id_Sous_compte');
            // $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('journals');
    }
};
