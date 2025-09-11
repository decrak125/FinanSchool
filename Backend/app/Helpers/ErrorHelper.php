<?php

namespace App\Helpers;

use App\Models\Error;

class ErrorHelper
{
    public static function get($id)
    {
        $error = Error::find($id);
        // ⚡ Debug temporaire
        // dd($error);

        return $error ? $error->message : 'Erreur inconnue';
    }
}
