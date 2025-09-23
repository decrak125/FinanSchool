<?php

namespace App\Models\Saisie;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Devise extends Model
{
    use HasFactory;

    protected $table = 'devises';
    protected $primaryKey = 'Id_Devise';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'Libelle',
        'Code',
        'Sigle',
    ];
}
