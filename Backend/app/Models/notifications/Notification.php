<?php

namespace App\Models\notifications;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Notification extends Model
{
    use HasFactory;

    protected $table = 'notifications';
    public $timestamps = true;
    
    protected $fillable = [
        'evenement_id',
        'niveau_urgence_id',
        'titre',
        'message',
        'statut',
        'lu_a'
    ];

    protected $casts = [
        'lu_a' => 'datetime'
    ];

    public function evenement()
    {
        return $this->belongsTo(Evenement::class);
    }

    public function niveauUrgence()
    {
        return $this->belongsTo(NiveauUrgence::class);
    }

    // Scope pour les notifications non lues
    public function scopeNonLues($query)
    {
        return $query->where('statut', 'non_lu');
    }

    // Scope pour les notifications lues
    public function scopeLues($query)
    {
        return $query->where('statut', 'lu');
    }

    // Marquer comme lu
    public function marquerCommeLu()
    {
        $this->update([
            'statut' => 'lu',
            'lu_a' => now()
        ]);
    }
}