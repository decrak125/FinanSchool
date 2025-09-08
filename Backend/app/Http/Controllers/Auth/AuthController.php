<?php

namespace App\Http\Controllers\Auth;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
class AuthController extends Controller
{
    public function login(Request $request)
    {
        // Validation rapide
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $credentials = $request->only('email', 'password');

        // Auth::attempt vérifie automatiquement le hash
        if (Auth::attempt($credentials)) {
            $user = Auth::user();

            // Exemple de retour JSON
            return response()->json([
                'success' => true,
                'user' => $user,
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Email ou mot de passe incorrect'
        ], 401);
    }
}
