<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\EmailVerification;
use App\Models\Error;
use App\Helpers\ErrorHelper;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Notification;
use App\Notifications\EmailVerificationCode;

class AuthController extends Controller
{
    // -------------------
    // LOGIN
    // -------------------
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ], [
            'email.required' => ErrorHelper::get(4),
            'password.required' => ErrorHelper::get(5),
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => ErrorHelper::get(1)
            ], 401);
        }

        $token = $user->createToken('app-token')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'user' => $user,
            'token' => $token
        ]);
    }

    // -------------------
    // LOGOUT
    // -------------------
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['status' => 'success', 'message' => 'Déconnecté']);
    }

    // -------------------
    // GET CURRENT USER
    // -------------------
    public function user(Request $request)
    {
        return response()->json($request->user());
    }

    // -------------------
    // DEMANDER CODE VERIFICATION EMAIL
    // -------------------
    public function requestVerification(Request $request)
    {
        $request->validate([
            'email' => 'required|email|unique:users,email',
        ], [
            'email.required' => ErrorHelper::get(4),
            'email.unique' => ErrorHelper::get(6),
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

    // -------------------
    // REGISTER
    // -------------------
    public function register(Request $request)
        {
            // Validation uniquement des champs nécessaires
            $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|min:6|confirmed',
            ], [
                'name.required' => ErrorHelper::get(7) ?? 'Nom requis', // id 7 pour nom si tu veux
                'email.required' => ErrorHelper::get(4),
                'email.unique' => ErrorHelper::get(6),
                'password.required' => ErrorHelper::get(5),
            ]);

            // Création de l'utilisateur
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => bcrypt($request->password),
            ]);

            return response()->json([
                'status' => 'success',
                'user' => $user
            ]);
        }

}
