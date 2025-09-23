<?php

namespace App\Models\Saisie;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TypeJournal extends Model
{
    use HasFactory;

    protected $table = 'type_journals';
    protected $primaryKey = 'Id_Type_Journal';
    public $incrementing = true;
    protected $keyType = 'int';
    public $timestamps = false;

    protected $fillable = [
        'Type',
    ];
}
