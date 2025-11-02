<?php

namespace App\Models\ParametresAnalytique;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\ParametresAnalytique\CentreAnalytique;
use App\Models\PlanCompte\SousCompte;
use App\Models\ParametresAnalytique\CodeAnalytique; // ← Ajout du modèle lié

class AffectationAnalytique extends Model
{
    use HasFactory;

    protected $table = 'affectationanalytique';
    protected $primaryKey = 'id_affectation';
    public $timestamps = false;

    protected $fillable = [
        'Id_Sous_compte',
        'id_centre',
        'description',
        'taux',
        'id_type',
        'id_code', // ← Ajout du champ lié au code analytique
    ];

    public function type()
    {
        return $this->belongsTo(TypeCentre::class, 'id_type');
    }

    public function centre()
    {
        return $this->belongsTo(CentreAnalytique::class, 'id_centre');
    }

    public function sousCompte()
    {
        return $this->belongsTo(SousCompte::class, 'Id_Sous_compte');
    }

    public function codeAnalytique()
    {
        return $this->belongsTo(CodeAnalytique::class, 'id_code');
    }
}
