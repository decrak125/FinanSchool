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
       Schema::table('affectationanalytique', function (Blueprint $table) {
          $table->foreignId('id_code')
                ->after('Id_Sous_compte')
                ->nullable()
                ->constrained('code_analytique', 'id_code')
                ->onDelete('cascade');
});

    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('affectationanalytique', function (Blueprint $table) {
            //
        });
    }
};
