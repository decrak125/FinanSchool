<?php

namespace App\Models\notifications;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Evenement extends Model
{
    use HasFactory;

    protected $table = 'evenements';
    public $timestamps = false;

    protected $fillable = [
        'type_evenement_id',
        'donnees_evenement'
    ];

    protected $casts = [
        'donnees_evenement' => 'array'
    ];

    public function typeEvenement()
    {
        return $this->belongsTo(TypeEvenement::class);
    }

    public function notification()
    {
        return $this->hasOne(Notification::class);
    }
}