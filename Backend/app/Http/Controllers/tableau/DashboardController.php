<?php

namespace App\Http\Controllers\tableau;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class DashboardController extends Controller
{
    // 1. Évolution du Chiffre d'Affaires (CA) par mois avec soldes progressifs
     public function evolutionCA(Request $request)
    {
        $dateDebut = $request->input('date_debut', date('Y-01-01'));
        $dateFin = $request->input('date_fin', date('Y-12-31'));

        $interval = DB::table('intervalle_comptes_categorie as icc')
            ->join('categorie_fonctionelles as cf', 'icc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
            ->where('cf.code', 'CA')
            ->select('icc.compte_debut', 'icc.compte_fin')
            ->first();

        if (!$interval) return response()->json([]);

        $result = DB::table('vue_grand_livre as vgl')
            ->whereBetween('vgl.code_compte', [$interval->compte_debut, $interval->compte_fin])
            ->whereBetween('vgl.date_mouvement', [$dateDebut, $dateFin])
            ->select(
                DB::raw('EXTRACT(MONTH FROM vgl."date_mouvement") as mois'),
                DB::raw('ABS(SUM(vgl."Debit" - vgl."Credit")) as montant')
            )
            ->groupBy(DB::raw('EXTRACT(MONTH FROM vgl."date_mouvement")'))
            ->orderBy('mois')
            ->get();

        return response()->json($result);
    }

    // 2. Évolution de la Trésorerie par mois avec filtre date
    public function evolutionTresorerie(Request $request)
    {
        $dateDebut = $request->input('date_debut', date('Y-01-01'));
        $dateFin = $request->input('date_fin', date('Y-12-31'));

        $interval = DB::table('intervalle_comptes_categorie as icc')
            ->join('categorie_fonctionelles as cf', 'icc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
            ->where('cf.code', 'TRESO')
            ->select('icc.compte_debut', 'icc.compte_fin')
            ->first();

        if (!$interval) return response()->json([]);

        $result = DB::table('vue_grand_livre as vgl')
            ->whereBetween('vgl.code_compte', [$interval->compte_debut, $interval->compte_fin])
            ->whereBetween('vgl.date_mouvement', [$dateDebut, $dateFin])
            ->select(
                DB::raw('EXTRACT(MONTH FROM vgl."date_mouvement") as mois'),
                DB::raw('ABS(SUM(vgl."Debit" - vgl."Credit")) as montant')
            )
            ->groupBy(DB::raw('EXTRACT(MONTH FROM vgl."date_mouvement")'))
            ->orderBy('mois')
            ->get();

        return response()->json($result);
    }

    // 3. Composition du Bilan (fin = date_fin)
    public function compositionBilan(Request $request)
    {
        $dateFin = $request->input('date_fin', date('Y-12-31'));
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
                $amount = DB::table('vue_grand_livre as vgl')
                    ->whereBetween('vgl.code_compte', [$interval->compte_debut, $interval->compte_fin])
                    ->where('vgl.date_mouvement', '<=', $dateFin)
                    ->sum(DB::raw('vgl."Debit" - vgl."Credit"'));

                $result[] = ['poste' => $poste, 'montant' => $amount];
            }
        }

        return response()->json($result);
    }

    // 4. Décomposition du résultat (fin = date_fin)
    public function decompositionResultat(Request $request)
    {
        $dateFin = $request->input('date_fin', date('Y-12-31'));
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
                $amount = DB::table('vue_grand_livre as vgl')
                    ->whereBetween('vgl.code_compte', [$interval->compte_debut, $interval->compte_fin])
                    ->where('vgl.date_mouvement', '<=', $dateFin)
                    ->sum(DB::raw('ABS(vgl."Debit" - vgl."Credit")'));
                $result[] = ['etape' => $cat, 'montant' => $amount];
            }
        }

        return response()->json($result);
    }

public function resumeDashboard(Request $request)
{
    $dateDebut = $request->input('date_debut', date('Y-01-01'));
    $dateFin = $request->input('date_fin', date('Y-12-31'));

    // Solde CA actuel (valeur absolue)
    $intervalCA = DB::table('intervalle_comptes_categorie as icc')
        ->join('categorie_fonctionelles as cf', 'icc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
        ->where('cf.code', 'CA')
        ->select('icc.compte_debut', 'icc.compte_fin')
        ->first();

    $soldeCA = 0;
    if ($intervalCA) {
        $soldeCA = DB::table('vue_grand_livre as vgl')
            ->whereBetween('vgl.code_compte', [$intervalCA->compte_debut, $intervalCA->compte_fin])
            ->whereBetween('vgl.date_mouvement', [$dateDebut, $dateFin])
            ->sum(DB::raw('vgl."Debit" - vgl."Credit"'));
        $soldeCA = abs($soldeCA);
    }

    // Solde Charges (valeur absolue de la somme des charges)
    $codesCharges = [
        'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'IMPTAX', 
        'AUTCHOP', 'AMORTPROV', 'CHARGEFIN', 'CHAREXCEPT'
    ];
    $soldeCharges = 0;
    foreach ($codesCharges as $cat) {
        $interval = DB::table('intervalle_comptes_categorie as icc')
            ->join('categorie_fonctionelles as cf', 'icc.id_categorie_fonctionelle', '=', 'cf.id_categorie_fonctionelle')
            ->where('cf.code', $cat)
            ->select('icc.compte_debut', 'icc.compte_fin')
            ->first();
        if ($interval) {
            $valCharge = DB::table('vue_grand_livre as vgl')
                ->whereBetween('vgl.code_compte', [$interval->compte_debut, $interval->compte_fin])
                ->whereBetween('vgl.date_mouvement', [$dateDebut, $dateFin])
                ->sum(DB::raw('vgl."Debit" - vgl."Credit"'));
            $soldeCharges += abs($valCharge);
        }
    }

    // Nombre d'écritures non validées
    $nbecritsNonVal = DB::table('ligne_ecritures as le')
        ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
        ->whereBetween('me.Date_mouvement', [$dateDebut, $dateFin])
        ->where('le.statut', 'brouillon')
        ->count();

    return response()->json([
        'solde_ca' => $soldeCA,
        'solde_charges' => $soldeCharges,
        'nb_ecritures_non_validees' => $nbecritsNonVal
    ]);
}


    
    /**
     * Helper: Obtenir le nom du mois en français
     */
    private function getNomMois($numero)
    {
        $mois = [
            1 => 'Janvier', 2 => 'Février', 3 => 'Mars', 4 => 'Avril',
            5 => 'Mai', 6 => 'Juin', 7 => 'Juillet', 8 => 'Août',
            9 => 'Septembre', 10 => 'Octobre', 11 => 'Novembre', 12 => 'Décembre'
        ];
        return $mois[$numero] ?? '';
    }
}
