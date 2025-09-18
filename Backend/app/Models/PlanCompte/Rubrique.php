<?php

namespace App\Models\PlanCompte;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\PlanCompte\Classe; // importer le modèle Classe

class Rubrique extends Model
{
    use HasFactory;

    protected $table = 'rubriques';
    protected $primaryKey = 'Id_Rubrique';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'Code_rubrique',
        'Libelle',
        'Id_Classe',
    ];

    // Relation avec Classe
    public function classe()
    {
        return $this->belongsTo(Classe::class, 'Id_Classe', 'Id_Classe');
    }
}
