<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EmailVerification extends Model
{
    use HasFactory;

    public $timestamps = false; // On gère created_at manuellement

    protected $fillable = [
        'email',
        'token',
        'created_at',
    ];
}
