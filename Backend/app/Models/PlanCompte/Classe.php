<?php

namespace App\Models\PlanCompte;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Classe extends Model
{
    use HasFactory;

    // Table associée
    protected $table = 'classes';

    // Clé primaire
    protected $primaryKey = 'Id_Classe';

    // Indique si la clé primaire est auto-incrémentée
    public $incrementing = true;

    // Type de la clé primaire
    protected $keyType = 'int';

    // Pas de timestamps dans ta table
    public $timestamps = false;

    // Champs modifiables
    protected $fillable = [
        'Code',
        'Libelle',
    ];
}
