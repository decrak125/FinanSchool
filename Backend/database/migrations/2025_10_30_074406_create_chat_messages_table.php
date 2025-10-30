<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('chat_messages', function (Blueprint $table) {
            $table->id();
            $table->text('message');          // Message de l'utilisateur
            $table->text('response')->nullable(); // Réponse du bot
            $table->string('session_id');     // Identifiant de session
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('cascade');
            $table->timestamps();             // created_at et updated_at
            
            // Index pour améliorer les performances
            $table->index('session_id');
            $table->index('user_id');
        });
    }

    public function down()
    {
        Schema::dropIfExists('chat_messages');
    }
};