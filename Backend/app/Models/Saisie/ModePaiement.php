<?php

namespace App\Models\Saisie;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ModePaiement extends Model
{
    use HasFactory;

    protected $table = 'mode_paiements';
    protected $primaryKey = 'Id_Mode_paiement';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'Libelle',
        'Abr',
    ];
}
