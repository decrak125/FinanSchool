<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;
use App\Http\Controllers\PlanCompte\ClasseController;
use App\Http\Controllers\PlanCompte\CompteController;
use App\Http\Controllers\PlanCompte\RubriqueController;
use App\Http\Controllers\PlanCompte\SousCompteController;

Route::middleware('api')->group(function () {
    Route::post('/example', function (Request $request) {
        return response()->json(['message' => 'POST request received']);
    });

    Route::get('/errors/{id}', [AuthController::class, 'getErrorMessage']);

    Route::get('/test', function () {
        return response()->json(['message' => 'API is working']);
    });

    Route::post('/login', [AuthController::class, 'login']);
    Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);
});

    Route::post('/forgot-password', [ForgotPasswordController::class, 'sendResetLink'])
    ->name('password.reset');
    Route::post('/reset-password', [ResetPasswordController::class, 'reset']);

    Route::get('password/reset/{token}', [ForgotPasswordController::class, 'showResetForm'])
    ->name('password.reset');

    Route::post('/request-verification', [AuthController::class, 'requestVerification']);
    Route::post('/verify-code', [AuthController::class, 'verifyCode']);
    Route::post('/register', [AuthController::class, 'register']);

    // crud plan de compte
    Route::apiResource('comptes', CompteController::class);
    Route::apiResource('sous-comptes', SousCompteController::class);
    Route::apiResource('rubriques', RubriqueController::class);
    Route::apiResource('classes', ClasseController::class);



});
