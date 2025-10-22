<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ParametresAnalytique\AxeAnalytiqueController;
use App\Http\Controllers\ParametresAnalytique\TypeCentreController;
use App\Http\Controllers\ParametresAnalytique\CentreAnalytiqueController;
use App\Http\Controllers\ParametresAnalytique\AffectationAnalytiqueController;
use App\Http\Controllers\Analyse\CoutEtProfitController;
use App\Http\Controllers\Analyse\IndicateursGenerauxController;
use App\Http\Controllers\Analyse\IndicateurRentabiliteController;
use App\Http\Controllers\Analyse\IndicateurLiquiditeController;
use App\Http\Controllers\Analyse\IndicateurSolvabiliteController;

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
          // vaovao
          Route::get('/evolution-12-mois', [CoutEtProfitController::class, 'donneesEvolution12MoisOptimise']);
          Route::get('/evolution-centres', [CoutEtProfitController::class, 'getEvolutionsCentres']);
          Route::get('/classement-centres', [CoutEtProfitController::class, 'getClassementCentres']);
          Route::get('/alertes-automatique', [CoutEtProfitController::class, 'getAlertesAutomatiques']);

          Route::get('/cout-profit/comparaison', [CoutEtProfitController::class, 'getComparaisonCoutProfit']);
          Route::get('/cout-profit/resume-annuel', [CoutEtProfitController::class, 'getResumeAnnuelCoutProfit']);
          Route::get('/cout-profit/rentabilite-type', [CoutEtProfitController::class, 'getAnalyseRentabiliteParType']);
          Route::get('/cout-profit/evolution-mensuelle', [CoutEtProfitController::class, 'getEvolutionMensuelleCoutProfit']);
          Route::get('/cout-profit/classementCentre', [CoutEtProfitController::class,'classementSousCompte']);



     // Indicateurs Généraux
     Route::get('/total-produits', [IndicateursGenerauxController::class, 'calculTotalProduits']);
     Route::get('/total-charges', [IndicateursGenerauxController::class, 'calculTotalCharges']);
     Route::get('/resultat-net', [IndicateursGenerauxController::class, 'calculResultatNet']);
     Route::get('/marge-exploitation', [IndicateursGenerauxController::class, 'calculMargeExploitation']);
     // Indicateurs Rentabilite
     Route::get('/marge-brute', [IndicateurRentabiliteController::class, 'calculMargeBrute']);
     Route::get('/marge-exploitation-ebit', [IndicateurRentabiliteController::class, 'calculMargeExploitationEBIT']);
     Route::get('/marge-nette', [IndicateurRentabiliteController::class, 'calculMargeNette']);
     Route::get('/roa', [IndicateurRentabiliteController::class, 'calculROA']);
     Route::get('/roe', [IndicateurRentabiliteController::class, 'calculROE']);
     // Indicateurs Liquidité
     Route::get('/ratio-liquidite-generale', [IndicateurLiquiditeController::class, 'calculRatioLiquiditeGenerale']);
     Route::get('/tresorerie-nette', [IndicateurLiquiditeController::class, 'calculTresorerieNette']);
     Route::get('/bfr', [IndicateurLiquiditeController::class, 'calculBFR']);
     // Indicateurs Solvabilité
     Route::get('/ratio-endettement', [IndicateurSolvabiliteController::class, 'calculRatioEndettement']);
     Route::get('/capacite-remboursement', [IndicateurSolvabiliteController::class, 'calculCapaciteRemboursement']);
     Route::get('/autonomie-financiere', [IndicateurSolvabiliteController::class, 'calculAutonomieFinanciere']);
    });


