<?php

namespace App\Models\general;

use Illuminate\Database\Eloquent\Model;

class Balance extends Model
{
    protected $table = 'vue_balance_generale';
    public $timestamps = false; // car une vue n’a pas de timestamps

    protected $fillable = [
        'code_compte',
        'libelle_compte',
        'code_sous_compte',
        'libelle_sous_compte',
        'total_debit',
        'total_credit',
        'solde_final',
        'date_mouvement',
    ];
}
