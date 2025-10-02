<?php

namespace App\Models\Saisie;

use Illuminate\Database\Eloquent\Model;

class GrandLivre extends Model
{
    protected $table = 'vue_grand_livre';

    protected $primaryKey = null;

    public $incrementing = false;

    public $timestamps = false;

    // Since this is a read-only view, no mass assignable attributes are needed
}