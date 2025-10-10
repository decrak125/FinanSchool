<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class CoutEtProfitController extends Controller
{
    // Fonction pour récupérer les montants par centre analytique avec taux de ventilation
    public function AnalyseCoutEtProfit(Request $request)
    {
        // Dates paramétrables via l'URL ou valeur par défaut
        $dateStart = $request->input('date_start', '2025-01-01');
        $dateEnd = $request->input('date_end', '2025-12-31');
        $idCentre  = $request->input('id_centre'); // facultatif
        $idType = $request->input('id_type');

        $query = DB::table('ligne_ecritures as le')
            ->select(
                'ca.id_type',
                'ca.id_centre',
                'ca.nom as centre',
                // 🔥 CORRECTION : ABS() POUR AVOIR DES MONTANTS POSITIFS
                DB::raw('ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) as montant_ventile'),
                DB::raw('ABS(SUM(le."Debit" - le."Credit")) as montant_brut'),
                DB::raw('ROUND(ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) * 100.0 / NULLIF(SUM(ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0)))) OVER (), 0), 2) as pourcentage_ventile'),
                DB::raw('ROUND(ABS(SUM(le."Debit" - le."Credit")) * 100.0 / NULLIF(SUM(ABS(SUM(le."Debit" - le."Credit"))) OVER (), 0), 2) as pourcentage_brut')
            )
            ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
            ->join('centreanalytique as ca', 'aa.id_centre', '=', 'ca.id_centre')
            ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
            ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd]);

        // Filtrer par centre si fourni
        if ($idCentre) {
            $query->where('ca.id_centre', $idCentre);
        }
        if ($idType) {
            $query->where('ca.id_type', $idType);
        }

        $results = $query
            ->groupBy('ca.id_type','ca.id_centre', 'ca.nom')
            ->get();

        return response()->json($results);
    }

    public function AnalyseParAffectationFiltree(Request $request)
    {
        // Paramètres depuis l'URL ou valeurs par défaut
        $dateStart = $request->input('date_start', '2025-01-01');
        $dateEnd   = $request->input('date_end', '2025-12-31');
        $idCentre  = $request->input('id_centre'); // facultatif
        $idSousCompte = $request->input('id_sous_compte'); // ← NOUVEAU
        $montantMin = $request->input('montant_min'); // ← NOUVEAU
        $montantMax = $request->input('montant_max'); // ← NOUVEAU
    
        $query = DB::table('ligne_ecritures as le')
            ->select(
                'ca.id_type',
                'aa.description as affectation_description',
                'ca.nom as centre_nom',
                'aa.taux as taux_ventilation',
                'sc.Id_Sous_compte as id_sous_compte', // ← AJOUTÉ
                'sc.Libelle as libelle_sous_compte',   // ← AJOUTÉ
                // 🔥 CORRECTION : ABS() POUR AVOIR DES MONTANTS POSITIFS
                DB::raw('ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) as montant_ventile'),
                DB::raw('ABS(SUM(le."Debit" - le."Credit")) as montant_brut'),
                DB::raw('ROUND(ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) * 100.0 / NULLIF(SUM(ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0)))) OVER (), 0), 2) as pourcentage_ventile'),
                DB::raw('ROUND(ABS(SUM(le."Debit" - le."Credit")) * 100.0 / NULLIF(SUM(ABS(SUM(le."Debit" - le."Credit"))) OVER (), 0), 2) as pourcentage_brut')
            )
            ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
            ->join('centreanalytique as ca', 'aa.id_centre', '=', 'ca.id_centre')
            ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
            ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
            ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd]);
    
        // Filtrer par centre si fourni
        if ($idCentre) {
            $query->where('ca.id_centre', $idCentre);
        }
    
        // ← NOUVEAUX FILTRES
        if ($idSousCompte) {
            $query->where('sc.Id_Sous_compte', $idSousCompte);
        }
    
        $results = $query
            ->groupBy('ca.id_type', 'aa.description', 'ca.nom', 'aa.taux', 'sc.Id_Sous_compte', 'sc.Libelle')
            ->orderByDesc('montant_ventile')
            ->get();
    
        // Filtrage par montant (fait après pour éviter la complexité SQL)
        if ($montantMin) {
            $results = $results->where('montant_ventile', '>=', $montantMin);
        }
        
        if ($montantMax) {
            $results = $results->where('montant_ventile', '<=', $montantMax);
        }
    
        return response()->json($results->values());
    }

    // Nouvelle fonction pour analyse détaillée par sous-compte avec ventilation
    public function AnalyseParSousCompteAvecVentilation(Request $request)
    {
        $dateStart = $request->input('date_start', '2025-01-01');
        $dateEnd   = $request->input('date_end', '2025-12-31');
        $idCentre  = $request->input('id_centre');

        $query = DB::table('ligne_ecritures as le')
            ->select(
                'sc.Code_sous_compte',
                'sc.Libelle as libelle_sous_compte',
                'ca.nom as centre_nom',
                'aa.taux as taux_ventilation',
                'aa.description as description_ventilation',
                // 🔥 CORRECTION : ABS() POUR AVOIR DES MONTANTS POSITIFS
                DB::raw('ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) as montant_ventile'),
                DB::raw('ABS(SUM(le."Debit" - le."Credit")) as montant_total_sous_compte'),
                DB::raw('ROUND((ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) / ABS(SUM(le."Debit" - le."Credit"))) * 100, 2) as pourcentage_effectif')
            )
            ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
            ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
            ->join('centreanalytique as ca', 'aa.id_centre', '=', 'ca.id_centre')
            ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
            ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd]);

        if ($idCentre) {
            $query->where('ca.id_centre', $idCentre);
        }

        $results = $query
            ->groupBy('sc.Code_sous_compte', 'sc.Libelle', 'ca.nom', 'aa.taux', 'aa.description')
            ->orderBy('sc.Code_sous_compte')
            ->orderByDesc('montant_ventile')
            ->get();

        return response()->json($results);
    }

    // Fonction pour vérifier la cohérence des ventilations
    public function VerificationVentilations(Request $request)
    {
        $dateStart = $request->input('date_start', '2025-01-01');
        $dateEnd   = $request->input('date_end', '2025-12-31');

        $results = DB::table('sous_compte as sc')
            ->select(
                'sc.Code_sous_compte',
                'sc.Libelle',
                DB::raw('COALESCE(SUM(aa.taux), 0) as total_taux_ventilation'),
                DB::raw('COUNT(aa.id_affectation) as nombre_ventilations'),
                DB::raw('CASE WHEN COALESCE(SUM(aa.taux), 0) = 100 THEN true ELSE false END as ventilation_complete')
            )
            ->leftJoin('affectationanalytique as aa', 'sc.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
            ->groupBy('sc.Code_sous_compte', 'sc.Libelle')
            ->havingRaw('COUNT(aa.id_affectation) > 0') // Uniquement les sous-comptes avec ventilations
            ->orderBy('sc.Code_sous_compte')
            ->get();

        return response()->json($results);
    }
}