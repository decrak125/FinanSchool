<?php

namespace App\Models\calcul;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CategorieFonctionelle extends Model
{
    use HasFactory;

    /**
     * Le nom de la table associée au modèle.
     *
     * @var string
     */
    protected $table = 'categorie_fonctionelles';

    /**
     * La clé primaire associée à la table.
     *
     * @var string
     */
    protected $primaryKey = 'id_categorie_fonctionelle';

    /**
     * Les attributs qui sont assignables en masse.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'code',
        'libelle',
        'calcul_auto',
        'id_duree',
        'id_fonction_economique',
        'id_nature_comptable',
        'id_type_categorie',
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
        'calcul_auto' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    /**
     * Relation avec le modèle Duree
     */
    public function duree()
    {
        return $this->belongsTo(Duree::class, 'id_duree', 'id_duree');
    }

    /**
     * Relation avec le modèle FonctionEconomique
     */
    public function fonctionEconomique()
    {
        return $this->belongsTo(FonctionEconomique::class, 'id_fonction_economique', 'id_fonction_economique');
    }

    /**
     * Relation avec le modèle NatureComptable
     */
    public function natureComptable()
    {
        return $this->belongsTo(NatureComptable::class, 'id_nature_comptable', 'id_nature_comptable');
    }

    /**
     * Relation avec le modèle TypeCategorie
     */
    public function typeCategorie()
    {
        return $this->belongsTo(TypeCategorie::class, 'id_type_categorie', 'id_type_categorie');
    }
}
