<?php

require __DIR__ . '/apiAnalyse.php';

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\Auth\ForgotPasswordController;
use App\Http\Controllers\Auth\ResetPasswordController;
use App\Http\Controllers\PlanCompte\ClasseController;
use App\Http\Controllers\PlanCompte\CompteController;
use App\Http\Controllers\PlanCompte\RubriqueController;
use App\Http\Controllers\PlanCompte\SousCompteController;
use App\Http\Controllers\Saisie\TypeJournalController;
use App\Http\Controllers\Saisie\ModePaiementController;
use App\Http\Controllers\Saisie\JournalController;
use App\Http\Controllers\Saisie\MouvementEcritureController;
use App\Http\Controllers\Saisie\LigneEcritureController;
use App\Http\Controllers\Saisie\DeviseController;
use App\Http\Controllers\Saisie\GrandLivreController;
use App\Http\Controllers\general\BalanceController;
use App\Http\Controllers\calcul\IntervalleComptesCategorieController;
use App\Http\Controllers\calcul\ComptesCategorieController;
use App\Http\Controllers\calcul\UtilesController;
use App\Http\Controllers\general\CompteResultatNatureController;
use App\Http\Controllers\general\CompteResultatFonctionController;
use App\Http\Controllers\exercice\ExerciceComptableController;
use App\Http\Controllers\general\BilanActifController;
use App\Http\Controllers\general\BilanPassifController;
use App\Http\Controllers\general\FluxTresorerieController;
use App\Http\Controllers\general\VariationsCapitauxController;

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
    Route::post('/mouvements', [LigneEcritureController::class, 'createMouvement']);
    Route::delete('/mouvements/{mouvementId}', [LigneEcritureController::class, 'deleteMouvement']);
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


    Route::get('/devises', [DeviseController::class, 'index'])->name('devises.index');
    Route::post('/devises', [DeviseController::class, 'store'])->name('devises.store');
    Route::get('/devises/{id}', [DeviseController::class, 'show'])->name('devises.show');
    Route::put('/devises/{id}', [DeviseController::class, 'update'])->name('devises.update');
    Route::delete('/devises/{id}', [DeviseController::class, 'destroy'])->name('devises.destroy');

    // crud saisie
    Route::apiResource('type-journals', TypeJournalController::class);
    Route::apiResource('mode-paiements', ModePaiementController::class);
    Route::get('journals/{id}/ecritures', [JournalController::class, 'ecritures']);
    Route::apiResource('journals', JournalController::class);
    Route::apiResource('mouvements', MouvementEcritureController::class);
    // Route::post('mouvements/{id}/valider', [MouvementEcritureController::class, 'valider']);
    Route::apiResource('lignes', LigneEcritureController::class);
    Route::post('lignes/{id}/valider', [LigneEcritureController::class, 'valider']);
    Route::apiResource('devises', DeviseController::class);

    Route::get('/mouvements-complets', [LigneEcritureController::class, 'getMouvementsComplets']);
    Route::post('/mouvements/{id}/valider', [LigneEcritureController::class, 'validerMouvementComplet']);
    Route::delete('/mouvements/{id}', [LigneEcritureController::class, 'deleteMouvement']);
    Route::get('/sous-comptes/search', [LigneEcritureController::class, 'searchSousComptes']);
 


    // Routes pour les performances améliorées {Ecritures et Mouvements}
 Route::get('/mouvements-complets', [LigneEcritureController::class, 'getMouvementsComplets']);
    Route::get('/search-sous-comptes', [LigneEcritureController::class, 'searchSousComptes']);
    Route::post('/lignes-batch', [LigneEcritureController::class, 'saveLignesBatch']);
    Route::post('/mouvements/{id}/valider-complet', [LigneEcritureController::class, 'validerMouvementComplet']);
    Route::get('/options-formulaires', [LigneEcritureController::class, 'getOptions']);

    // Routes pour la gestion des mouvements
    

    // Routes pour la gestion des lignes d'écriture
    Route::apiResource('lignes', LigneEcritureController::class);

    Route::get('/grand-livre', [GrandLivreController::class, 'index']);
    Route::get('/grand-livre/compte/{codeCompte}', [GrandLivreController::class, 'getByCompte']);
    Route::get('/grand-livre/{codeCompte}/{codeSousCompte?}', [GrandLivreController::class, 'show']);

    // Nouvelles routes pour les écritures d'un seul compte
    Route::get('/compte/{codeCompte}/ecritures', [GrandLivreController::class, 'getEcrituresCompte']);
    Route::get('/compte/{codeCompte}/ecritures-simple', [GrandLivreController::class, 'getEcrituresCompteSimple']);

    Route::get('/balance-generale', [BalanceController::class, 'index']);
    Route::get('/balance-generale/{codeSousCompte}', [BalanceController::class, 'show']);

    Route::apiResource('/intervalle-comptes-categorie', IntervalleComptesCategorieController::class);

    Route::apiResource('/compte-categories', ComptesCategorieController::class);
    Route::post('/assigner-toutes-automatiquement', [ComptesCategorieController::class, 'assignerToutesCategoriesAutomatiquement']);
    Route::get('/somme-categorie', [UtilesController::class, 'getSommeParCategorie']);

    // routes/api.php
    Route::get('/compte-resultat/nature', [CompteResultatNatureController::class, 'index']);
    // routes/api.php
    Route::get('/compte-resultat/fonction', [CompteResultatFonctionController::class, 'index']);

    

Route::prefix('exercices')->group(function () {
    Route::get('/', [ExerciceComptableController::class, 'index']);
    Route::get('/ouvert', [ExerciceComptableController::class, 'getExerciceOuvert']);
    Route::get('/courant', [ExerciceComptableController::class, 'getExerciceCourant']);
    Route::get('/verifier/courant', [ExerciceComptableController::class, 'verifierExerciceCourant']);
    Route::get('/{id}', [ExerciceComptableController::class, 'show']);
    Route::get('/{id}/dates', [ExerciceComptableController::class, 'getDates']);
    Route::post('/{id}/ouvrir', [ExerciceComptableController::class, 'ouvrir']);
    Route::post('/{id}/cloturer', [ExerciceComptableController::class, 'cloturer']);
});



Route::get('/bilan/actif', [BilanActifController::class, 'index']);
Route::get('/bilan/passif', [BilanPassifController::class, 'index']);
Route::get('/flux-tresorerie', [FluxTresorerieController::class, 'index']);
Route::get('/variations-capitaux', [VariationsCapitauxController::class, 'index']);


});
