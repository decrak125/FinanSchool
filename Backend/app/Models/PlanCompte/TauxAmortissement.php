<?php
namespace App\Models\PlanCompte;

use Illuminate\Database\Eloquent\Model;

class TauxAmortissement extends Model
{
    protected $table = 'taux_amortissement';
    protected $fillable = ['intitule', 'taux', 'duree', 'unite_duree'];
    public $timestamps = true;
}
