<?php

namespace App\Models\ParametresAnalytique;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class AxeAnalytique extends Model
{
    use HasFactory;

    protected $table = 'axesanalytique';
    protected $primaryKey = 'id_axe';
    public $timestamps = false; // si tu n'as pas created_at/updated_at

    protected $fillable = [
        'axe',
        'description',
    ];

    public function centres()
    {
        return $this->hasMany(CentreAnalytique::class, 'id_axe');
    }
}
