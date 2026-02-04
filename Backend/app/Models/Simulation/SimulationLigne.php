<?php

namespace App\Models\Simulation;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\PlanCompte\SousCompte;

class SimulationLigne extends Model
{
    use HasFactory;

    protected $table = 'simulation_lignes';
    protected $primaryKey = 'id_simulation_ligne';

    protected $fillable = [
        'id_simulation',
        'libelle',
        'type',
        'nature_charge',
        'moyenne_historique',
        'coefficient',
        'montant_simule',
        'id_sous_compte'
    ];

    public function simulation()
    {
        return $this->belongsTo(Simulation::class, 'id_simulation', 'id_simulation');
    }

    public function sousCompte()
    {
        return $this->belongsTo(SousCompte::class, 'id_sous_compte', 'Id_Sous_compte');
    }
}
