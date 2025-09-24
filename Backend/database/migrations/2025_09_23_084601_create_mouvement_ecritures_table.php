<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('mouvement_ecritures', function (Blueprint $table) {
            $table->id('Id_Mouvement_ecriture');
            $table->date('Date_mouvement');
            $table->string('Numero_piece', 50)->nullable()->unique();
            $table->foreignId('Id_Journal')->constrained('journals', 'Id_Journal');
            // $table->timestamps();
        });
    }

    public function down(): void {
        Schema::dropIfExists('mouvement_ecritures');
    }
};
