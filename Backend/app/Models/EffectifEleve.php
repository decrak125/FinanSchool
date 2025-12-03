<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use App\Models\exercice\ExerciceComptable;

class EffectifEleve extends Model
{
    use HasFactory;

    /**
     * Le nom de la table associée au modèle.
     *
     * @var string
     */
    protected $table = 'effectif_eleve';

    /**
     * La clé primaire de la table.
     *
     * @var string
     */
    protected $primaryKey = 'id';
     public $timestamps = false;
    /**
     * Les attributs qui sont assignables en masse.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'Id_Exercice_comptable',
        'nombre_eleves',
    ];
    
    /**
     * Les attributs qui doivent être convertis.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'nombre_eleves' => 'integer',
    ];

    /**
     * Relation avec l'exercice comptable.
     *
     * @return \Illuminate\Database\Eloquent\Relations\BelongsTo
     */
    public function exerciceComptable(): BelongsTo
    {
        return $this->belongsTo(ExerciceComptable::class, 'Id_Exercice_comptable', 'Id_Exercice_comptable');
    }
}