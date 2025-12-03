<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\EffectifEleve;
use App\Models\exercice\ExerciceComptable;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Validator;

class EffectifEleveController extends Controller
{
    /**
     * Afficher la liste des effectifs d'élèves.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $effectifs = EffectifEleve::with('exerciceComptable')
            // ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $effectifs,
            'message' => 'Liste des effectifs récupérée avec succès.'
        ], Response::HTTP_OK);
    }

    /**
     * Afficher un effectif spécifique.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show($id)
    {
        $effectif = EffectifEleve::with('exerciceComptable')->find($id);

        if (!$effectif) {
            return response()->json([
                'success' => false,
                'message' => 'Effectif non trouvé.'
            ], Response::HTTP_NOT_FOUND);
        }

        return response()->json([
            'success' => true,
            'data' => $effectif,
            'message' => 'Effectif récupéré avec succès.'
        ], Response::HTTP_OK);
    }

    /**
     * Créer un nouvel effectif d'élèves.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        // Validation des données
        $validator = Validator::make($request->all(), [
            'Id_Exercice_comptable' => 'required|exists:exercice_comptable,Id_Exercice_comptable',
            'nombre_eleves' => 'required|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
                'message' => 'Erreur de validation.'
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        // Vérifier si l'exercice comptable existe déjà
        $existing = EffectifEleve::where('Id_Exercice_comptable', $request->Id_Exercice_comptable)->first();
        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Un effectif existe déjà pour cet exercice comptable.'
            ], Response::HTTP_CONFLICT);
        }

        // Création de l'effectif
        $effectif = EffectifEleve::create($request->all());

        return response()->json([
            'success' => true,
            'data' => $effectif->load('exerciceComptable'),
            'message' => 'Effectif créé avec succès.'
        ], Response::HTTP_CREATED);
    }

    /**
     * Mettre à jour un effectif existant.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $effectif = EffectifEleve::find($id);

        if (!$effectif) {
            return response()->json([
                'success' => false,
                'message' => 'Effectif non trouvé.'
            ], Response::HTTP_NOT_FOUND);
        }

        // Validation des données
        $validator = Validator::make($request->all(), [
            'Id_Exercice_comptable' => 'sometimes|exists:exercice_comptable,Id_Exercice_comptable',
            'nombre_eleves' => 'sometimes|integer|min:0',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'errors' => $validator->errors(),
                'message' => 'Erreur de validation.'
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        // Vérifier si le nouvel exercice comptable n'est pas déjà utilisé
        if ($request->has('Id_Exercice_comptable') && $request->Id_Exercice_comptable != $effectif->Id_Exercice_comptable) {
            $existing = EffectifEleve::where('Id_Exercice_comptable', $request->Id_Exercice_comptable)->first();
            if ($existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'Un effectif existe déjà pour cet exercice comptable.'
                ], Response::HTTP_CONFLICT);
            }
        }

        $effectif->update($request->all());

        return response()->json([
            'success' => true,
            'data' => $effectif->load('exerciceComptable'),
            'message' => 'Effectif mis à jour avec succès.'
        ], Response::HTTP_OK);
    }

    /**
     * Supprimer un effectif.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy($id)
    {
        $effectif = EffectifEleve::find($id);

        if (!$effectif) {
            return response()->json([
                'success' => false,
                'message' => 'Effectif non trouvé.'
            ], Response::HTTP_NOT_FOUND);
        }

        $effectif->delete();

        return response()->json([
            'success' => true,
            'message' => 'Effectif supprimé avec succès.'
        ], Response::HTTP_OK);
    }

    /**
     * Vérifie et copie l'effectif de l'exercice précédent si nécessaire
     */
    public function checkAndCopyEffectif(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $request->date_debut;
        $dateFin = $request->date_fin;

        // Trouver l'exercice comptable par dates
        $exercice = ExerciceComptable::where('Date_debut', $dateDebut)
            ->where('Date_fin', $dateFin)
            ->first();

        if (!$exercice) {
            return response()->json([
                'success' => false,
                'message' => 'Exercice comptable non trouvé pour les dates spécifiées.'
            ], Response::HTTP_NOT_FOUND);
        }

        // Vérifier si l'exercice actuel a déjà un effectif
        $currentEffectif = EffectifEleve::where('Id_Exercice_comptable', $exercice->Id_Exercice_comptable)
            ->with('exerciceComptable')
            ->first();
        
        if ($currentEffectif) {
            return response()->json([
                'success' => true,
                'data' => $currentEffectif,
                'message' => 'Effectif existe déjà pour cet exercice.',
                'action' => 'none'
            ], Response::HTTP_OK);
        }

        // Trouver l'exercice précédent
        $previousExercice = ExerciceComptable::where('Date_fin', '<', $dateDebut)
            ->orderBy('Date_fin', 'desc')
            ->first();

        if (!$previousExercice) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun exercice précédent trouvé.'
            ], Response::HTTP_NOT_FOUND);
        }

        // Récupérer l'effectif de l'exercice précédent
        $previousEffectif = EffectifEleve::where('Id_Exercice_comptable', $previousExercice->Id_Exercice_comptable)->first();

        if (!$previousEffectif) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun effectif trouvé pour l\'exercice précédent.'
            ], Response::HTTP_NOT_FOUND);
        }

        // Copier l'effectif de l'exercice précédent vers l'exercice actuel
        $newEffectif = EffectifEleve::create([
            'Id_Exercice_comptable' => $exercice->Id_Exercice_comptable,
            'nombre_eleves' => $previousEffectif->nombre_eleves
        ]);

        return response()->json([
            'success' => true,
            'data' => $newEffectif->load('exerciceComptable'),
            'message' => 'Effectif copié depuis l\'exercice précédent avec succès.',
            'action' => 'copied',
            'source_exercice' => $previousExercice->Annee_fiscale,
            'target_exercice' => $exercice->Annee_fiscale
        ], Response::HTTP_CREATED);
    }

    /**
     * Récupérer l'effectif par exercice comptable.
     *
     * @param  int  $exerciceId
     * @return \Illuminate\Http\JsonResponse
     */
    public function getByExercice($exerciceId)
    {
        $effectif = EffectifEleve::with('exerciceComptable')
            ->where('Id_Exercice_comptable', $exerciceId)
            ->first();

        if (!$effectif) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun effectif trouvé pour cet exercice comptable.'
            ], Response::HTTP_NOT_FOUND);
        }

        return response()->json([
            'success' => true,
            'data' => $effectif,
            'message' => 'Effectif récupéré avec succès.'
        ], Response::HTTP_OK);
    }

    /**
     * Récupérer les statistiques d'effectifs.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function stats()
    {
        $stats = [
            'total_effectifs' => EffectifEleve::count(),
            'total_eleves' => EffectifEleve::sum('nombre_eleves'),
            'moyenne_eleves' => round(EffectifEleve::avg('nombre_eleves'), 2),
            'max_eleves' => EffectifEleve::max('nombre_eleves'),
            'min_eleves' => EffectifEleve::min('nombre_eleves'),
        ];

        return response()->json([
            'success' => true,
            'data' => $stats,
            'message' => 'Statistiques récupérées avec succès.'
        ], Response::HTTP_OK);
    }

    /**
     * Récupère l'effectif par dates d'exercice
     */
    public function getEffectifByDates(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        // Trouver l'exercice comptable
        $exercice = ExerciceComptable::where('Date_debut', $request->date_debut)
            ->where('Date_fin', $request->date_fin)
            ->first();

        if (!$exercice) {
            return response()->json([
                'success' => false,
                'message' => 'Exercice comptable non trouvé.'
            ], Response::HTTP_NOT_FOUND);
        }

        // Récupérer l'effectif
        $effectif = EffectifEleve::with('exerciceComptable')
            ->where('Id_Exercice_comptable', $exercice->Id_Exercice_comptable)
            ->first();

        if (!$effectif) {
            return response()->json([
                'success' => false,
                'message' => 'Aucun effectif trouvé pour cet exercice.'
            ], Response::HTTP_NOT_FOUND);
        }

        return response()->json([
            'success' => true,
            'data' => $effectif,
            'message' => 'Effectif récupéré avec succès.'
        ], Response::HTTP_OK);
    }
}