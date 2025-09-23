<?php

namespace App\Models\Saisie;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Journal extends Model
{
    use HasFactory;

    protected $table = 'journals';
    protected $primaryKey = 'Id_Journal';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'Code',
        'Libelle',
        'Id_Type_Journal',
        'Id_Sous_compte',
    ];

    public function typeJournal() {
        return $this->belongsTo(TypeJournal::class, 'Id_Type_Journal');
    }

    public function sousCompte() {
        return $this->belongsTo(SousCompte::class, 'Id_Sous_compte');
    }

    public function mouvements() {
        return $this->hasMany(MouvementEcriture::class, 'Id_Journal');
    }

    public function lignes() {
        return $this->hasMany(LigneEcriture::class, 'Id_Journal');
    }
}
