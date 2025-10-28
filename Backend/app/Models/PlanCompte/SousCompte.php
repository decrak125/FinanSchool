<?php

namespace App\Models\PlanCompte;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\PlanCompte\Compte;

class SousCompte extends Model
{
    use HasFactory;

    protected $table = 'sous_comptes';
    protected $primaryKey = 'Id_Sous_compte';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'Code_sous_compte',
        'Libelle',
        'Id_Compte',
    ];

    // Relation avec Compte
    public function compte()
    {
        return $this->belongsTo(Compte::class, 'Id_Compte', 'Id_Compte');
    }

     public function amortissements()
    {
        return $this->hasMany(Amortissement::class, 'Id_Sous_compte');
    }
}
