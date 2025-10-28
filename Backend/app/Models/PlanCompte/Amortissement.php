<?php
namespace App\Models\PlanCompte;

use Illuminate\Database\Eloquent\Model;

class Amortissement extends Model
{
    protected $table = 'amortissements';
    protected $fillable = [
        'Id_Sous_compte',
        'taux_amortissement_id',
        'date_amortissement',
        'exercice',
        'montant',
        'cumul',
        'is_exceptionnel',
        'commentaire'
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
