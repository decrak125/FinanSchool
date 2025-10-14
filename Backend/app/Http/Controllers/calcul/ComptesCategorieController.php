<?php

namespace App\Http\Controllers\calcul;

use App\Http\Controllers\Controller;
use App\Models\calcul\CompteCategories;
use App\Models\PlanCompte\SousCompte;
use App\Models\calcul\CategorieFonctionelles;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ComptesCategorieController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $compteCategories = CompteCategories::with(['sousCompte', 'categorieFonctionelles'])->get();
        return response()->json($compteCategories);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'poids' => 'required|numeric|min:0',
            'date_debut' => 'required|date',
            'date_fin' => 'nullable|date|after:date_debut',
            'actif' => 'nullable|boolean',
            'id_sous_compte' => [
                'required',
                Rule::exists('sous_comptes', 'Id_Sous_compte')
            ],
            'id_categorie_fonctionelle' => [
                'required',
                Rule::exists('categorie_fonctionelles', 'id_categorie_fonctionelle')
            ],
        ]);

        $compteCategorie = CompteCategories::create($validated);

        return response()->json([
            'message' => 'Compte catégorie créé avec succès',
            'data' => $compteCategorie->load(['sousCompte', 'categorieFonctionelles'])
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(CompteCategories $compteCategories)
    {
        return response()->json($compteCategories->load(['sousCompte', 'categorieFonctionelles']));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, CompteCategories $compteCategories)
    {
        $validated = $request->validate([
            'poids' => 'sometimes|required|numeric|min:0',
            'date_debut' => 'sometimes|required|date',
            'date_fin' => 'nullable|date|after:date_debut',
            'actif' => 'nullable|boolean',
            'id_sous_compte' => [
                'sometimes',
                'required',
                Rule::exists('sous_comptes', 'Id_Sous_compte')
            ],
            'id_categorie_fonctionelle' => [
                'sometimes',
                'required',
                Rule::exists('categorie_fonctionelles', 'id_categorie_fonctionelle')
            ],
        ]);

        $compteCategories->update($validated);

        return response()->json([
            'message' => 'Compte catégorie mis à jour avec succès',
            'data' => $compteCategories->load(['sousCompte', 'categorieFonctionelles'])
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(CompteCategories $compteCategories)
    {
        $compteCategories->delete();

        return response()->json([
            'message' => 'Compte catégorie supprimé avec succès'
        ]);
    }

    /**
     * Récupère les comptes catégories actifs
     */
    public function getActifs()
    {
        $compteCategories = CompteCategories::where('actif', true)
            ->with(['sousCompte', 'categorieFonctionelles'])
            ->get();

        return response()->json($compteCategories);
    }

    /**
     * Récupère les comptes catégories par sous-compte
     */
    public function getBySousCompte($idSousCompte)
    {
        $compteCategories = CompteCategories::where('id_sous_compte', $idSousCompte)
            ->with(['sousCompte', 'categorieFonctionelles'])
            ->get();

        return response()->json($compteCategories);
    }

    /**
     * Récupère les comptes catégories par catégorie fonctionnelle
     */
    public function getByCategorieFonctionelle($idCategorieFonctionelle)
    {
        $compteCategories = CompteCategories::where('id_categorie_fonctionelle', $idCategorieFonctionelle)
            ->with(['sousCompte', 'categorieFonctionelles'])
            ->get();

        return response()->json($compteCategories);
    }

    /**
     * Récupère les comptes catégories valides pour une date donnée
     */
    public function getByDate(Request $request)
    {
        $validated = $request->validate([
            'date' => 'required|date'
        ]);

        $compteCategories = CompteCategories::where('date_debut', '<=', $validated['date'])
            ->where(function($query) use ($validated) {
                $query->where('date_fin', '>=', $validated['date'])
                      ->orWhereNull('date_fin');
            })
            ->where('actif', true)
            ->with(['sousCompte', 'categorieFonctionelles'])
            ->get();

        return response()->json($compteCategories);
    }

    /**
     * Active/désactive un compte catégorie
     */
    public function toggleActif(CompteCategories $compteCategories)
    {
        $compteCategories->update([
            'actif' => !$compteCategories->actif
        ]);

        return response()->json([
            'message' => 'Statut actif mis à jour avec succès',
            'data' => $compteCategories->load(['sousCompte', 'categorieFonctionelles'])
        ]);
    }

    /**
     * Vérifie la validité d'un compte catégorie pour une date donnée
     */
    public function checkValidite(Request $request, $id)
    {
        $validated = $request->validate([
            'date' => 'required|date'
        ]);

        $compteCategorie = CompteCategories::findOrFail($id);

        $estValide = $compteCategorie->date_debut <= $validated['date'] &&
                    ($compteCategorie->date_fin === null || $compteCategorie->date_fin >= $validated['date']) &&
                    $compteCategorie->actif;

        return response()->json([
            'est_valide' => $estValide,
            'compte_categorie' => $compteCategorie
        ]);
    }

    public function assignerCategoriesAutomatiquement(Request $request)
{
    $validated = $request->validate([
        'id_categorie_fonctionelle' => 'required|exists:categorie_fonctionelles,id_categorie_fonctionelle',
        'compte_debut' => 'required|string|max:10',
        'compte_fin' => 'required|string|max:10',
        'poids' => 'nullable|numeric|min:0|default:1',
        'date_debut' => 'nullable|date|default:today',
        'actif' => 'nullable|boolean|default:true',
    ]);

    try {
        // Vérifier d'abord si l'intervalle existe
        $intervalleExiste = \DB::table('intervalle_comptes_categorie')
            ->where('id_categorie_fonctionelle', $validated['id_categorie_fonctionelle'])
            ->where('compte_debut', $validated['compte_debut'])
            ->where('compte_fin', $validated['compte_fin'])
            ->exists();

        if (!$intervalleExiste) {
            return response()->json([
                'message' => 'L\'intervalle spécifié n\'existe pas dans la table intervalle_comptes_categorie',
                'success' => false
            ], 404);
        }

        // Utiliser une requête raw pour l'insertion
        $resultat = \DB::insert("
            INSERT INTO compte_categories (id_sous_compte, id_categorie_fonctionelle, poids, date_debut, actif, created_at, updated_at)
            SELECT
                sc.\"Id_Sous_compte\",
                ?,
                ?,
                ?,
                ?,
                NOW(),
                NOW()
            FROM sous_comptes sc
            JOIN comptes c ON sc.\"Id_Compte\" = c.\"Id_Compte\"
            JOIN intervalle_comptes_categorie icc ON
                c.\"Code_compte\"::bigint >= icc.compte_debut::bigint
                AND c.\"Code_compte\"::bigint <= icc.compte_fin::bigint
            WHERE icc.id_categorie_fonctionelle = ?
                AND icc.compte_debut = ?
                AND icc.compte_fin = ?
                AND NOT EXISTS (
                    SELECT 1
                    FROM compte_categories cc
                    WHERE cc.id_sous_compte = sc.\"Id_Sous_compte\"
                    AND cc.id_categorie_fonctionelle = ?
                )
        ", [
            $validated['id_categorie_fonctionelle'],
            $validated['poids'],
            $validated['date_debut'],
            $validated['actif'],
            $validated['id_categorie_fonctionelle'],
            $validated['compte_debut'],
            $validated['compte_fin'],
            $validated['id_categorie_fonctionelle']
        ]);

        // Compter le nombre de lignes insérées
        $nombreInsere = \DB::select("
            SELECT COUNT(*) as count
            FROM sous_comptes sc
            JOIN comptes c ON sc.\"Id_Compte\" = c.\"Id_Compte\"
            JOIN intervalle_comptes_categorie icc ON
                c.\"Code_compte\"::bigint >= icc.compte_debut::bigint
                AND c.\"Code_compte\"::bigint <= icc.compte_fin::bigint
            WHERE icc.id_categorie_fonctionelle = ?
                AND icc.compte_debut = ?
                AND icc.compte_fin = ?
        ", [
            $validated['id_categorie_fonctionelle'],
            $validated['compte_debut'],
            $validated['compte_fin']
        ])[0]->count;

        return response()->json([
            'message' => 'Assignation automatique des catégories terminée',
            'success' => true,
            'nombre_sous_comptes_eligibles' => $nombreInsere,
            'assignation_reussie' => $resultat,
            'parametres_utilises' => $validated
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Erreur lors de l\'assignation automatique',
            'error' => $e->getMessage(),
            'success' => false
        ], 500);
    }
}

/**
 * Assigne automatiquement les catégories pour tous les intervalles de comptes
 */
/**
 * Assigne automatiquement les catégories pour tous les intervalles de comptes
 */
public function assignerToutesCategoriesAutomatiquement(Request $request)
{
    $validated = $request->validate([
        'poids' => 'nullable|numeric|min:0|default:1',
        'date_debut' => 'nullable|date|default:today',
        'date_fin' => 'nullable|date',
        'actif' => 'nullable|boolean|default:true',
        'forcer' => 'nullable|boolean|default:false',
    ]);

    // Assurer les valeurs par défaut
    $parametres = array_merge([
        'poids' => 1,
        'date_debut' => now()->toDateString(),
        'date_fin' => null,
        'actif' => true,
        'forcer' => false,
    ], $validated);

    try {
        // Récupérer tous les intervalles de comptes
        $intervalles = \DB::table('intervalle_comptes_categorie')->get();

        $resultats = [];
        $totalAssignations = 0;
        $totalIntervalles = $intervalles->count();

        foreach ($intervalles as $intervalle) {
            $resultatIntervalle = $this->traiterIntervalle($intervalle, $parametres);
            $resultats[] = $resultatIntervalle;
            $totalAssignations += $resultatIntervalle['nombre_assignations'] ?? 0;
        }

        return response()->json([
            'message' => 'Assignation automatique de toutes les catégories terminée',
            'success' => true,
            'total_intervalles_traites' => $totalIntervalles,
            'total_assignations' => $totalAssignations,
            'details_par_intervalle' => $resultats,
            'parametres_utilises' => $parametres
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Erreur lors de l\'assignation automatique de toutes les catégories',
            'error' => $e->getMessage(),
            'success' => false
        ], 500);
    }
}

/**
 * Traite un intervalle spécifique
 */
private function traiterIntervalle($intervalle, $parametres)
{
    $forcer = $parametres['forcer'] ?? false;

    if ($forcer) {
        // Supprimer les assignations existantes pour cet intervalle
        \DB::table('compte_categories')
            ->where('id_categorie_fonctionelle', $intervalle->id_categorie_fonctionelle)
            ->delete();
    }

    // Requête avec les colonnes dans le bon ordre
    $requeteInsert = "
        INSERT INTO compte_categories (
            poids,
            date_debut,
            date_fin,
            actif,
            id_sous_compte,
            id_categorie_fonctionelle,
            created_at,
            updated_at
        )
        SELECT
            ?,
            ?,
            ?,
            ?,
            sc.\"Id_Sous_compte\",
            ?,
            NOW(),
            NOW()
        FROM sous_comptes sc
        JOIN comptes c ON sc.\"Id_Compte\" = c.\"Id_Compte\"
        JOIN intervalle_comptes_categorie icc ON
            c.\"Code_compte\"::bigint >= icc.compte_debut::bigint
            AND c.\"Code_compte\"::bigint <= icc.compte_fin::bigint
        WHERE icc.id = ?
            AND NOT EXISTS (
                SELECT 1
                FROM compte_categories cc
                WHERE cc.id_sous_compte = sc.\"Id_Sous_compte\"
                AND cc.id_categorie_fonctionelle = ?
            )
    ";

    $resultat = \DB::insert($requeteInsert, [
        $parametres['poids'] ?? 1,                    // poids avec valeur par défaut
        $parametres['date_debut'] ?? now()->toDateString(), // date_debut avec valeur par défaut
        $parametres['date_fin'] ?? null,              // date_fin (nullable)
        $parametres['actif'] ?? true,                 // actif avec valeur par défaut
        $intervalle->id_categorie_fonctionelle,       // id_categorie_fonctionelle
        $intervalle->id,                              // pour la condition WHERE
        $intervalle->id_categorie_fonctionelle        // pour la condition NOT EXISTS
    ]);

    // Compter le nombre réel d'insertions pour cet intervalle
    $nombreAssignations = \DB::select("
        SELECT COUNT(*) as count
        FROM (
            SELECT sc.\"Id_Sous_compte\"
            FROM sous_comptes sc
            JOIN comptes c ON sc.\"Id_Compte\" = c.\"Id_Compte\"
            JOIN intervalle_comptes_categorie icc ON
                c.\"Code_compte\"::bigint >= icc.compte_debut::bigint
                AND c.\"Code_compte\"::bigint <= icc.compte_fin::bigint
            WHERE icc.id = ?
                AND NOT EXISTS (
                    SELECT 1
                    FROM compte_categories cc
                    WHERE cc.id_sous_compte = sc.\"Id_Sous_compte\"
                    AND cc.id_categorie_fonctionelle = ?
                )
        ) as eligible
    ", [$intervalle->id, $intervalle->id_categorie_fonctionelle])[0]->count;

    // Compter le nombre de sous-comptes éligibles pour cet intervalle
    $nombreEligibles = \DB::select("
        SELECT COUNT(DISTINCT sc.\"Id_Sous_compte\") as count
        FROM sous_comptes sc
        JOIN comptes c ON sc.\"Id_Compte\" = c.\"Id_Compte\"
        JOIN intervalle_comptes_categorie icc ON
            c.\"Code_compte\"::bigint >= icc.compte_debut::bigint
            AND c.\"Code_compte\"::bigint <= icc.compte_fin::bigint
        WHERE icc.id = ?
    ", [$intervalle->id])[0]->count;

    // Compter le nombre d'assignations existantes pour cet intervalle
    $nombreExistants = \DB::table('compte_categories')
        ->where('id_categorie_fonctionelle', $intervalle->id_categorie_fonctionelle)
        ->count();

    return [
        'intervalle_id' => $intervalle->id,
        'compte_debut' => $intervalle->compte_debut,
        'compte_fin' => $intervalle->compte_fin,
        'id_categorie_fonctionelle' => $intervalle->id_categorie_fonctionelle,
        'nombre_sous_comptes_eligibles' => $nombreEligibles,
        'nombre_assignations_existantes' => $nombreExistants,
        'nombre_assignations' => $nombreAssignations,
        'assignation_reussie' => $resultat,
        'message' => $nombreAssignations > 0 ? "{$nombreAssignations} nouvelles assignations" : 'Aucune nouvelle assignation'
    ];
}
/**
 * Version avec suivi en temps réel (pour les gros volumes)
 */
public function assignerToutesCategoriesAvecSuivi(Request $request)
{
    $validated = $request->validate([
        'poids' => 'nullable|numeric|min:0|default:1',
        'date_debut' => 'nullable|date|default:today',
        'actif' => 'nullable|boolean|default:true',
        'batch_size' => 'nullable|integer|min:1|max:1000|default:100',
    ]);

    try {
        // Compter le nombre total d'intervalles
        $totalIntervalles = \DB::table('intervalle_comptes_categorie')->count();

        $resultats = [];
        $totalAssignations = 0;
        $intervallesTraites = 0;

        // Traiter par lots pour éviter les timeouts
        \DB::table('intervalle_comptes_categorie')
            ->orderBy('id')
            ->chunk($validated['batch_size'], function ($intervalles) use (&$resultats, &$totalAssignations, &$intervallesTraites, $validated) {
                foreach ($intervalles as $intervalle) {
                    $resultatIntervalle = $this->traiterIntervalle($intervalle, $validated);
                    $resultats[] = $resultatIntervalle;
                    $totalAssignations += $resultatIntervalle['nombre_assignations'] ?? 0;
                    $intervallesTraites++;
                }
            });

        return response()->json([
            'message' => 'Assignation automatique de toutes les catégories terminée',
            'success' => true,
            'total_intervalles_traites' => $intervallesTraites,
            'total_assignations' => $totalAssignations,
            'details_par_intervalle' => $resultats,
            'parametres_utilises' => $validated
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Erreur lors de l\'assignation automatique de toutes les catégories',
            'error' => $e->getMessage(),
            'success' => false
        ], 500);
    }
}

/**
 * Vérifie l'état des assignations avant traitement
 */
public function verifierEtatAssignations()
{
    try {
        $etat = [];

        // Compter le nombre total d'intervalles
        $totalIntervalles = \DB::table('intervalle_comptes_categorie')->count();

        // Compter le nombre total de sous-comptes éligibles
        $totalSousComptesEligibles = \DB::select("
            SELECT COUNT(DISTINCT sc.\"Id_Sous_compte\") as count
            FROM sous_comptes sc
            JOIN comptes c ON sc.\"Id_Compte\" = c.\"Id_Compte\"
            JOIN intervalle_comptes_categorie icc ON
                c.\"Code_compte\"::bigint >= icc.compte_debut::bigint
                AND c.\"Code_compte\"::bigint <= icc.compte_fin::bigint
        ")[0]->count;

        // Compter le nombre total d'assignations existantes
        $totalAssignationsExistantes = \DB::table('compte_categories')->count();

        // Détails par intervalle
        $detailsIntervalles = \DB::select("
            SELECT
                icc.id,
                icc.compte_debut,
                icc.compte_fin,
                icc.id_categorie_fonctionelle,
                COUNT(DISTINCT sc.\"Id_Sous_compte\") as sous_comptes_eligibles,
                COUNT(cc.id_compte_categorie) as assignations_existantes
            FROM intervalle_comptes_categorie icc
            LEFT JOIN sous_comptes sc ON EXISTS (
                SELECT 1
                FROM comptes c
                WHERE c.\"Id_Compte\" = sc.\"Id_Compte\"
                AND c.\"Code_compte\"::bigint >= icc.compte_debut::bigint
                AND c.\"Code_compte\"::bigint <= icc.compte_fin::bigint
            )
            LEFT JOIN compte_categories cc ON cc.id_categorie_fonctionelle = icc.id_categorie_fonctionelle
            GROUP BY icc.id, icc.compte_debut, icc.compte_fin, icc.id_categorie_fonctionelle
            ORDER BY icc.id
        ");

        return response()->json([
            'etat_general' => [
                'total_intervalles' => $totalIntervalles,
                'total_sous_comptes_eligibles' => $totalSousComptesEligibles,
                'total_assignations_existantes' => $totalAssignationsExistantes,
                'taux_couverture' => $totalSousComptesEligibles > 0 ?
                    round(($totalAssignationsExistantes / $totalSousComptesEligibles) * 100, 2) : 0
            ],
            'details_par_intervalle' => $detailsIntervalles
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'message' => 'Erreur lors de la vérification de l\'état des assignations',
            'error' => $e->getMessage(),
            'success' => false
        ], 500);
    }
}
}
