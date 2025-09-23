<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('devises', function (Blueprint $table) {
            $table->id('Id_Devise');
            $table->string('Libelle', 100);
            $table->string('Code', 10)->unique();
            $table->string('Sigle', 10)->unique();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('devises');
    }
};
