<?php

namespace App\Http\Controllers\ChatBot;

use App\Http\Controllers\Controller;
use App\Models\Saisie\GrandLivre; // Remplace par ta classe modèle/vue
use App\Http\Controllers\ChatBot\ChatUtilesController;
use Carbon\Carbon;

class ChatGrandLivresController extends Controller
{
    /**
     * Affiche les écritures du Grand Livre pour un compte (période, mois, limité à 30 lignes)
     */
    public static function getEcrituresParCompte($message)
    {
        try {
            // Extraction du code compte
            $codeCompte = ChatUtilesController::extractCodeCompte($message);
            if (!$codeCompte) {
                return "Veuillez préciser le code du compte (ex: 512001, 411, 401 etc).";
            }

            // Construction requête
            $query = GrandLivre::where('code_compte', $codeCompte);

            // Extraction de la période (format "du ... au ...")
            $range = ChatUtilesController::extractDateRange($message);
            if ($range) {
                $start = Carbon::createFromFormat('d/m/Y', $range['start'])->startOfDay();
                $end = Carbon::createFromFormat('d/m/Y', $range['end'])->endOfDay();
                $query->whereBetween('date_mouvement', [$start, $end]);
            } else {
                // Extraction mois & année ("pour janvier 2025")
                $mois = ChatUtilesController::extractMonthFromMessage($message);
                $annee = ChatUtilesController::extractYearFromMessage($message);
                if ($mois && $annee) {
                    $query->whereMonth('date_mouvement', $mois)
                        ->whereYear('date_mouvement', $annee);
                }
            }

            // Pagination
            $limit = 30;
            $ecritures = $query->orderBy('date_mouvement')->limit($limit + 1)->get();
            $truncated = $ecritures->count() > $limit;
            $ecritures = $ecritures->slice(0, $limit);

            // Construction réponse
            if ($ecritures->isEmpty()) {
                return "Aucune écriture trouvée pour le compte **{$codeCompte}** sur la période demandée.";
            }

            $response = "📒 Grand Livre du compte **{$codeCompte}** :\n\n";
            $response .= "| Date | Libellé | Débit | Crédit |\n";
            $response .= "|------|---------|-------|--------|\n";
            foreach ($ecritures as $ecriture) {
                $response .= "| {$ecriture->date_mouvement} | {$ecriture->libelle_ecriture} | {$ecriture->Debit} | {$ecriture->Credit} |\n";
            }
            if ($truncated) {
                $response .= "\n_(Liste tronquée à {$limit} écritures)_\n";
            }
            return $response;
        } catch (\Exception $e) {
            return "Erreur lors de la récupération du Grand Livre : " . $e->getMessage();
        }
    }

    /**
     * Recherche d'écritures par libellé/motif/tiers
     */
    public static function searchByLibelle($message)
    {
        try {
            $text = ChatUtilesController::normalizeText($message);
            $text = str_replace(['cherche', 'libellé', 'motif', 'grand livre'], '', $text);
            $text = trim($text);

            if (strlen($text) < 2) {
                return "Indiquez au moins 2 caractères pour la recherche.";
            }

            $results = GrandLivre::where('libelle_ecriture', 'LIKE', "%{$text}%")
                        ->orWhere('numero_piece', 'LIKE', "%{$text}%")
                        ->orderBy('date_mouvement')
                        ->limit(15)
                        ->get();

            if ($results->isEmpty()) {
                return "Aucune écriture trouvée avec '{$text}'.";
            }

            $response = "🔎 Écritures du Grand Livre pour « {$text} » :\n";
            $response .= "| Date | Compte | Libellé | Débit | Crédit |\n";
            $response .= "|------|--------|---------|-------|--------|\n";
            foreach ($results as $ecriture) {
                $response .= "| {$ecriture->date_mouvement} | {$ecriture->code_compte} | {$ecriture->libelle_ecriture} | {$ecriture->Debit} | {$ecriture->Credit} |\n";
            }
            return $response;
        } catch (\Exception $e) {
            return "Erreur lors de la recherche dans le Grand Livre : " . $e->getMessage();
        }
    }

    /**
     * Résumé/solde du Grand Livre pour un compte
     */
    public static function getSoldeGrandLivre($message)
    {
        try {
            $codeCompte = ChatUtilesController::extractCodeCompte($message);
            if (!$codeCompte) {
                return "Précisez le code du compte pour obtenir le solde du Grand Livre.";
            }

            $totalDebit = GrandLivre::where('code_compte', $codeCompte)->sum('Debit');
            $totalCredit = GrandLivre::where('code_compte', $codeCompte)->sum('Credit');
            $solde = $totalDebit - $totalCredit;

            $response = "🧾 Solde du Grand Livre pour le compte **{$codeCompte}** :\n";
            $response .= "{$solde}";
            return $response;
        } catch (\Exception $e) {
            return "Erreur lors du calcul du solde : " . $e->getMessage();
        }
    }

    /**
     * Prompts d’aide complets
     */
    public static function aidePrompts()
    {
        return
            "Voici ce que je peux faire sur le Grand Livre 👇\n\n"
            . "• Détail par compte : `Grand livre du compte 401001 pour janvier 2025`\n"
            . "• Toutes les écritures sur une période : `Montre le grand livre du 512 du 01/01/2025 au 28/02/2025`\n"
            . "• Recherche par libellé/tiers : `Cherche chèque dans le grand livre`\n"
            . "• Solde final d’un compte : `Solde final du grand livre pour 401`\n"
            . "• Liste limitée à 30 écritures, détail par ligne\n";
    }
}
