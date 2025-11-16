<?php

namespace App\Models\PlanCompte;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ExerciceComptable extends Model
{
    use HasFactory;

    protected $table = 'exercice_comptable';
    protected $primaryKey = 'Id_Exercice_comptable';
    
    protected $fillable = [
        'Date_debut',
        'Date_fin', 
        'Statut',
        'Annee_fiscale'
    ];
    
    protected $casts = [
        'Date_debut' => 'date',
        'Date_fin' => 'date',
    ];
    
    /**
     * Scope pour les exercices ouverts
     */
    public function scopeOuvert($query)
    {
        return $query->where('Statut', 'OUVERT');
    }
    
    /**
     * Scope pour un année fiscale spécifique
     */
    public function scopeAnneeFiscale($query, $annee)
    {
        return $query->where('Annee_fiscale', $annee);
    }
}