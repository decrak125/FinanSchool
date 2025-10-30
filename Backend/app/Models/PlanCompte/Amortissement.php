<?php
namespace App\Models\PlanCompte;

use Illuminate\Database\Eloquent\Model;

class Amortissement extends Model
{
    protected $table = 'immobilisations';
    protected $fillable = [
        'libelle',
        'Id_Sous_compte',
        'taux_amortissement_id',
        'valeur_brute',
        'date_acquisition',
        'date_debut_utilisation'
    ];

    public function sousCompte()
    {
        return $this->belongsTo(SousCompte::class, 'Id_Sous_compte');
    }

    public function tauxAmortissement()
    {
        return $this->belongsTo(TauxAmortissement::class, 'taux_amortissement_id');
    }
}
