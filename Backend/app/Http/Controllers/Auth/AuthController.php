<?php

namespace App\Http\Controllers\Auth;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Support\Facades\Notification;
use App\Models\User;
use App\Models\EmailVerification;
use App\Notifications\EmailVerificationCode;
use Illuminate\Support\Str;
use Carbon\Carbon;
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

   
    public function requestVerification(Request $request)
    {
        $request->validate([
            'email' => 'required|email|unique:users,email',
        ]);

        $code = rand(100000, 999999);

        EmailVerification::updateOrCreate(
            ['email' => $request->email],
            ['token' => $code, 'created_at' => now()]
        );

        Notification::route('mail', $request->email)
            ->notify(new EmailVerificationCode($code));

        return response()->json(['status' => 'success', 'message' => 'Code envoyé à votre email.']);
    }

    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|string|min:6|confirmed',
            'code' => 'required|digits:6',
        ]);

        $verification = EmailVerification::where('email', $request->email)
            ->where('token', $request->code)
            ->first();

        if (!$verification) {
            return response()->json(['status' => 'error', 'message' => 'Code invalide.'], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => bcrypt($request->password),
        ]);

        $verification->delete();

        return response()->json(['status' => 'success', 'user' => $user]);
    }

}
