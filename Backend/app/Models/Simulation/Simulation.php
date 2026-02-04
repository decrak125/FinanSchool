<?php

namespace App\Models\Simulation;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\exercice\ExerciceComptable;

class Simulation extends Model
{
    use HasFactory;

    protected $table = 'simulations';
    protected $primaryKey = 'id_simulation';

    protected $fillable = [
        'nom_simulation',
        'date_simulation',
        'description',
        'id_exercice_comptable'
    ];

    public function lignes()
    {
        return $this->hasMany(SimulationLigne::class, 'id_simulation', 'id_simulation');
    }

    public function exercice()
    {
        return $this->belongsTo(ExerciceComptable::class, 'id_exercice_comptable', 'Id_Exercice_comptable');
    }
}
