<?php

namespace App\Models\ParametresAnalytique;

use Illuminate\Database\Eloquent\Model;

class CodeAnalytique extends Model
{
    protected $table = 'code_analytique';

    protected $primaryKey = 'id_code';

    public $timestamps = false; // 🔥 Désactive les timestamps

    protected $fillable = [
        'code',
        'libelle',
        'plage_de_extension',
    ];

    public function affectations()
    {
        return $this->hasMany(AffectationAnalytique::class, 'id_code');
    }
}
