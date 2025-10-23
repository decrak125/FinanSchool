<?php

namespace App\Models\ParametresAnalytique;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class IndicateurAnalytique extends Model
{
    use HasFactory;

    protected $table = 'indicateurs_analytique';

    protected $primaryKey = 'id_indicateur_analytique';

    public $incrementing = true;

    protected $keyType = 'int';

    public $timestamps = false;

    /**
     * Attributs assignables en masse
     */
    protected $fillable = [
        'libelle',
        'description',
        'formule'
    ];

    public function interpretations()
    {
        return $this->hasMany(InterpretationIndicateur::class, 'id_indicateur_analytique');
    }
}