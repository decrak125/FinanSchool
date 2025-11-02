<?php

namespace App\Models\notifications;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class TypeEvenement extends Model
{
    use HasFactory;

    protected $table = 'types_evenement';
    
    protected $fillable = [
        'code',
        'nom',
        'description',
        'est_actif'
    ];

    protected $casts = [
        'est_actif' => 'boolean'
    ];

    public function evenements()
    {
        return $this->hasMany(Evenement::class);
    }
}