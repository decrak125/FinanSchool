<?php
namespace App\Models\import;

use Illuminate\Database\Eloquent\Model;

class ImportHistory extends Model
{
    protected $table = 'import_histories';
    protected $fillable = [
        'nom_fichier',
        'imported_at',
        'imported_by',
        'nombre_mouvements',
        'nombre_lignes',
        'statut',
        'erreur',
    ];

    public function user() {
        return $this->belongsTo(\App\Models\User::class, 'imported_by');
    }
}
