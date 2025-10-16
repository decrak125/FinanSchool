<?php

namespace App\Models\exercice;

use Illuminate\Database\Eloquent\Model;
use Carbon\Carbon;

class ExerciceComptable extends Model
{
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
     * Récupère l'exercice actuellement ouvert
     */
    public static function getExerciceOuvert()
    {
        return self::where('Statut', 'OUVERT')->first();
    }

    /**
     * Récupère l'exercice contenant une date donnée
     */
    public static function getExerciceByDate($date)
    {
        return self::whereDate('Date_debut', '<=', $date)
            ->whereDate('Date_fin', '>=', $date)
            ->first();
    }

    /**
     * Récupère tous les exercices (pour dropdown/sélection)
     */
    public static function getAllExercices()
    {
        return self::orderBy('Annee_fiscale', 'desc')->get();
    }

    /**
     * Vérifie si l'exercice est ouvert
     */
    public function isOuvert()
    {
        return $this->Statut === 'OUVERT';
    }

    /**
     * Vérifie si l'exercice est clôturé
     */
    public function isCloture()
    {
        return $this->Statut === 'CLOTURE';
    }

    /**
     * Fermer l'exercice
     */
    public function cloturer()
    {
        $this->Statut = 'CLOTURE';
        $this->save();
    }

    /**
     * Ouvrir l'exercice
     */
    public function ouvrir()
    {
        // Fermer tous les autres exercices ouverts
        self::where('Statut', 'OUVERT')->update(['Statut' => 'CLOTURE']);
        
        $this->Statut = 'OUVERT';
        $this->save();
    }
}
