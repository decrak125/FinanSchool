<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;

Route::middleware('api')->group(function () {
    Route::post('/example', function (Request $request) {
        return response()->json(['message' => 'POST request received']);
    });

    Route::get('/test', function () {
        return response()->json(['message' => 'API is working']);
    });

    Route::post('/login', [AuthController::class, 'login']);
});