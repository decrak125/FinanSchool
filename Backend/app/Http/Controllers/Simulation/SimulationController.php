<?php

namespace App\Http\Controllers\Simulation;

use App\Http\Controllers\Controller;
use App\Models\Simulation\Simulation;
use App\Models\Simulation\SimulationLigne;
use App\Models\Saisie\LigneEcriture;
use App\Models\PlanCompte\SousCompte;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class SimulationController extends Controller
{
    public function index()
    {
        return response()->json(Simulation::with('lignes')->orderBy('created_at', 'desc')->get());
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'nom_simulation' => 'required|string|max:255',
            'description' => 'nullable|string',
            'id_exercice_comptable' => 'required|exists:exercice_comptable,Id_Exercice_comptable',
            'lignes' => 'required|array',
            'lignes.*.libelle' => 'required|string',
            'lignes.*.type' => 'required|in:produit,charge',
            'lignes.*.nature_charge' => 'required|in:fixe,variable',
            'lignes.*.moyenne_historique' => 'required|numeric',
            'lignes.*.coefficient' => 'required|numeric',
            'lignes.*.montant_simule' => 'required|numeric',
            'lignes.*.id_sous_compte' => 'nullable|exists:sous_comptes,Id_Sous_compte',
        ]);

        return DB::transaction(function () use ($validated) {
            $simulation = Simulation::create([
                'nom_simulation' => $validated['nom_simulation'],
                'description' => $validated['description'],
                'id_exercice_comptable' => $validated['id_exercice_comptable'],
            ]);

            foreach ($validated['lignes'] as $ligneData) {
                $simulation->lignes()->create($ligneData);
            }

            return response()->json($simulation->load('lignes'), 201);
        });
    }

    public function show($id)
    {
        $simulation = Simulation::with('lignes.sousCompte')->findOrFail($id);
        return response()->json($simulation);
    }

    public function destroy($id)
    {
        $simulation = Simulation::findOrFail($id);
        $simulation->delete();
        return response()->json(['message' => 'Simulation supprimée']);
    }

    public function getHistoricalData(Request $request)
    {
        // On récupère les écritures liées aux comptes de classe 6 (charges) et 7 (produits)
        // Utilisation de DB::table pour plus de contrôle sur les noms de colonnes et les quotes

        $results = DB::table('ligne_ecritures as le')
            ->select(
                'sc.Id_Sous_compte',
                'sc.Libelle',
                'sc.Code_sous_compte',
                DB::raw('SUM(le."Debit") as total_debit'),
                DB::raw('SUM(le."Credit") as total_credit')
            )
            ->join('sous_comptes as sc', 'le.Id_Sous_compte', '=', 'sc.Id_Sous_compte')
            // Optionnel: leftJoin pour éviter de perdre des lignes si le mouvement est mal lié
            ->leftJoin('mouvement_ecritures as me', 'le.Id_Mouvement_ecriture', '=', 'me.Id_Mouvement_ecriture')
            ->where(function ($q) {
                $q->where('sc.Code_sous_compte', 'like', '6%')
                    ->orWhere('sc.Code_sous_compte', 'like', '7%');
            })
            // Note: On peut filtrer par statut 'valide' en production
            // ->where('le.statut', 'valide') 
            ->groupBy('sc.Id_Sous_compte', 'sc.Libelle', 'sc.Code_sous_compte')
            ->get();

        $data = $results->map(function ($item) {
            $code = $item->Code_sous_compte;
            $type = str_starts_with($code, '7') ? 'produit' : 'charge';

            // Calcul du solde selon le type de compte (7: Crédit - Débit, 6: Débit - Crédit)
            $solde = ($type === 'produit')
                ? ($item->total_credit - $item->total_debit)
                : ($item->total_debit - $item->total_credit);

            $montantFinal = abs($solde);

            return [
                'id_sous_compte' => $item->Id_Sous_compte,
                'libelle' => $item->Libelle,
                'code' => $code,
                'type' => $type,
                'moyenne_mensuelle' => round($montantFinal / 12, 2)
            ];
        })->values();

        return response()->json($data);
    }
}
