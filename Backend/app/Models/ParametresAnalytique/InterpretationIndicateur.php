<?php

namespace App\Models\ParametresAnalytique;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class InterpretationIndicateur extends Model
{
    use HasFactory;


    protected $table = 'interpretation_indicateur';


    protected $primaryKey = 'id_interpretation_indicateur';


    public $incrementing = true;


    protected $keyType = 'int';


    public $timestamps = false;


    protected $fillable = [
        'id_indicateur_analytique',
        'valeur',
        'interpretation',
        'id_niveau_alerte'
    ];


    protected $casts = [
        'valeur' => 'decimal:2'
    ];


    public function indicateurAnalytique()
    {
        return $this->belongsTo(IndicateurAnalytique::class, 'id_indicateur_analytique');
    }


    public function niveauAlerte()
    {
        return $this->belongsTo(NiveauAlerte::class, 'id_niveau_alerte');
    }
}