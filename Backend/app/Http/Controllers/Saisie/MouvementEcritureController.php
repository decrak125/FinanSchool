<?php

namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saisie\MouvementEcriture;
use App\Models\Saisie\Journal;

class MouvementEcritureController extends Controller
{
    public function index()
    {
        return MouvementEcriture::all();
    }

    public function show($id)
    {
        return MouvementEcriture::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Date_mouvement' => 'required|date',
            'Id_Journal' => 'required|exists:journals,Id_Journal',
        ]);

        $year = date('Y', strtotime($request->Date_mouvement));

        // Récupérer le dernier numéro pour ce journal et cette année
        $lastNumero = MouvementEcriture::where('Id_Journal', $request->Id_Journal)
            ->whereYear('Date_mouvement', $year)
            ->max('Id_Mouvement_ecriture'); // ou Numero_piece_int si tu crées un champ int

        $nextNumero = $lastNumero ? $lastNumero + 1 : 1;

        // Générer le numéro formaté : VE2025-0001
        $journalCode = Journal::find($request->Id_Journal)->Code;
        $numeroPiece = $journalCode . $year . '-' . str_pad($nextNumero, 4, '0', STR_PAD_LEFT);

        // Créer le mouvement
        $mouvement = MouvementEcriture::create([
            'Date_mouvement' => $request->Date_mouvement,
            'Id_Journal' => $request->Id_Journal,
            'Numero_piece' => $numeroPiece,
        ]);

        return response()->json([
            'message' => 'Mouvement enregistré avec succès',
            'mouvement' => $mouvement
        ]);
    }

    public function update(Request $request, $id)
    {
        $mouvement = MouvementEcriture::findOrFail($id);
        $mouvement->update($request->all());

        return $mouvement;
    }

    public function destroy($id)
    {
        $mouvement = MouvementEcriture::findOrFail($id);
        $mouvement->delete();

        return response()->json(['message' => 'Mouvement supprimé']);
    }
}
