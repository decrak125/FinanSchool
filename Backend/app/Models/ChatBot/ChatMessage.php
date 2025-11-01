<?php

namespace App\Models\ChatBot;

use Illuminate\Database\Eloquent\Model;
use App\Models\User;

class ChatMessage extends Model
{
    protected $fillable = [
        'message', 
        'response', 
        'session_id',
        'user_id'
    ];

    /**
     * Relation avec l'utilisateur
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
