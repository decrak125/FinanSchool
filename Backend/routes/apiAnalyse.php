<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ParametresAnalytique\AxeAnalytiqueController;
use App\Http\Controllers\ParametresAnalytique\TypeCentreController;
use App\Http\Controllers\ParametresAnalytique\CentreAnalytiqueController;
use App\Http\Controllers\ParametresAnalytique\AffectationAnalytiqueController;
use App\Http\Controllers\Analyse\CoutEtProfitController;

    Route::put('/affectations/multiple', [AffectationAnalytiqueController::class, 'updateMultiple']);
    Route::delete('/affectations/sous-compte/{id_sous_compte}', [AffectationAnalytiqueController::class, 'destroyBySousCompte']);
    // crud parametres analytiques
    Route::apiResource('axes', AxeAnalytiqueController::class);
    Route::apiResource('types', TypeCentreController::class);
    Route::apiResource('centres', CentreAnalytiqueController::class);
    Route::apiResource('affectations', AffectationAnalytiqueController::class);

    // Importation
    Route::post('/import/axes', [AxeAnalytiqueController::class, 'import']);
    Route::post('/import/centres', [CentreAnalytiqueController::class, 'import']);
    Route::post('/import/affectations', [AffectationAnalytiqueController::class, 'import']);

    // Analyse cout et profit
    Route::get('cout-et-profit', [CoutEtProfitController::class, 'AnalyseCoutEtProfit']);
    Route::get('detail-affectation', [CoutEtProfitController::class, 'AnalyseParAffectation']);


