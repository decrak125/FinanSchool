<?php

namespace App\Http\Controllers\tableau;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class DashboardController extends Controller
{
    // 1. Évolution du Chiffre d'Affaires (CA) par mois
    public function evolutionCA(Request $request)
    {
        $year = $request->input('year', now()->year);
        
        $interval = DB::table('intervalle_comptes_categorie as icc')
            ->join('categorie_fonctionelles as cf', 'icc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
            ->where('cf.code', 'CA')
            ->select('icc.compte_debut', 'icc.compte_fin')
            ->first();
            
        if (!$interval) return response()->json([]);
        
        $result = DB::table('ligne_ecritures as le')
            ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
            ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
            ->join('comptes as c', 'sc.Id_Compte', '=', 'c.Id_Compte')
            ->select(
                DB::raw('EXTRACT(MONTH FROM me."Date_mouvement") as mois'),
                DB::raw('SUM(le."Debit" - le."Credit") as montant')
            )
            ->whereBetween('c.Code_compte', [$interval->compte_debut, $interval->compte_fin])
            ->whereYear('me.Date_mouvement', $year)
            ->groupBy('mois')
            ->orderBy('mois')
            ->get();
            
        return response()->json($result);
    }

    // 2. Évolution de la Trésorerie par mois
    public function evolutionTresorerie(Request $request)
    {
        $year = $request->input('year', now()->year);
        
        $interval = DB::table('intervalle_comptes_categorie as icc')
            ->join('categorie_fonctionelles as cf', 'icc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
            ->where('cf.code', 'TRESO')
            ->select('icc.compte_debut', 'icc.compte_fin')
            ->first();
            
        if (!$interval) return response()->json([]);
        
        $result = DB::table('ligne_ecritures as le')
            ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
            ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
            ->join('comptes as c', 'sc.Id_Compte', '=', 'c.Id_Compte')
            ->select(
                DB::raw('EXTRACT(MONTH FROM me."Date_mouvement") as mois'),
                DB::raw('SUM(le."Debit" - le."Credit") as montant')
            )
            ->whereBetween('c.Code_compte', [$interval->compte_debut, $interval->compte_fin])
            ->whereYear('me.Date_mouvement', $year)
            ->groupBy('mois')
            ->orderBy('mois')
            ->get();
            
        return response()->json($result);
    }

    // 3. Composition du Bilan (postes principaux, actifs & passifs)
    public function compositionBilan(Request $request)
    {
        $date = $request->input('date', now()->toDateString());
        $postes = [
            'IMMOINC', 'IMMOCO', 'STOCKS', 'CLIENTS', 'TRESO',
            'CAPITAL', 'PRIME', 'DETTECT', 'FOURN', 'AUTDETTE'
        ];
        
        $result = [];
        foreach ($postes as $poste) {
            $interval = DB::table('intervalle_comptes_categorie as icc')
                ->join('categorie_fonctionelles as cf', 'icc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
                ->where('cf.code', $poste)
                ->select('icc.compte_debut', 'icc.compte_fin')
                ->first();
                
            if ($interval) {
                $amount = DB::table('ligne_ecritures as le')
                    ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
                    ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
                    ->join('comptes as c', 'sc.Id_Compte', '=', 'c.Id_Compte')
                    ->whereBetween('c.Code_compte', [$interval->compte_debut, $interval->compte_fin])
                    ->where('me.Date_mouvement', '<=', $date)
                    ->sum(DB::raw('le."Debit" - le."Credit"'));
                    
                $result[] = ['poste' => $poste, 'montant' => $amount];
            }
        }
        
        return response()->json($result);
    }

    // 4. Décomposition du résultat (compte de résultat "cascade")
    public function decompositionResultat(Request $request)
    {
        $date = $request->input('date', now()->toDateString());
        $etapes = [
            'CA', 'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'IMPTAX',
            'AUTCHOP', 'AMORTPROV', 'REPRISEPROV', 'PRODFIN', 'CHARGEFIN',
            'PRODEXCEPT', 'CHAREXCEPT'
        ];
        
        $result = [];
        foreach ($etapes as $cat) {
            $interval = DB::table('intervalle_comptes_categorie as icc')
                ->join('categorie_fonctionelles as cf', 'icc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
                ->where('cf.code', $cat)
                ->select('icc.compte_debut', 'icc.compte_fin')
                ->first();
                
            if ($interval) {
                $amount = DB::table('ligne_ecritures as le')
                    ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
                    ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
                    ->join('comptes as c', 'sc.Id_Compte', '=', 'c.Id_Compte')
                    ->whereBetween('c.Code_compte', [$interval->compte_debut, $interval->compte_fin])
                    ->where('me.Date_mouvement', '<=', $date)
                    ->sum(DB::raw('le."Debit" - le."Credit"'));
                    
                $result[] = ['etape' => $cat, 'montant' => $amount];
            }
        }
        
        return response()->json($result);
    }
}
