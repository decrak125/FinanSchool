<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CoutEtProfitController extends Controller
{
    // Fonction pour récupérer les montants par centre analytique
    public function AnalyseCoutEtProfit(Request $request)
    {
        // Dates paramétrables via l'URL ou valeur par défaut
        $dateStart = $request->input('date_start', '2025-01-01');
        $dateEnd = $request->input('date_end', '2025-12-31');

        $results = DB::table('ligne_ecritures as le')
            ->select(
                'ca.id_centre',
                'ca.nom as centre',
                DB::raw('SUM(le."Debit" - le."Credit") as montant'),
                DB::raw('ROUND(SUM(le."Debit" - le."Credit") * 100.0 / NULLIF(SUM(SUM(le."Debit" - le."Credit")) OVER (), 0), 2) as pourcentage')
            )
            ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
            ->join('centreanalytique as ca', 'aa.id_centre', '=', 'ca.id_centre')
            ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
            ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd])
            ->groupBy('ca.id_centre', 'ca.nom')
            ->get();

        return response()->json($results);
    }

    public function AnalyseParAffectation(Request $request)
    {
        // Paramètres depuis l'URL ou valeurs par défaut
        $dateStart = $request->input('date_start', '2025-01-01');
        $dateEnd   = $request->input('date_end', '2025-12-31');
        $idCentre  = $request->input('id_centre'); // facultatif

        $query = DB::table('ligne_ecritures as le')
            ->select(
                'aa.description as centre',
                DB::raw('SUM(le."Debit" - le."Credit") as montant'),
                DB::raw('ROUND(SUM(le."Debit" - le."Credit") * 100.0 / NULLIF(SUM(SUM(le."Debit" - le."Credit")) OVER (), 0), 2) as pourcentage')
            )
            ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
            ->join('centreanalytique as ca', 'aa.id_centre', '=', 'ca.id_centre')
            ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
            ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd]);

        // Filtrer par centre si fourni
        if ($idCentre) {
            $query->where('ca.id_centre', $idCentre);
        }

        $results = $query
            ->groupBy('aa.description')
            ->orderByDesc('montant')
            ->get();

        return response()->json($results);
    }
}
