<?php

namespace App\Models\Saisie;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MouvementEcriture extends Model
{
    use HasFactory;

    protected $table = 'mouvement_ecritures';
    protected $primaryKey = 'Id_Mouvement_ecriture';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'Date_mouvement',
        'Numero_piece',
        'Id_Journal',
    ];
    
    public function journal() {
        return $this->belongsTo(Journal::class, 'Id_Journal');
    }

    public function lignes() {
        return $this->hasMany(LigneEcriture::class, 'Id_Mouvement_ecriture');
    }
}
