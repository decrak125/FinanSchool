<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Events\MouvementCreated;

class CoutEtProfitController extends Controller
{
    // Fonction pour récupérer les montants par centre analytique avec taux de ventilation
    public function AnalyseCoutEtProfit(Request $request)
    {
        // 🔥 Déclencher l'événement
        event(new MouvementCreated());
        // Dates paramétrables via l'URL ou valeur par défaut
        $dateStart = $request->input('date_start', '2025-01-01');
        $dateEnd = $request->input('date_end', '2025-12-31');
        $idCentre  = $request->input('id_centre'); // facultatif
        $idType = $request->input('id_type');

        $query = DB::table('ligne_ecritures as le')
            ->select(
                'aa.id_type',
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
            $query->where('aa.id_type', $idType);
        }

        $results = $query
            ->groupBy('aa.id_type','ca.id_centre', 'ca.nom')
            ->get();

        return response()->json($results);
    }

    public function AnalyseParAffectationFiltree(Request $request)
    {
        // 🔥 Déclencher l'événement
        event(new MouvementCreated());
        // Paramètres depuis l'URL ou valeurs par défaut
        $dateStart = $request->input('date_start', '2025-01-01');
        $dateEnd   = $request->input('date_end', '2025-12-31');
        $idCentre  = $request->input('id_centre'); // facultatif
        $idSousCompte = $request->input('id_sous_compte'); // ← NOUVEAU
        $montantMin = $request->input('montant_min'); // ← NOUVEAU
        $montantMax = $request->input('montant_max'); // ← NOUVEAU
        $idType = $request->input('id_type');
    
        $query = DB::table('ligne_ecritures as le')
            ->select(
                'aa.id_type',
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
        if ($idType) {
            $query->where('aa.id_type', $idType);
        }
    
        $results = $query
            ->groupBy('aa.id_type', 'aa.description', 'ca.nom', 'aa.taux', 'sc.Id_Sous_compte', 'sc.Libelle')
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
        // 🔥 Déclencher l'événement
        event(new MouvementCreated());
        $dateStart = $request->input('date_start', '2025-01-01');
        $dateEnd   = $request->input('date_end', '2025-12-31');
        $idCentre  = $request->input('id_centre');
        $idType = $request->input('id_type');

        $query = DB::table('ligne_ecritures as le')
            ->select(
                'sc.Code_sous_compte',
                'sc.Libelle as libelle_sous_compte',
                'ca.nom as centre_nom',
                'aa.taux as taux_ventilation',
                'aa.description as description_ventilation',
                // 'aa.id_type as id_type',
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
        if ($idType) {
            $query->where('aa.id_type', $idType);
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
        // 🔥 Déclencher l'événement
        event(new MouvementCreated());
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

    // 🔥 ANALYSE MENSUELLE PAR CENTRE
// 🔥 ANALYSE MENSUELLE AVEC VUE MATERIALISÉE
public function donneesMensuellesOptimise(Request $request)
{
    // 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $year = $request->input('year', date('Y'));
    $idCentre = $request->input('id_centre');
    $idType = $request->input('id_type', 1);

    $query = DB::table('mv_analyse_mensuelle')
        ->select('*')
        ->where('annee', $year)
        ->where('id_type', $idType);

    if ($idCentre) {
        $query->where('id_centre', $idCentre);
    }

    $results = $query
        ->orderBy('mois')
        ->orderBy('centre')
        ->get();

    return response()->json($results);
}

// 🔥 ANALYSE TRIMESTRIELLE OPTIMISÉE AVEC VUE MATERIALISÉE
public function AnalyseTrimestrielleParCentreOptimise(Request $request)
{
    // 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $year = $request->input('year', date('Y'));
    $idCentre = $request->input('id_centre');
    $idType = $request->input('id_type', 1);

    $query = DB::table('mv_analyse_trimestrielle')
        ->select('*')
        ->where('annee', $year)
        ->where('id_type', $idType);

    if ($idCentre) {
        $query->where('id_centre', $idCentre);
    }

    $results = $query
        ->orderBy('trimestre')
        ->orderBy('centre')
        ->get();

    return response()->json($results);
}

// 🔥 STATISTIQUES TRIMESTRIELLES OPTIMISÉES
public function statsTrimestriellesOptimise(Request $request)
{
    // 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $year = $request->input('year', date('Y'));
    $trimestre = $request->input('trimestre');

    $query = DB::table('mv_stats_globales_temporelles')
        ->select('*')
        ->where('type_analyse', 'trimestrielle')
        ->where('annee', $year);

    if ($trimestre) {
        $query->where('trimestre', $trimestre);
    }

    $stats = $query->first();

    return response()->json([
        'totalVentile' => $stats->total_ventile ?? 0,
        'totalBrut' => $stats->total_brut ?? 0,
        'nombreCentres' => $stats->nombre_centres ?? 0,
        'nombrePeriodes' => $stats->nombre_periodes ?? 0
    ]);
}

// 🔥 DONNÉES TRIMESTRIELLES POUR GRAPHIQUE
public function donneesTrimestriellesGraphique(Request $request)
{
    // 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $year = $request->input('year', date('Y'));
    $idType = $request->input('id_type', 1);

    $results = DB::table('mv_analyse_trimestrielle')
        ->select(
            'trimestre',
            'nom_trimestre',
            'centre',
            'montant_ventile',
            'montant_brut'
        )
        ->where('annee', $year)
        ->where('id_type', $idType)
        ->orderBy('trimestre')
        ->orderBy('centre')
        ->get();

    // Formatage pour les graphiques
    $centres = $results->pluck('centre')->unique()->values();
    $trimestres = ['T1', 'T2', 'T3', 'T4'];
    
    $datasets = [];
    foreach ($centres as $centre) {
        $data = [];
        foreach ($trimestres as $trim) {
            $trimNum = (int)str_replace('T', '', $trim);
            $montant = $results
                ->where('centre', $centre)
                ->where('trimestre', $trimNum)
                ->first();
            $data[] = $montant ? $montant->montant_ventile : 0;
        }
        
        $datasets[] = [
            'label' => $centre,
            'data' => $data,
            'backgroundColor' => sprintf('#%06X', mt_rand(0, 0xFFFFFF))
        ];
    }

    return response()->json([
        'labels' => $trimestres,
        'datasets' => $datasets
    ]);
}

// 🔥 COMPARAISON ANNUELLE AVEC VUE MATERIALISÉE
public function donneesComparaisonAnnuelleOptimise(Request $request)
{
    // 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $annee1 = $request->input('annee1', date('Y') - 1);
    $annee2 = $request->input('annee2', date('Y'));
    $idCentre = $request->input('id_centre');
    $idType = $request->input('id_type', 1);

    $query = DB::table('mv_comparaison_annuelle')
        ->select('*')
        ->whereIn('annee', [$annee1, $annee2])
        ->where('id_type', $idType);

    if ($idCentre) {
        $query->where('id_centre', $idCentre);
    }

    $results = $query
        ->orderBy('annee')
        ->orderBy('centre')
        ->get();

    return response()->json($results);
}

public function getEvolutionsCentres(Request $request)
{
    // 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $year = $request->input('year', date('Y'));
    $idType = $request->input('id_type', 1);
    
    $currentYear = DB::table('mv_comparaison_annuelle')
        ->where('annee', $year)
        ->where('id_type', $idType)
        ->get()
        ->keyBy('id_centre');
        
    $previousYear = DB::table('mv_comparaison_annuelle')
        ->where('annee', $year - 1)
        ->where('id_type', $idType)
        ->get()
        ->keyBy('id_centre');
    
    $evolutions = [];
    foreach ($currentYear as $centreId => $current) {
        $previous = $previousYear[$centreId] ?? null;
        $evolution = $previous && $previous->montant_ventile > 0 
            ? round((($current->montant_ventile - $previous->montant_ventile) / $previous->montant_ventile * 100), 2)
            : null;
            
        $evolutions[] = [
            'centre' => $current->centre,
            'annee_courante' => $current->annee,
            'montant_courant' => $current->montant_ventile,
            'montant_precedent' => $previous->montant_ventile ?? 0,
            'evolution_pourcentage' => $evolution
        ];
    }
    
    // Trier par évolution décroissante
    usort($evolutions, function($a, $b) {
        return $b['evolution_pourcentage'] <=> $a['evolution_pourcentage'];
    });
    
    return response()->json($evolutions);
}

public function getClassementCentres(Request $request)
{
    // 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $year = $request->input('year', date('Y'));
    $idType = $request->input('id_type', 1);
    
    $centres = DB::table('mv_comparaison_annuelle')
        ->where('annee', $year)
        ->where('id_type', $idType)
        ->orderByDesc('montant_ventile')
        ->get();
    
    // Calculer le total pour les pourcentages
    $total = $centres->sum('montant_ventile');
    
    // Ajouter le rang et le pourcentage
    $classement = $centres->map(function($centre, $index) use ($total) {
        $centre->rang_global = $index + 1;
        $centre->part_marche = $total > 0 ? round(($centre->montant_ventile / $total * 100), 2) : 0;
        return $centre;
    });
    
    return response()->json($classement);
}

public function getClassementCentresLocal($year, $idType)
{
        $centres = DB::table('mv_comparaison_annuelle')
            ->where('annee', $year)
            ->where('id_type', $idType)
            ->orderByDesc('montant_ventile')
            ->get();
        
        $total = $centres->sum('montant_ventile');
        
        return $centres->map(function($centre, $index) use ($total) {
            $centre->rang_global = $index + 1;
            $centre->part_marche = $total > 0 ? round(($centre->montant_ventile / $total * 100), 2) : 0;

            return $centre;
        });
}

public function getAlertesAutomatiques(Request $request)
{
    // 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $seuil = $request->input('seuil', -20); // -20% par défaut
    $year = $request->input('year', date('Y'));
    $idType = $request->input('id_type', 1);
    
    $currentYear = DB::table('mv_comparaison_annuelle')
        ->where('annee', $year)
        ->where('id_type', $idType)
        ->get()
        ->keyBy('id_centre');
        
    $previousYear = DB::table('mv_comparaison_annuelle')
        ->where('annee', $year - 1)
        ->where('id_type', $idType)
        ->get()
        ->keyBy('id_centre');
    
    $alertes = [];
    foreach ($currentYear as $centreId => $current) {
        $previous = $previousYear[$centreId] ?? null;
        
        if ($previous && $previous->montant_ventile > 0) {
            $evolution = (($current->montant_ventile - $previous->montant_ventile) / $previous->montant_ventile * 100);
            
            if ($evolution < $seuil) {
                $alertes[] = [
                    'type_alerte' => 'chute_brutale',
                    'centre' => $current->centre,
                    'annee_courante' => $current->annee,
                    'montant_courant' => $current->montant_ventile,
                    'montant_precedent' => $previous->montant_ventile,
                    'evolution' => round($evolution, 2)
                ];
            }
        }
    }
    
    // Trier par évolution (pire en premier)
    usort($alertes, function($a, $b) {
        return $a['evolution'] <=> $b['evolution'];
    });
    
    return response()->json($alertes);
}

// 🔥 ÉVOLUTION 12 MOIS AVEC VUE MATERIALISÉE
public function donneesEvolution12MoisOptimise(Request $request)
{
    // 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $idCentre = $request->input('id_centre');
    $idType = $request->input('id_type', 1);

    $query = DB::table('mv_evolution_12_mois')
        ->select('*')
        ->where('id_type', $idType);

    if ($idCentre) {
        $query->where('id_centre', $idCentre);
    }

    $results = $query
        ->orderBy('mois')
        ->orderBy('centre')
        ->get();

    return response()->json($results);
}

// COUTS VS PROFITS 

// 🔥 COMPARAISON COÛTS VS PROFITS AVEC VUE MATERIALISÉE
public function getComparaisonCoutProfit(Request $request)
{// 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $annee = $request->input('annee');
    $mois = $request->input('mois');
    $idType = $request->input('id_type');
    $limit = $request->input('limit', 1000);
    $offset = $request->input('offset', 0);

    $query = DB::table('mv_comparaison_cout_profit')
        ->select('*');

    // Filtres optionnels
    if ($annee) {
        $query->where('annee', $annee);
    }
    
    if ($mois) {
        $query->where('mois', $mois);
    }
    
    if ($idType) {
        $query->where('id_type', $idType);
    }

    $results = $query
        ->orderBy('annee', 'desc')
        ->orderBy('mois', 'desc')
        ->orderBy('id_type')
        ->limit($limit)
        ->offset($offset)
        ->get();

    return response()->json($results);
}

// 🔥 RÉSUMÉ ANNUEL COÛTS VS PROFITS
public function getResumeAnnuelCoutProfit(Request $request)
{// 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $annee = $request->input('annee');

    $query = DB::table('mv_comparaison_cout_profit')
        ->select(
            'annee',
            'id_type',
            DB::raw('SUM(total_couts_ventiles) as total_couts_ventiles_annuels'),
            DB::raw('SUM(total_profits_ventiles) as total_profits_ventiles_annuels'),
            DB::raw('SUM(solde_net_ventile) as solde_net_annuel'),
            DB::raw('AVG(marge_nette_percent) as marge_nette_moyenne'),
            DB::raw('COUNT(DISTINCT mois) as mois_actifs'),
            DB::raw('SUM(nombre_sous_comptes) as nombre_sous_comptes_total')
        );

    if ($annee) {
        $query->where('annee', $annee);
    }

    $results = $query
        ->groupBy('annee', 'id_type')
        ->orderBy('annee', 'desc')
        ->orderBy('id_type')
        ->get();

    return response()->json($results);
}

// 🔥 ANALYSE RENTABILITÉ PAR TYPE
public function getAnalyseRentabiliteParType(Request $request)
{// 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $annee = $request->input('annee', date('Y'));

    $results = DB::table('mv_comparaison_cout_profit')
        ->select(
            'id_type',
            DB::raw('SUM(total_couts_ventiles) as total_couts'),
            DB::raw('SUM(total_profits_ventiles) as total_profits'),
            DB::raw('SUM(solde_net_ventile) as solde_net'),
            DB::raw('AVG(marge_nette_percent) as marge_moyenne'),
            DB::raw('COUNT(DISTINCT mois) as mois_actifs')
        )
        ->where('annee', $annee)
        ->groupBy('id_type')
        ->orderBy('solde_net', 'desc')
        ->get();

    return response()->json($results);
}

// 🔥 ÉVOLUTION MENSUELLE COÛTS VS PROFITS
public function getEvolutionMensuelleCoutProfit(Request $request)
{// 🔥 Déclencher l'événement
    event(new MouvementCreated());
    $idType = $request->input('id_type');
    $annee = $request->input('annee', date('Y'));

    $query = DB::table('mv_comparaison_cout_profit')
        ->select(
            'mois',
            'nom_periode',
            DB::raw('SUM(total_couts_ventiles) as total_couts'),
            DB::raw('SUM(total_profits_ventiles) as total_profits'),
            DB::raw('SUM(solde_net_ventile) as solde_net'),
            DB::raw('AVG(marge_nette_percent) as marge_moyenne')
        )
        ->where('annee', $annee);

    if ($idType) {
        $query->where('id_type', $idType);
    }

    $results = $query
        ->groupBy('mois', 'nom_periode')
        ->orderBy('mois')
        ->get();

    return response()->json($results);
}


public function classementSousCompte(Request $request)
{
    event(new MouvementCreated());
    
    $dateStart = $request->input('date_start', '2025-01-01');
    $dateEnd   = $request->input('date_end', '2025-12-31');
    $idCentre  = $request->input('id_centre');
    $idSousCompte = $request->input('id_sous_compte');
    $montantMin = $request->input('montant_min');
    $montantMax = $request->input('montant_max');
    $idType = $request->input('id_type'); // Filtrer par type

    $query = DB::table('ligne_ecritures as le')
        ->select(
            'aa.id_type',
            'aa.description as affectation_description',
            'ca.nom as centre_nom',
            'aa.taux as taux_ventilation',
            'sc.Id_Sous_compte as id_sous_compte',
            'sc.Libelle as libelle_sous_compte',
            // Montants
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

    // Filtres sous-compte
    if ($idSousCompte) {
        $query->where('sc.Id_Sous_compte', $idSousCompte);
    }

    // 🔥 Filtrer par type spécifique
    if ($idType) {
        $query->where('aa.id_type', $idType);
    }

    $results = $query
        ->groupBy('aa.id_type', 'aa.description', 'ca.nom', 'aa.taux', 'sc.Id_Sous_compte', 'sc.Libelle')
        ->orderByDesc('montant_ventile') // Classement du plus gros au plus petit montant
        ->limit(10) // Les 10 plus gros montants
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
public function classementSousCompteLocal($idType,$dateStart,$dateEnd,$idCentre,$idSousCompte,$montantMin,$montantMax)
{
    event(new MouvementCreated());
    
    $query = DB::table('ligne_ecritures as le')
        ->select(
            'aa.id_type',
            'aa.description as affectation_description',
            'ca.nom as centre_nom',
            'aa.taux as taux_ventilation',
            'sc.Id_Sous_compte as id_sous_compte',
            'sc.Libelle as libelle_sous_compte',
            // Montants
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

    // Filtres sous-compte
    if ($idSousCompte) {
        $query->where('sc.Id_Sous_compte', $idSousCompte);
    }

    // 🔥 Filtrer par type spécifique
    if ($idType) {
        $query->where('aa.id_type', $idType);
    }

    $results = $query
        ->groupBy('aa.id_type', 'aa.description', 'ca.nom', 'aa.taux', 'sc.Id_Sous_compte', 'sc.Libelle')
        ->orderByDesc('montant_ventile') // Classement du plus gros au plus petit montant
        ->limit(10) // Les 10 plus gros montants
        ->get();

    // Filtrage par montant (fait après pour éviter la complexité SQL)
    if ($montantMin) {
        $results = $results->where('montant_ventile', '>=', $montantMin);
    }
    
    if ($montantMax) {
        $results = $results->where('montant_ventile', '<=', $montantMax);
    }

    return $results;
}
}