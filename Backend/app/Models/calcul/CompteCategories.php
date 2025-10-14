<?php

namespace App\Models\calcul;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\PlanCompte\SousCompte;

class CompteCategories extends Model
{
    use HasFactory;

    /**
     * Le nom de la table associée au modèle.
     *
     * @var string
     */
    protected $table = 'compte_categories';

    /**
     * La clé primaire associée à la table.
     *
     * @var string
     */
    protected $primaryKey = 'id_compte_categorie';

    /**
     * Les attributs qui sont assignables en masse.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'poids',
        'date_debut',
        'date_fin',
        'actif',
        'id_sous_compte',
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
        'poids' => 'decimal:2',
        'date_debut' => 'date',
        'date_fin' => 'date',
        'actif' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relation avec le modèle SousCompte
     */
    public function sousCompte()
    {
        return $this->belongsTo(SousCompte::class, 'id_sous_compte', 'Id_Sous_compte');
    }

    /**
     * Relation avec le modèle CategorieFonctionelle
     */
    public function categorieFonctionelles()
    {
        return $this->belongsTo(CategorieFonctionelles::class, 'id_categorie_fonctionelle', 'id_categorie_fonctionelle');
    }
}
