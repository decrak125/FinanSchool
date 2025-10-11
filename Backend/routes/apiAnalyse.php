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
    Route::prefix('analyse')->group(function () {
    
        // Route pour l'analyse des coûts et profits par centre avec ventilation
        Route::get('/cout-profit', [CoutEtProfitController::class, 'AnalyseCoutEtProfit'])
             ->name('analyse.cout-profit');
    
        // Route pour l'analyse par affectation avec ventilation
        Route::get('/affectation', [CoutEtProfitController::class, 'AnalyseParAffectationFiltree'])
             ->name('analyse.affectation');
    
        // Route pour l'analyse détaillée par sous-compte avec ventilation
        Route::get('/sous-compte-ventilation', [CoutEtProfitController::class, 'AnalyseParSousCompteAvecVentilation'])
             ->name('analyse.sous-compte-ventilation');
    
        // Route pour la vérification des ventilations
        Route::get('/verification-ventilations', [CoutEtProfitController::class, 'VerificationVentilations'])
             ->name('analyse.verification-ventilations');
    // Routes pour l'analyse temporelle
          Route::get('/mensuelle-centre', [CoutEtProfitController::class, 'donneesMensuellesOptimise']);
          Route::get('/trimestrielle-centre', [CoutEtProfitController::class, 'AnalyseTrimestrielleParCentreOptimise']);
          Route::get('/trimestrielle-stat', [CoutEtProfitController::class, 'statsTrimestriellesOptimise']);
          Route::get('/trimestrielle-graphic', [CoutEtProfitController::class, 'donneesTrimestriellesGraphique']);
          Route::get('/comparaison-annuelle', [CoutEtProfitController::class, 'donneesComparaisonAnnuelleOptimise']);
          Route::get('/evolution-12-mois', [CoutEtProfitController::class, 'donneesEvolution12MoisOptimise']);
    });


