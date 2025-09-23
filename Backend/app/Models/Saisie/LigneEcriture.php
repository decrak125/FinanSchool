<?php

namespace App\Models\Saisie;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class LigneEcriture extends Model
{
    use HasFactory;

    protected $table = 'ligne_ecritures';
    protected $primaryKey = 'Id_Ligne_ecriture';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'Libelle',
        'Debit',
        'Credit',
        'Reference',
        'Quantite',
        'Id_Mode_paiement',
        'Id_Mouvement_ecriture',
        'Id_Journal',
        'Id_Sous_compte',
    ];

    public function modePaiement() {
        return $this->belongsTo(ModePaiement::class, 'Id_Mode_paiement');
    }

    public function mouvement() {
        return $this->belongsTo(MouvementEcriture::class, 'Id_Mouvement_ecriture');
    }

    public function journal() {
        return $this->belongsTo(Journal::class, 'Id_Journal');
    }

    public function sousCompte() {
        return $this->belongsTo(SousCompte::class, 'Id_Sous_compte');
    }
}
