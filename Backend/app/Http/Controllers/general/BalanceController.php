<?php

namespace App\Http\Controllers\general;

use App\Http\Controllers\Controller;
use App\Models\general\Balance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BalanceController extends Controller
{

        // public function index(Request $request)
        // {
        //     $dateDebut = $request->query('date_debut');
        //     $dateFin = $request->query('date_fin');

        //     if ($dateDebut && $dateFin) {
        //         $balance = DB::table('vue_balance_generale')
        //             ->whereBetween('date_mouvement', [$dateDebut, $dateFin])
        //             ->get();
        //     } else {
        //         $balance = DB::table('vue_balance_generale')->get();
        //     }

        //     return response()->json($balance);
        // }
    // 🧾 Liste complète de la balance générale
    public function index(Request $request)
{
    $query = DB::table('vue_balance_generale')
        ->select(
            'code_compte',
            'libelle_compte',
            'code_sous_compte',
            'libelle_sous_compte',
            DB::raw('SUM(total_debit) as total_debit'),
            DB::raw('SUM(total_credit) as total_credit'),
            DB::raw('SUM(solde_final) as solde_final')
        );

    // Filtrer jusqu'à la date de fin
    if ($request->date_fin) {
        $query->where('date_mouvement', '<=', $request->date_fin);
    }

    // Filtrer depuis la date de début (optionnel)
    if ($request->date_debut) {
        $query->where('date_mouvement', '>=', $request->date_debut);
    }

    // Filtrer par classe de compte
    if ($request->classe_compte) {
        $query->where('code_compte', 'like', $request->classe_compte . '%');
    }

    $query->groupBy('code_compte', 'libelle_compte', 'code_sous_compte', 'libelle_sous_compte')
          ->orderBy('code_compte')
          ->orderBy('code_sous_compte');

    return response()->json($query->get());
}




    // 🔍 Afficher un sous-compte précis
    public function show($codeSousCompte)
    {
        $sousCompte = Balance::where('code_sous_compte', $codeSousCompte)->first();

        if (!$sousCompte) {
            return response()->json(['message' => 'Sous-compte introuvable'], 404);
        }

        return response()->json($sousCompte);
    }
}
