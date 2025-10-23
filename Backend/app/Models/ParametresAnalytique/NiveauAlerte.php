<?php

namespace App\Models\ParametresAnalytique;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class NiveauAlerte extends Model
{
    use HasFactory;


    protected $table = 'niveau_alerte';

   
    protected $primaryKey = 'id_niveau_alerte';

    
    public $incrementing = true;

    
    protected $keyType = 'int';

    
    public $timestamps = false;

    
    protected $fillable = [
        'libelle',
        'couleur'
    ];

    
    public function interpretations()
    {
        return $this->hasMany(InterpretationIndicateur::class, 'id_niveau_alerte');
    }
}