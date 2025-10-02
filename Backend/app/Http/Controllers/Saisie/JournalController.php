<?php

namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saisie\Journal;

class JournalController extends Controller
{
    public function index()
    {
        return Journal::with('typeJournal','sousCompte')->get();
    }

    public function show($id)
    {
        return Journal::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Code' => 'required|string|max:50|unique:journals,Code',
            'Libelle' => 'required|string|max:50',
            'Id_Type_Journal' => 'required|integer|exists:type_journals,Id_Type_Journal',
            'Id_Sous_compte' => 'nullable|integer|exists:sous_comptes,Id_Sous_compte',
        ]);

        return Journal::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $journal = Journal::findOrFail($id);

        $request->validate([
            'Code' => 'required|string|max:50|unique:journals,Code,' . $journal->Id_Journal . ',Id_Journal',
            'Libelle' => 'required|string|max:50',
            'Id_Type_Journal' => 'required|integer|exists:type_journals,Id_Type_Journal',
            'Id_Sous_compte' => 'nullable|integer|exists:sous_comptes,Id_Sous_compte',
        ]);

        $journal->update($request->all());

        return $journal;
    }

    public function destroy($id)
    {
        $journal = Journal::findOrFail($id);
        $journal->delete();

        return response()->json(['message' => 'Journal supprimé']);
    }

    public function ecritures($id, Request $request)
    {
        $journal = Journal::with(['lignes' => function ($query) {
            $query->where('statut', 'valide');
        }, 'lignes.sousCompte', 'lignes.modePaiement', 'lignes.mouvement'])->findOrFail($id);
        return response()->json($journal->lignes);
    }

}
