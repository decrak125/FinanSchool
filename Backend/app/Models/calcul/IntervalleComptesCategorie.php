<?php

namespace App\Models\calcul;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class IntervalleComptesCategorie extends Model
{
    use HasFactory;

    /**
     * Le nom de la table associée au modèle.
     *
     * @var string
     */
    protected $table = 'intervalle_comptes_categorie';

    /**
     * Les attributs qui sont assignables en masse.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'compte_debut',
        'compte_fin',
        'id_categorie_fonctionelle',
    ];

    /**
     * Les attributs qui doivent être cachés pour la sérialisation.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        // Ajoutez ici les champs à cacher si nécessaire
    ];

    /**
     * Les attributs qui doivent être convertis.
     *
     * @var array<string, string>
     */
    protected $casts = [
        // Ajoutez les casts si nécessaire
    ];

    /**
     * Indique si le modèle doit avoir des timestamps.
     *
     * @var bool
     */
    public $timestamps = false;

    /**
     * Relation avec le modèle CategorieFonctionelle
     */
    public function categorieFonctionelles()
    {
        return $this->belongsTo(CategorieFonctionelles::class, 'id_categorie_fonctionelle', 'id_categorie_fonctionelle');
    }
}
