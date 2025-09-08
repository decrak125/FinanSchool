<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;

Route::middleware('api')->group(function () {
    Route::post('/example', function (Request $request) {
        return response()->json(['message' => 'POST request received']);
    });

    Route::get('/test', function () {
        return response()->json(['message' => 'API is working']);
    });

    Route::post('/login', [AuthController::class, 'login']);

    Route::post('/forgot-password', [ForgotPasswordController::class, 'sendResetLink'])
    ->name('password.reset');
    Route::post('/reset-password', [ResetPasswordController::class, 'reset']);

    Route::get('password/reset/{token}', [ForgotPasswordController::class, 'showResetForm'])
    ->name('password.reset');

    Route::post('/request-verification', [AuthController::class, 'requestVerification']);
    Route::post('/register', [AuthController::class, 'register']);

    
});