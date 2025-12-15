<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Events\MouvementCreated;
use App\Http\Controllers\calcul\UtilesController;
use App\Models\PlanCompte\SousCompte;


class CoutEtProfitController extends Controller
{
    // Fonction pour récupérer les montants par centre analytique avec taux de ventilation
// Fonction pour récupérer les montants par centre analytique avec taux de ventilation
public function AnalyseCoutEtProfit(Request $request)
{
    $dateStart = $request->input('date_start', '2025-01-01');
    $dateEnd = $request->input('date_end', '2025-12-31');
    $idCentre = $request->input('id_centre');
    $idType = $request->input('id_type');
    $idCode = $request->input('id_code');

    // Calcul des totaux produits et charges
    $totalProduits = UtilesController::calculerTotalCategorieGroupe([
        'CA', 'PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP', 
        'PRODFIN', 'PRODEXCEPT', 'REPRISEPROV'
    ], $dateStart, $dateEnd);

    $totalCharges = UtilesController::calculerTotalCategorieGroupe([
        'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 
        'AMORTPROV', 'CHARGEFIN', 'CHAREXCEPT'
    ], $dateStart, $dateEnd);

    // Requête pour les écritures avec affectation analytique
    $baseQuery = DB::table('ligne_ecritures as le')
        ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
        ->join('centreanalytique as ca', 'aa.id_centre', '=', 'ca.id_centre')
        ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
        ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd])
        ->select(
            'le.Debit',
            'le.Credit', 
            'aa.taux',
            'aa.id_type',
            'ca.id_centre',
            'ca.nom as centre'
        );

    // Appliquer les filtres
    if ($idCentre) {
        $baseQuery->where('ca.id_centre', $idCentre);
    }
    if ($idType) {
        $baseQuery->where('aa.id_type', $idType);
    }
    if ($idCode) {
        $baseQuery->where('aa.id_code', $idCode);
    }

    // Récupérer les données
    $rawData = $baseQuery->get();

    // Grouper correctement et traiter chaque élément
    $groupedData = [];
    
    foreach ($rawData as $item) {
        $key = $item->id_type . '_' . $item->id_centre;
        
        if (!isset($groupedData[$key])) {
            $groupedData[$key] = [
                'id_type' => $item->id_type,
                'id_centre' => $item->id_centre,
                'centre' => $item->centre,
                'items' => []
            ];
        }
        
        $groupedData[$key]['items'][] = $item;
    }

    // Calculer les montants pour chaque groupe
    $data = [];
    $totalVentileParType = [1 => 0, 2 => 0]; // Pour stocker les totaux ventilés par type
    
    foreach ($groupedData as $group) {
        $montantVentile = 0;
        $montantBrut = 0;
        
        foreach ($group['items'] as $item) {
            $montant = $item->Debit - $item->Credit;
            $montantAbsolu = abs($montant);
            $montantBrut += $montantAbsolu;
            $montantVentile += $montantAbsolu * ($item->taux / 100.0);
        }

        // Stocker le total ventilé par type
        if (isset($totalVentileParType[$group['id_type']])) {
            $totalVentileParType[$group['id_type']] += $montantVentile;
        }

        $data[] = [
            'id_type' => $group['id_type'],
            'id_centre' => $group['id_centre'],
            'centre' => $group['centre'],
            'montant_ventile' => $montantVentile,
            'montant_brut' => $montantBrut,
            'pourcentage_ventile' => 0,
            'pourcentage_brut' => 0
        ];
    }

    // 🔥 AJOUT : Calcul des montants non affectés
    // Pour les produits (id_type = 2)
    if ($totalProduits > 0) {
        $totalVentileProduits = $totalVentileParType[2] ?? 0;
        $montantNonAffecteProduits = abs($totalProduits - $totalVentileProduits);
        
        // Vérifier si on filtre par type et si c'est le bon type
        $shouldAddProduits = !$idType || $idType == 2;
        
        if ($montantNonAffecteProduits > 0.01 && $shouldAddProduits) {
            $data[] = [
                'id_type' => 2,
                'id_centre' => 0,
                'centre' => 'Non affecté',
                'montant_ventile' => $montantNonAffecteProduits,
                'montant_brut' => $montantNonAffecteProduits,
                'pourcentage_ventile' => 0,
                'pourcentage_brut' => 0
            ];
        }
    }

    // Pour les charges (id_type = 1)
    if ($totalCharges > 0) {
        $totalVentileCharges = $totalVentileParType[1] ?? 0;
        $montantNonAffecteCharges = abs($totalCharges - $totalVentileCharges);
        
        // Vérifier si on filtre par type et si c'est le bon type
        $shouldAddCharges = !$idType || $idType == 1;
        
        if ($montantNonAffecteCharges > 0.01 && $shouldAddCharges) {
            $data[] = [
                'id_type' => 1,
                'id_centre' => 0,
                'centre' => 'Non affecté',
                'montant_ventile' => $montantNonAffecteCharges,
                'montant_brut' => $montantNonAffecteCharges,
                'pourcentage_ventile' => 0,
                'pourcentage_brut' => 0
            ];
        }
    }

    // 🔥 CORRECTION : Calcul des totaux ventilés et bruts INCLUANT les non affectés
    $totalVentile = array_sum(array_column($data, 'montant_ventile'));
    $totalBrut = array_sum(array_column($data, 'montant_brut'));

    // 🔥 MODIFICATION : Calcul des totaux par type incluant les non affectés
    $totalVentileParTypeAvecNonAffecte = [
        1 => 0,
        2 => 0
    ];
    
    foreach ($data as $item) {
        if (isset($totalVentileParTypeAvecNonAffecte[$item['id_type']])) {
            $totalVentileParTypeAvecNonAffecte[$item['id_type']] += $item['montant_ventile'];
        }
    }

    // 🔥 MODIFICATION : Appliquer les pourcentages
    $results = [];
    foreach ($data as $item) {
        // Calcul du pourcentage ventilé par rapport au total du même type
        $totalVentileDuType = $totalVentileParTypeAvecNonAffecte[$item['id_type']] ?? 0;
        
        $item['pourcentage_ventile'] = $totalVentileDuType > 0 ? 
            round(($item['montant_ventile'] * 100.0) / $totalVentileDuType, 2) : 0;
        
        // Calcul du pourcentage brut par rapport au total général brut
        $item['pourcentage_brut'] = $totalBrut > 0 ? 
            round(($item['montant_brut'] * 100.0) / $totalBrut, 2) : 0;
        
        $results[] = $item;
    }

    event(new MouvementCreated());

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
    $idSousCompte = $request->input('id_sous_compte');
    $montantMin = $request->input('montant_min');
    $montantMax = $request->input('montant_max');
    $idType = $request->input('id_type');
    $idCode = $request->input('id_code'); // ← NOUVEAU : filtre par code analytique

    // 🔥 AJOUT : Calcul des totaux produits et charges
    $totalProduits = UtilesController::calculerTotalCategorieGroupe([
        'CA', 'PRODSTOCK', 'PRODIMMO', 'SUBVENT', 'AUTPRODOP', 
        'PRODFIN', 'PRODEXCEPT', 'REPRISEPROV'
    ], $dateStart, $dateEnd);

    $totalCharges = UtilesController::calculerTotalCategorieGroupe([
        'ACHATCONSOM', 'SERVEXT', 'CHPERS', 'AUTCHOP', 
        'AMORTPROV', 'CHARGEFIN', 'CHAREXCEPT'
    ], $dateStart, $dateEnd);

    $results = collect(); // Initialiser une collection vide

    // 🔥 MODIFICATION : Si pas de id_centre, on affiche SEULEMENT les non affectés
    if (!$idCentre) {
        // 🔥 ÉTAPE 1 : Calculer les totaux ventilés par type
        $totalVentileParType = [1 => 0, 2 => 0];
        
        // On peut quand même calculer les totaux ventilés si besoin
        $queryVentiles = DB::table('ligne_ecritures as le')
            ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
            ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
            ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd]);
            
        if ($idType) {
            $queryVentiles->where('aa.id_type', $idType);
        }
        
        $ventilesData = $queryVentiles
            ->select(
                'aa.id_type',
                DB::raw('SUM(ABS((le."Debit" - le."Credit") * (aa.taux / 100.0))) as montant_ventile')
            )
            ->groupBy('aa.id_type')
            ->get();
        
        foreach ($ventilesData as $item) {
            if ($item->id_type == 1) {
                $totalVentileParType[1] += $item->montant_ventile;
            } elseif ($item->id_type == 2) {
                $totalVentileParType[2] += $item->montant_ventile;
            }
        }
        
        // 🔥 ÉTAPE 2 : Déterminer quels types inclure
        $typesToInclude = [];
        if (!$idType) {
            $typesToInclude = [1, 2]; // Les deux types si pas de filtre
        } else {
            $typesToInclude = [$idType]; // Seulement le type spécifié
        }
        
        // 🔥 ÉTAPE 3 : Ajouter les sous-comptes non affectés
        foreach ($typesToInclude as $typeId) {
            // Calculer le montant non affecté pour ce type
            $totalType = ($typeId == 1) ? $totalCharges : $totalProduits;
            $totalVentileType = $totalVentileParType[$typeId] ?? 0;
            $montantNonAffecte = abs($totalType - $totalVentileType);
            
            if ($montantNonAffecte > 0.01) {
                // Récupérer les sous-comptes non affectés détaillés
                $sousComptesNonAffectes = $this->getSousComptesNonAffectesDetails($typeId, $dateStart, $dateEnd, $idSousCompte);
                
                // Ajouter chaque sous-compte non affecté comme une entrée séparée
                foreach ($sousComptesNonAffectes as $sousCompte) {
                    $results->push((object)[
                        'id_type' => $typeId,
                        'affectation_description' => 'Non affecté',
                        'centre_nom' => 'Non affecté',
                        'taux_ventilation' => 100,
                        'id_sous_compte' => $sousCompte->Id_Sous_compte,
                        'libelle_sous_compte' => $sousCompte->Libelle,
                        'id_code' => null,
                        'code' => 'N/A',
                        'montant_ventile' => $sousCompte->montant_total,
                        'montant_brut' => $sousCompte->montant_total,
                        'pourcentage_ventile' => 0, // Sera recalculé
                        'pourcentage_brut' => 0     // Sera recalculé
                    ]);
                }
            }
        }
    } else {
        // 🔥 ÉTAPE 1 : Requête pour les écritures AVEC affectation analytique (si id_centre est spécifié)
        $query = DB::table('ligne_ecritures as le')
            ->select(
                'aa.id_type',
                'aa.description as affectation_description',
                'ca.nom as centre_nom',
                'aa.taux as taux_ventilation',
                'sc.Id_Sous_compte as id_sous_compte',
                'sc.Libelle as libelle_sous_compte',
                'aa.id_code',
                'co.code',
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
            ->join('code_analytique as co', 'aa.id_code', '=', 'co.id_code')
            ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd]);

        // Si id_centre = 0, on veut les non affectés seulement
        if ($idCentre == 0) {
            // Calculer les totaux ventilés par type
            $totalVentileParType = [1 => 0, 2 => 0];
            
            $ventilesData = DB::table('ligne_ecritures as le')
                ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
                ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
                ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd]);
                
            if ($idType) {
                $ventilesData->where('aa.id_type', $idType);
            }
            
            $ventilesData = $ventilesData
                ->select(
                    'aa.id_type',
                    DB::raw('SUM(ABS((le."Debit" - le."Credit") * (aa.taux / 100.0))) as montant_ventile')
                )
                ->groupBy('aa.id_type')
                ->get();
            
            foreach ($ventilesData as $item) {
                if ($item->id_type == 1) {
                    $totalVentileParType[1] += $item->montant_ventile;
                } elseif ($item->id_type == 2) {
                    $totalVentileParType[2] += $item->montant_ventile;
                }
            }
            
            // Déterminer quels types inclure
            $typesToInclude = [];
            if (!$idType) {
                $typesToInclude = [1, 2]; // Les deux types si pas de filtre
            } else {
                $typesToInclude = [$idType]; // Seulement le type spécifié
            }
            
            foreach ($typesToInclude as $typeId) {
                // Calculer le montant non affecté pour ce type
                $totalType = ($typeId == 1) ? $totalCharges : $totalProduits;
                $totalVentileType = $totalVentileParType[$typeId] ?? 0;
                $montantNonAffecte = abs($totalType - $totalVentileType);
                
                if ($montantNonAffecte > 0.01) {
                    // Récupérer les sous-comptes non affectés détaillés
                    $sousComptesNonAffectes = $this->getSousComptesNonAffectesDetails($typeId, $dateStart, $dateEnd, $idSousCompte);
                    
                    // Ajouter chaque sous-compte non affecté comme une entrée séparée
                    foreach ($sousComptesNonAffectes as $sousCompte) {
                        $results->push((object)[
                            'id_type' => $typeId,
                            'affectation_description' => 'Non affecté',
                            'centre_nom' => 'Non affecté',
                            'taux_ventilation' => 100,
                            'id_sous_compte' => $sousCompte->Id_Sous_compte,
                            'libelle_sous_compte' => $sousCompte->Libelle,
                            'id_code' => null,
                            'code' => 'N/A',
                            'montant_ventile' => $sousCompte->montant_total,
                            'montant_brut' => $sousCompte->montant_total,
                            'pourcentage_ventile' => 0, // Sera recalculé
                            'pourcentage_brut' => 0     // Sera recalculé
                        ]);
                    }
                }
            }
        } else {
            // Filtre par centre spécifique (autre que 0)
            $query->where('ca.id_centre', $idCentre);
            
            // Filtres existants
            if ($idSousCompte) {
                $query->where('sc.Id_Sous_compte', $idSousCompte);
            }
            if ($idType) {
                $query->where('aa.id_type', $idType);
            }
            if ($idCode) {
                $query->where('aa.id_code', $idCode);
            }

            $results = $query
                ->groupBy('aa.id_type', 'aa.description', 'ca.nom', 'aa.taux', 'sc.Id_Sous_compte', 'sc.Libelle', 'aa.id_code', 'co.code')
                ->orderByDesc('montant_ventile')
                ->get();
        }
    }

    // 🔥 ÉTAPE 4 : Recalculer les pourcentages si on a des non affectés
    if ($results->count() > 0 && (!$idCentre || $idCentre == 0)) {
        // Calculer les totaux pour les pourcentages
        $totalVentile = $results->sum('montant_ventile');
        $totalBrut = $results->sum('montant_brut');
        
        // Calculer les totaux par type pour les pourcentages ventilés
        $totalVentileParType = [
            1 => $results->where('id_type', 1)->sum('montant_ventile'),
            2 => $results->where('id_type', 2)->sum('montant_ventile')
        ];
        
        // Recalculer les pourcentages pour tous les éléments
        $results = $results->map(function ($item) use ($totalVentile, $totalBrut, $totalVentileParType) {
            // Pourcentage ventilé : par rapport au total du même type
            $totalDuType = $totalVentileParType[$item->id_type] ?? 0;
            $item->pourcentage_ventile = $totalDuType > 0 ? 
                round(($item->montant_ventile * 100.0) / $totalDuType, 2) : 0;
            
            // Pourcentage brut : par rapport au total général
            $item->pourcentage_brut = $totalBrut > 0 ? 
                round(($item->montant_brut * 100.0) / $totalBrut, 2) : 0;
            
            return $item;
        });
    }

    // 🔥 ÉTAPE 5 : Trier par montant ventilé décroissant
    $results = $results->sortByDesc('montant_ventile')->values();

    // 🔥 ÉTAPE 6 : Appliquer les filtres de montant
    if ($montantMin) {
        $results = $results->where('montant_ventile', '>=', $montantMin);
    }
    
    if ($montantMax) {
        $results = $results->where('montant_ventile', '<=', $montantMax);
    }

    return response()->json($results->values());
}

// 🔥 MODIFICATION : Ajout du paramètre $idSousCompte
private function getSousComptesNonAffectesDetails($idtype, $dateStart, $dateEnd, $idSousCompte = null)
{
    // Récupérer les sous-comptes non affectés
    $sousComptesQuery = SousCompte::whereNotIn('Id_Sous_compte', function($query) {
        $query->select('Id_Sous_compte')
            ->from('affectationanalytique');
    })
    ->whereHas('compte', function($query) use ($idtype) {
        if ($idtype == 1) {
            $query->whereBetween('Code_compte', [600, 699]);
        } elseif ($idtype == 2) {
            $query->whereBetween('Code_compte', [700, 799]);
        }
    });

    // Filtrer par sous-compte si spécifié
    if ($idSousCompte) {
        $sousComptesQuery->where('Id_Sous_compte', $idSousCompte);
    }

    $sousComptesNonAffectes = $sousComptesQuery
        ->with(['compte'])
        ->get();

    // Pour chaque sous-compte non affecté, calculer le montant total
    $result = collect();
    foreach ($sousComptesNonAffectes as $sousCompte) {
        $montantTotal = DB::table('ligne_ecritures as le')
            ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
            ->where('le.Id_Sous_compte', $sousCompte->Id_Sous_compte)
            ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd])
            ->sum(DB::raw('ABS(le."Debit" - le."Credit")'));
        
        if ($montantTotal > 0) {
            $sousCompte->montant_total = $montantTotal;
            $result->push($sousCompte);
        }
    }

    return $result;
}    // Nouvelle fonction pour analyse détaillée par sous-compte avec ventilation
public function AnalyseParSousCompteAvecVentilation(Request $request)
{
    $dateStart = $request->input('date_start', '2025-01-01');
    $dateEnd   = $request->input('date_end', '2025-12-31');
    $idCentre  = $request->input('id_centre');
    $idType = $request->input('id_type');
    $idCode = $request->input('id_code', null);

    // 🔥 OPTIM: Requête simplifiée sans calculs complexes
    $baseQuery = DB::table('ligne_ecritures as le')
        ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
        ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
        ->join('code_analytique as co', 'aa.id_code', '=', 'co.id_code')
        ->join('centreanalytique as ca', 'aa.id_centre', '=', 'ca.id_centre')
        ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
        ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd])
        ->select(
            'sc.Code_sous_compte',
            'sc.Libelle as libelle_sous_compte',
            'ca.nom as centre_nom',
            'aa.taux as taux_ventilation',
            'aa.description as description_ventilation',
            'aa.id_code as id_code',
            'co.code as code',
            'le.Debit',
            'le.Credit'
        );

    if ($idCentre) {
        $baseQuery->where('ca.id_centre', $idCentre);
    }
    if ($idType) {
        $baseQuery->where('aa.id_type', $idType);
    }
    if ($idCode) {
        $baseQuery->where('aa.id_code', $idCode);
    }

    $rawData = $baseQuery->get();

    // 🔥 OPTIM: Calculs en mémoire PHP
    $groupedData = [];
    
    foreach ($rawData as $item) {
        $key = $item->Code_sous_compte . '_' . $item->id_code . '_' . $item->centre_nom;
        
        if (!isset($groupedData[$key])) {
            $groupedData[$key] = [
                'Code_sous_compte' => $item->Code_sous_compte,
                'libelle_sous_compte' => $item->libelle_sous_compte,
                'centre_nom' => $item->centre_nom,
                'taux_ventilation' => $item->taux_ventilation,
                'description_ventilation' => $item->description_ventilation,
                'id_code' => $item->id_code,
                'code' => $item->code,
                'items' => []
            ];
        }
        
        $groupedData[$key]['items'][] = $item;
    }

    // Calculer les montants pour chaque groupe
    $results = [];
    foreach ($groupedData as $group) {
        $montantVentile = 0;
        $montantTotalSousCompte = 0;
        
        foreach ($group['items'] as $item) {
            $montantLigne = abs($item->Debit - $item->Credit);
            $montantTotalSousCompte += $montantLigne;
            $montantVentile += $montantLigne * ($item->taux_ventilation / 100.0);
        }

        $pourcentageEffectif = $montantTotalSousCompte > 0 ? 
            round(($montantVentile / $montantTotalSousCompte) * 100, 2) : 0;

        $results[] = [
            'Code_sous_compte' => $group['Code_sous_compte'],
            'libelle_sous_compte' => $group['libelle_sous_compte'],
            'centre_nom' => $group['centre_nom'],
            'taux_ventilation' => $group['taux_ventilation'],
            'description_ventilation' => $group['description_ventilation'],
            'id_code' => $group['id_code'],
            'code' => $group['code'],
            'montant_ventile' => $montantVentile,
            'montant_total_sous_compte' => $montantTotalSousCompte,
            'pourcentage_effectif' => $pourcentageEffectif
        ];
    }

    // 🔥 OPTIM: Tri en PHP
    usort($results, function ($a, $b) {
        if ($a['Code_sous_compte'] === $b['Code_sous_compte']) {
            return $b['montant_ventile'] <=> $a['montant_ventile'];
        }
        return $a['Code_sous_compte'] <=> $b['Code_sous_compte'];
    });

    // 🔥 OPTIM: Event après le traitement
    event(new MouvementCreated());

    return response()->json($results);
}

    // Fonction pour vérifier la cohérence des ventilations
    public function VerificationVentilations(Request $request)
    {
        // 🔥 Déclencher l'événement
        event(new MouvementCreated());
        $dateStart = $request->input('date_start', '2025-01-01');
        $dateEnd   = $request->input('date_end', '2025-12-31');
        $idCode = $request->input('id_code'); // ← NOUVEAU : filtre par code analytique

        $query = DB::table('sous_compte as sc')
            ->select(
                'sc.Code_sous_compte',
                'sc.Libelle',
                DB::raw('COALESCE(SUM(aa.taux), 0) as total_taux_ventilation'),
                DB::raw('COUNT(aa.id_affectation) as nombre_ventilations'),
                DB::raw('CASE WHEN COALESCE(SUM(aa.taux), 0) = 100 THEN true ELSE false END as ventilation_complete')
            )
            ->leftJoin('affectationanalytique as aa', 'sc.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
            ->whereBetween('aa.created_at', [$dateStart, $dateEnd]); // Ajout de filtre par date

        // ← NOUVEAU : Filtrer par code analytique si fourni
        if ($idCode) {
            $query->where('aa.id_code', $idCode);
        }

        $results = $query
            ->groupBy('sc.Code_sous_compte', 'sc.Libelle')
            ->havingRaw('COUNT(aa.id_affectation) > 0') // Uniquement les sous-comptes avec ventilations
            ->orderBy('sc.Code_sous_compte')
            ->get();

        return response()->json($results);
    }

    // 🔥 ANALYSE MENSUELLE AVEC VUE MATERIALISÉE
    public function donneesMensuellesOptimise(Request $request)
    {
        // 🔥 Déclencher l'événement
        event(new MouvementCreated());
        $year = $request->input('year', date('Y'));
        $idCentre = $request->input('id_centre');
        $idType = $request->input('id_type', 1);
        $idCode = $request->input('id_code'); // ← NOUVEAU : filtre par code analytique

        $query = DB::table('mv_analyse_mensuelle')
            ->select('*')
            ->where('annee', $year)
            ->where('id_type', $idType);

        if ($idCentre) {
            $query->where('id_centre', $idCentre);
        }
        // ← NOUVEAU : Filtrer par code analytique si fourni
        if ($idCode) {
            $query->where('id_code', $idCode);
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

    $dateStart = $request->input('date_start', '2025-01-01');
    $dateEnd   = $request->input('date_end', '2025-12-31');
    $idCentre  = $request->input('id_centre');
    $idSousCompte = $request->input('id_sous_compte');
    $montantMin = $request->input('montant_min');
    $montantMax = $request->input('montant_max');
    $idType = $request->input('id_type');

    // 🔥 VERSION SIMPLIFIÉE : Utiliser la même structure que votre fonction originale
    // mais avec les index créés, ça ira déjà beaucoup plus vite !
    
    $query = DB::table('ligne_ecritures as le')
        ->select(
            'aa.id_type',
            'aa.description as affectation_description',
            'ca.nom as centre_nom',
            'aa.taux as taux_ventilation',
            'sc.Id_Sous_compte as id_sous_compte',
            'sc.Libelle as libelle_sous_compte',
            DB::raw('ABS(SUM((le."Debit" - le."Credit") * (aa.taux / 100.0))) as montant_ventile'),
            DB::raw('ABS(SUM(le."Debit" - le."Credit")) as montant_brut')
        )
        ->join('affectationanalytique as aa', 'le.Id_Sous_compte', '=', 'aa.Id_Sous_compte')
        ->join('centreanalytique as ca', 'aa.id_centre', '=', 'ca.id_centre')
        ->join('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
        ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
        ->whereBetween('me.Date_mouvement', [$dateStart, $dateEnd]);

    if ($idCentre) $query->where('ca.id_centre', $idCentre);
    if ($idSousCompte) $query->where('sc.Id_Sous_compte', $idSousCompte);
    if ($idType) $query->where('aa.id_type', $idType);

    $results = $query
        ->groupBy('aa.id_type', 'aa.description', 'ca.nom', 'aa.taux', 'sc.Id_Sous_compte', 'sc.Libelle')
        ->orderByDesc('montant_ventile')
        ->limit(10)
        ->get();

    // 🔥 OPTIMISATION : Calcul des pourcentages en PHP
    $totalVentile = $results->sum('montant_ventile');
    $totalBrut = $results->sum('montant_brut');

    $results = $results->map(function ($item) use ($totalVentile, $totalBrut) {
        $item->pourcentage_ventile = $totalVentile > 0 ? 
            round(($item->montant_ventile * 100.0) / $totalVentile, 2) : 0;
        $item->pourcentage_brut = $totalBrut > 0 ? 
            round(($item->montant_brut * 100.0) / $totalBrut, 2) : 0;
        return $item;
    });

    // Filtrage par montant
    if ($montantMin) {
        $results = $results->where('montant_ventile', '>=', $montantMin);
    }
    if ($montantMax) {
        $results = $results->where('montant_ventile', '<=', $montantMax);
    }

    event(new MouvementCreated());
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