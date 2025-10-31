<?php
namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use App\Models\PlanCompte\Amortissement; // adapt if model named Amortissement
use App\Models\PlanCompte\SousCompte;
use App\Models\PlanCompte\TauxAmortissement;
use Illuminate\Http\Request;
use Carbon\Carbon;

class AmortissementController extends Controller
{
    // GET /api/amortissement
    public function index(Request $request)
    {
        $exercice = $request->input('exercice', now()->year);
        $dateFinExercice = Carbon::create($exercice, 12, 31);

        $immos = Amortissement::with(['tauxAmortissement', 'sousCompte'])->get();

        $result = $immos->map(function($immo) use ($exercice, $dateFinExercice) {
            $dateDebut = $immo->date_debut_utilisation ?? $immo->date_acquisition;
            $dateDebut = Carbon::parse($dateDebut);

            $taux = $immo->tauxAmortissement->taux;
            $valeurBrute = $immo->valeur_brute;

            // S'assurer que la date de début n'est pas après la date de fin exercice
        if ($dateDebut->year == $exercice && $dateDebut <= $dateFinExercice) {
            // Calculer le prorata en mois (mois stricts, peu importe jour)
            $mois = ($dateFinExercice->month - $dateDebut->month) + 1;
            $montant = $valeurBrute * ($taux / 100) * ($mois / 12);
        } elseif ($dateDebut->year < $exercice) {
            $montant = $valeurBrute * ($taux / 100);
        } else {
            $montant = 0;
        }


            $nb_exercices = max(0, $exercice - $dateDebut->year);
            $cumul = ($valeurBrute * ($taux/100)) * ($nb_exercices)
                + ($dateDebut->year == $exercice ? $montant : 0);
            $cumul = min($cumul, $valeurBrute);

            return [
                'id' => $immo->id,
                'compte' => $immo->sousCompte->Code_sous_compte . ' - ' . $immo->sousCompte->Libelle,
                'libelle' => $immo->libelle,
                'taux' => $taux,
                'valeur_brute' => $valeurBrute,
                'date_acquisition' => $immo->date_acquisition,
                'date_debut_utilisation' => $immo->date_debut_utilisation,
                'cumul_amortissement' => round($cumul,2),
            ];
        });

        return response()->json($result);
    }

    // POST /api/amortissement
    public function store(Request $request)
    {
        $validated = $request->validate([
            'libelle' => 'required|string',
            'Id_Sous_compte' => 'required|exists:sous_comptes,Id_Sous_compte',
            'taux_amortissement_id' => 'required|exists:taux_amortissement,id',
            'valeur_brute' => 'required|numeric',
            'date_acquisition' => 'required|date',
            'date_debut_utilisation' => 'nullable|date'
        ]);

        $immobilisation = Amortissement::create([
            'libelle' => $validated['libelle'],
            'Id_Sous_compte' => $validated['Id_Sous_compte'],
            'taux_amortissement_id' => $validated['taux_amortissement_id'],
            'valeur_brute' => $validated['valeur_brute'],
            'date_acquisition' => $validated['date_acquisition'],
            'date_debut_utilisation' => $validated['date_debut_utilisation'] ?? $validated['date_acquisition'],
        ]);

        return response()->json($immobilisation->load(['tauxAmortissement', 'sousCompte']));
    }

    // GET /api/taux-amortissement
    public function getTaux()
    {
        return TauxAmortissement::all();
    }
}
