<?php

namespace App\Models\ParametresAnalytique;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CentreAnalytique extends Model
{
    use HasFactory;

    protected $table = 'centreanalytique';
    protected $primaryKey = 'id_centre';
    public $timestamps = false;

    protected $fillable = [
        'nom',
        'description',
        'id_axe',
    ];

    public function axe()
    {
        return $this->belongsTo(AxeAnalytique::class, 'id_axe');
    }

    public function affectations()
    {
        return $this->hasMany(AffectationAnalytique::class, 'id_centre');
    }
}
