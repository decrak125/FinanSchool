<?php

namespace App\Http\Controllers\Auth;

use Illuminate\Http\Request;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Notification;
use App\Models\User;
use App\Models\EmailVerification;
use App\Notifications\EmailVerificationCode;
use Illuminate\Support\Facades\Hash;
class AuthController extends Controller
{
   
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Identifiants incorrects'], 401);
        }

        $token = $user->createToken('app-token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'token' => $token
        ]);
    }

    // Logout
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Déconnecté']);
    }

    // Get current user
    public function user(Request $request)
    {
        return response()->json($request->user());
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
