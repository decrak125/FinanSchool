<?php

namespace App\Http\Controllers\general;

use App\Http\Controllers\Controller;
use App\Models\general\Balance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BalanceController extends Controller
{
    // 🧾 Liste complète de la balance générale
    public function index(Request $request)
    {
        $dateDebut = $request->query('date_debut');
        $dateFin = $request->query('date_fin');

        // On filtre côté backend si les dates sont fournies
        if ($dateDebut && $dateFin) {
            $balance = DB::table('vue_balance_generale')
                ->join('mouvement_ecritures', 'mouvement_ecritures.Id_Mouvement_ecriture', '=', 'mouvement_ecritures.Id_Mouvement_ecriture')
                ->whereBetween('mouvement_ecritures.Date_mouvement', [$dateDebut, $dateFin])
                ->select('vue_balance_generale.*')
                ->get();
        } else {
            $balance = Balance::all();
        }

        return response()->json($balance);
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
