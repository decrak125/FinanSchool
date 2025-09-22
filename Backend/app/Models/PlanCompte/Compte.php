<?php

namespace App\Models\PlanCompte;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\PlanCompte\Rubrique;

class Compte extends Model
{
    use HasFactory;

    protected $table = 'comptes';
    protected $primaryKey = 'Id_Compte';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'Code_compte',
        'Libelle',
        'Id_Rubrique',
    ];

    // Relation avec Rubrique
    public function rubrique()
    {
        return $this->belongsTo(Rubrique::class, 'Id_Rubrique', 'Id_Rubrique');
    }
    // Mutator pour générer Code_sous_compte automatiquement
    // public static function boot()
    // {
    //     parent::boot();

    //     static::creating(function ($sousCompte) {
    //         if (isset($sousCompte->suffixe)) {
    //             $compte = $sousCompte->compte()->first();
    //             if ($compte) {
    //                 $sousCompte->Code_sous_compte = $compte->Code_Compte . $sousCompte->suffixe;
    //             }
    //         }
    //     });

    //     static::updating(function ($sousCompte) {
    //         if (isset($sousCompte->suffixe)) {
    //             $compte = $sousCompte->compte()->first();
    //             if ($compte) {
    //                 $sousCompte->Code_sous_compte = $compte->Code_Compte . $sousCompte->suffixe;
    //             }
    //         }
    //     });
    // }
}
