<?php
namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Password;
use Illuminate\Http\Request;
use App\Helpers\ErrorHelper;

class ForgotPasswordController extends Controller
{
    public function sendResetLink(Request $request)
    {
        $request->validate(['email' => 'required|email']);

        $status = Password::sendResetLink(
            $request->only('email')
        );

        return $status === Password::RESET_LINK_SENT
            ? response()->json(['message' => 'Email envoyé !'])
            : response()->json(['message' => ErrorHelper::get(7)] , 400);
    }

public function showResetForm(Request $request, $token = null)
{
    // Construire l’URL complète du front Vue
    $frontUrl = config('http://localhost:5173') . '/reset-password';
    $url = $frontUrl . '?token=' . $token . '&email=' . urlencode($request->email);

    // Redirection vers le front Vue
    return redirect($url);
}

}
