<?php
namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use App\Models\PlanCompte\Amortissement;
use App\Models\PlanCompte\SousCompte;
use App\Models\PlanCompte\TauxAmortissement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AmortissementController extends Controller
{
    // GET /api/amortissements
    public function index()
    {
        return Amortissement::with(['sousCompte', 'tauxAmortissement'])->get();
    }

    
    // POST /api/amortissements
    public function store(Request $request)
    {
        $validated = $request->validate([
            'Id_Sous_compte' => 'required|exists:sous_comptes,Id_Sous_compte',
            'taux_amortissement_id' => 'required|exists:taux_amortissement,id',
            'date_amortissement' => 'required|date',
            'exercice' => 'required|integer',
            'montant' => 'required|numeric',
            'cumul' => 'nullable|numeric',
            'is_exceptionnel' => 'nullable|boolean',
            'commentaire' => 'nullable|string',
        ]);
        $amortissement = Amortissement::create($validated);
        return response()->json($amortissement->load(['sousCompte', 'tauxAmortissement']), 201);
    }
    public function show($id)
    {
        $amortissement = Amortissement::with(['sousCompte', 'tauxAmortissement'])->findOrFail($id);
        return response()->json($amortissement);
    }


    // GET /api/amortissements/taux
    public function getTaux()
    {
        return TauxAmortissement::all();
    }

    // GET /api/amortissements/solde-brut/{Id_Sous_compte}/{finExercice}
    public function getSoldeBrut($Id_Sous_compte, $finExercice)
    {
        $soldeBrut = DB::table('vue_balance_generale')
            ->where('code_sous_compte', SousCompte::findOrFail($Id_Sous_compte)->Code_sous_compte)
            ->whereDate('date_mouvement', '<=', $finExercice)
            ->orderBy('date_mouvement', 'desc')
            ->value('solde_final');

        return response()->json(['solde_brut' => $soldeBrut]);
    }
}
