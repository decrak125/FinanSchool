<?php

namespace App\Models\notifications;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class NiveauUrgence extends Model
{
    use HasFactory;

    protected $table = 'niveaux_urgence';
    
    protected $fillable = [
        'code',
        'nom', 
        'icone',
        'couleur',
        'ordre'
    ];

    public function notifications()
    {
        return $this->hasMany(Notification::class);
    }
}