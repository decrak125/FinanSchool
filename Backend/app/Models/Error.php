<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Error extends Model
{
    protected $table = 'errors';   // nom exact de la table
    protected $fillable = ['message'];
}
