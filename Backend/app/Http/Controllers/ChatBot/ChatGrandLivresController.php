<?php

namespace App\Http\Controllers\ChatBot;

use App\Http\Controllers\Controller;
use App\Models\Saisie\GrandLivre;       // Pour le détail des écritures
use App\Models\general\Balance;         // Pour le solde via la vue SQL
use App\Models\exercice\ExerciceComptable; // Pour filtrer par exercice courant
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
            // 1. Extraction du code compte
            $codeCompte = ChatUtilesController::extractCodeCompte($message);
            if (!$codeCompte) {
                return "Veuillez préciser le code du compte (ex: 512001, 411, 401 etc).";
            }

            // 2. Construction requête sur le GrandLivre (Détail)
            $query = GrandLivre::where('code_compte', $codeCompte);

            // 3. Gestion des dates
            $range = ChatUtilesController::extractDateRange($message);
            if ($range) {
                // Cas "du X au Y"
                $start = Carbon::createFromFormat('d/m/Y', $range['start'])->startOfDay();
                $end = Carbon::createFromFormat('d/m/Y', $range['end'])->endOfDay();
                $query->whereBetween('date_mouvement', [$start, $end]);
            } else {
                // Cas "janvier 2025" ou par défaut
                $mois = ChatUtilesController::extractMonthFromMessage($message);
                $annee = ChatUtilesController::extractYearFromMessage($message);
                if ($mois && $annee) {
                    $query->whereMonth('date_mouvement', $mois)
                          ->whereYear('date_mouvement', $annee);
                }
                // Note: Si aucune date n'est précisée, on pourrait aussi restreindre à l'exercice courant ici,
                // mais pour l'instant on laisse l'historique complet ou on attend une précision de l'utilisateur.
            }

            // 4. Pagination / Limite
            $limit = 30;
            $ecritures = $query->orderBy('date_mouvement')->limit($limit + 1)->get();
            $truncated = $ecritures->count() > $limit;
            $ecritures = $ecritures->slice(0, $limit);

            // 5. Réponse
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
            $text = str_replace(['cherche', 'libellé', 'motif', 'grand livre', 'dans le'], '', $text);
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
     * Résumé/solde du Grand Livre pour un compte via le modèle Balance (Vue SQL)
     * Filtré par l'exercice comptable courant.
     */
    public static function getSoldeGrandLivre($message)
    {
        try {
            $codeCompte = ChatUtilesController::extractCodeCompte($message);
            if (!$codeCompte) {
                return "Précisez le code du compte pour obtenir le solde du Grand Livre.";
            }

            // 1. Récupération de l'exercice courant basé sur la date actuelle
            $dateActuelle = Carbon::now();
            $exercice = ExerciceComptable::getExerciceByDate($dateActuelle);

            if (!$exercice) {
                return "⚠️ Impossible de récupérer le solde : aucun exercice comptable n'est actif pour la date du " . $dateActuelle->format('d/m/Y') . ".";
            }

            // 2. Requête filtrée sur les dates de l'exercice trouvé
            // La vue 'vue_balance_generale' peut avoir plusieurs lignes (par date), on doit faire la somme.
            $data = Balance::where('code_sous_compte', $codeCompte)
                ->whereBetween('date_mouvement', [$exercice->Date_debut, $exercice->Date_fin])
                ->selectRaw('SUM(total_debit) as debit, SUM(total_credit) as credit, SUM(solde_final) as solde')
                ->first();

            // 3. Vérification du résultat
            if (!$data || ($data->debit == 0 && $data->credit == 0)) {
                 return "Aucun mouvement trouvé pour le compte **{$codeCompte}** sur l'exercice courant ({$exercice->Annee_fiscale}).";
            }

            // 4. Formatage
            $soldeAbsolu = abs($data->solde);
            $soldeFormatted = number_format($soldeAbsolu, 2, ',', ' ');
            $debitFormatted = number_format($data->debit, 2, ',', ' ');
            $creditFormatted = number_format($data->credit, 2, ',', ' ');
            
            $statut = $data->solde > 0 ? "Débiteur" : ($data->solde < 0 ? "Créditeur" : "Soldé");

            // 5. Réponse détaillée
            $response = "**Solde actuel du compte {$codeCompte}**,\n";
            $response .= "• **Solde : {$soldeFormatted} ,(Compte {$statut})**";
            
            return $response;

        } catch (\Exception $e) {
            return "Erreur lors du calcul du solde : " . $e->getMessage();
        }
    }

    /**
     * Prompts d’aide complets
     */
    public static function aidePrompts()
    {
        return
            "Voici ce que je peux faire sur le Grand Livre 👇\n\n"
            . "• Détail par compte : `Grand livre du compte 401001 pour janvier 2025`\n"
            . "• Toutes les écritures sur une période : `Montre le grand livre du 512 du 01/01/2025 au 28/02/2025`\n"
            . "• Recherche par libellé/tiers : `Cherche chèque dans le grand livre`\n"
            . "• Solde actuel d’un compte : `Solde du compte 411` (sur l'exercice courant)\n"
            . "• Liste limitée à 30 écritures, détail par ligne\n";
    }
}
