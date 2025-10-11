<?php

namespace App\Models\ParametresAnalytique;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TypeCentre extends Model
{
    use HasFactory;

    protected $table = 'typecentre';
    protected $primaryKey = 'id_type';
    public $timestamps = false;

    protected $fillable = [
        'code',
        'libelle',
    ];

    public function centres()
    {
        return $this->hasMany(CentreAnalytique::class, 'id_type');
    }
    
    public function affectations()
    {
        return $this->hasMany(AffectationAnalytique::class, 'id_centre');
    }
}
