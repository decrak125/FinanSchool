<?php

namespace App\Http\Controllers\ChatBot;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saisie\Journal;

class ChatJournalController extends Controller
{
    /**
     * Liste tous les journaux disponibles
     */
    public static function getAllJournaux()
    {
        try {
            $journaux = Journal::select('Code', 'Libelle')->orderBy('Code')->get();

            if ($journaux->isEmpty()) {
                return "Aucun journal disponible en base.";
            }

            $reponse = "📓 **Liste des journaux disponibles** :\n\n";
            foreach ($journaux as $journal) {
                $reponse .= "- **{$journal->Code}** : {$journal->Libelle}\n";
            }
            return $reponse;
        } catch(\Exception $e) {
            return "Erreur lors de la récupération des journaux : " . $e->getMessage();
        }
    }

    /**
     * Détail d'un journal par code
     */
    public static function detailJournal($message)
    {
        try {
            preg_match('/journal\s*([A-Za-z0-9]+)/i', $message, $matches);
            $code = $matches[1] ?? null;
            if (!$code) {
                return "Veuillez préciser le code du journal (ex : ACH, VTE, BNQ).";
            }
            $journal = Journal::where('Code', strtoupper($code))->first();
            if (!$journal) {
                return "❌ Aucun journal trouvé pour le code **{$code}**.";
            }
            $reponse = "📖 **Détail du journal {$journal->Code}**\n";
            $reponse .= "Libellé : {$journal->Libelle}";
            // Tu peux ajouter autres champs ou relations ici
            return $reponse;
        } catch(\Exception $e) {
            return "Erreur lors de la recherche du journal : " . $e->getMessage();
        }
    }

    // Ajoute d'autres méthodes si tu veux gérer la recherche par libellé, type, etc.
}
