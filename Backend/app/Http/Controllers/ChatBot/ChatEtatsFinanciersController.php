<?php

namespace App\Http\Controllers\ChatBot;

use App\Http\Controllers\Controller;
use App\Models\exercice\ExerciceComptable;
use App\Http\Controllers\ChatBot\ChatUtilesController;
use Carbon\Carbon;

class ChatEtatsFinanciersController extends Controller
{
    /**
     * Point d'entrée : répond aux questions du type
     * - quel est le chiffre d'affaires ?
     * - total des immobilisations corporelles nettes ?
     */
    public static function getIndicateurFinancier($message)
    {
        try {
            $msgNorm = ChatUtilesController::normalizeText($message);

            // 1. Identifier l'exercice courant
            $now = Carbon::now();
            $exercice = ExerciceComptable::getExerciceByDate($now);

            if (!$exercice) {
                return "⚠️ Aucun exercice comptable trouvé pour la date du " . $now->format('d/m/Y') . ".";
            }

            $dateDebut = $exercice->Date_debut;
            $dateFin   = $exercice->Date_fin;

            // 2. Identifier l’indicateur demandé (CA, immo, résultat…)
            $indicateur = self::identifierIndicateur($msgNorm);

            if (!$indicateur) {
                return "Je n'ai pas compris l'indicateur demandé.\n"
                    . "Par exemple :\n"
                    . "• Quel est le chiffre d'affaires ?\n"
                    . "• Quelle est la valeur nette des immobilisations corporelles ?\n"
                    . "• Quel est le résultat net ?";
            }

            // 3. Calcul selon le type d’indicateur
            switch ($indicateur['type']) {

                case 'simple':
                    $montant = self::calculerCategorie($indicateur['code'], $dateDebut, $dateFin);
                    $montantFormatted = number_format($montant, 2, ',', ' ');
                    return "📊 **{$indicateur['label']}**\n"
                        . "📅 Exercice {$exercice->Annee_fiscale} (du "
                        . Carbon::parse($dateDebut)->format('d/m/Y')
                        . " au " . Carbon::parse($dateFin)->format('d/m/Y') . ")\n\n"
                        . "Montant : **{$montantFormatted} Ar**";

                case 'actif_net':
                    $brut  = self::calculerCategorie($indicateur['code_brut'], $dateDebut, $dateFin);
                    $amort = self::calculerCategorie($indicateur['code_amort'], $dateDebut, $dateFin);
                    $net   = $brut - $amort;

                    return self::reponseActifNet(
                        $indicateur,
                        $exercice,
                        $dateDebut,
                        $dateFin,
                        $brut,
                        $amort,
                        $net
                    );

                default:
                    return "Type d'indicateur non géré pour le moment.";
            }

        } catch (\Exception $e) {
            return "Erreur lors du calcul de l'indicateur financier : " . $e->getMessage();
        }
    }

    /**
     * Utilise UtilesController::calculerSommeCategorie comme dans BilanActifController
     */
    private static function calculerCategorie($codeCategorie, $dateDebut, $dateFin): float
    {
        $resultat = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie(
            $codeCategorie,
            $dateDebut,
            $dateFin
        );

        return $resultat && isset($resultat->montant_total)
            ? floatval($resultat->montant_total)
            : 0.0;
    }

    /**
     * Mappe le texte utilisateur → code de catégorie (PCG 2005)
     * en s’alignant sur tes codes (CA, IMMOCO, AMORT_IMMOCO, RESULT, STOCKS, etc.).
     */
    private static function identifierIndicateur(string $msgNorm): ?array
    {
        // Chiffre d’affaires
        if (str_contains($msgNorm, 'chiffre affaire') || str_contains($msgNorm, 'ca ') || str_ends_with($msgNorm, ' ca')) {
            return [
                'type'  => 'simple',
                'code'  => 'CA',
                'label' => "Chiffre d'affaires"
            ];
        }

        // Résultat net / résultat de l’exercice
        if (str_contains($msgNorm, 'resultat net') ||
            str_contains($msgNorm, 'résultat net') ||
            str_contains($msgNorm, 'resultat exercice') ||
            str_contains($msgNorm, 'résultat de l exercice')) {
            return [
                'type'  => 'simple',
                'code'  => 'RESULT',
                'label' => "Résultat net de l'exercice"
            ];
        }

        // Immobilisations corporelles (brut + amortissements + net)
        if (str_contains($msgNorm, 'immobilisation corporelle') ||
            str_contains($msgNorm, 'immobilisations corporelles') ||
            str_contains($msgNorm, 'immo corporelle')) {
            return [
                'type'       => 'actif_net',
                'code_brut'  => 'IMMOCO',
                'code_amort' => 'AMORT_IMMOCO',
                'label'      => "Immobilisations corporelles"
            ];
        }

        // Immobilisations incorporelles
        if (str_contains($msgNorm, 'immobilisation incorporelle') ||
            str_contains($msgNorm, 'immobilisations incorporelles')) {
            return [
                'type'       => 'actif_net',
                'code_brut'  => 'IMMOINC',
                'code_amort' => 'AMORT_IMMOINC',
                'label'      => "Immobilisations incorporelles"
            ];
        }

        // Stocks
        if (str_contains($msgNorm, 'stock')) {
            return [
                'type'       => 'actif_net',
                'code_brut'  => 'STOCKS',
                'code_amort' => 'AMORT_STOCKS',
                'label'      => "Stocks et en-cours"
            ];
        }

        // Créances clients
        if (str_contains($msgNorm, 'client') && (str_contains($msgNorm, 'creance') || str_contains($msgNorm, 'créance'))) {
            return [
                'type'       => 'actif_net',
                'code_brut'  => 'CLIENTS',
                'code_amort' => 'AMORT_CLIENTS',
                'label'      => "Créances clients"
            ];
        }

        // Trésorerie (banque + caisse, sans amortissement)
        if (str_contains($msgNorm, 'trésorerie') || str_contains($msgNorm, 'tresorerie') ||
            str_contains($msgNorm, 'banque') || str_contains($msgNorm, 'caisse')) {
            return [
                'type'  => 'simple',
                'code'  => 'TRESO',   // ou TRESOFONDS selon comment tu as paramétré calculerSommeCategorie
                'label' => "Trésorerie et équivalents de trésorerie"
            ];
        }

        // Dettes fournisseurs
        if (str_contains($msgNorm, 'fournisseur') || str_contains($msgNorm, 'fournisseurs')) {
            return [
                'type'  => 'simple',
                'code'  => 'FOURN',
                'label' => "Dettes fournisseurs"
            ];
        }

        // Emprunts
        if (str_contains($msgNorm, 'emprunt') || str_contains($msgNorm, 'emprunts')) {
            return [
                'type'  => 'simple',
                'code'  => 'EMPRUNT',
                'label' => "Emprunts et dettes financières"
            ];
        }

        // Capital
        if (str_contains($msgNorm, 'capital')) {
            return [
                'type'  => 'simple',
                'code'  => 'CAPITAL',
                'label' => "Capital social"
            ];
        }

        // Charges de personnel
        if (str_contains($msgNorm, 'charge personnel') ||
            str_contains($msgNorm, 'charges de personnel') ||
            str_contains($msgNorm, 'salaire')) {
            return [
                'type'  => 'simple',
                'code'  => 'CHPERS',
                'label' => "Charges de personnel"
            ];
        }

        // Impôts sur le résultat
        if (str_contains($msgNorm, 'impot') || str_contains($msgNorm, 'impôt') ||
            str_contains($msgNorm, 'is ') || str_contains($msgNorm, 'impot sur le resultat')) {
            return [
                'type'  => 'simple',
                'code'  => 'IMPOT',
                'label' => "Impôts sur les bénéfices"
            ];
        }

        return null;
    }

    /**
     * Mise en forme d’une réponse de type Actif : brut / amort / net
     */
    private static function reponseActifNet(
        array $indicateur,
        $exercice,
        $dateDebut,
        $dateFin,
        float $brut,
        float $amort,
        float $net
    ): string {
        $brutF  = number_format($brut, 2, ',', ' ');
        $amortF = number_format($amort, 2, ',', ' ');
        $netF   = number_format($net, 2, ',', ' ');

        $periode = "Exercice {$exercice->Annee_fiscale} (du "
            . Carbon::parse($dateDebut)->format('d/m/Y')
            . " au " . Carbon::parse($dateFin)->format('d/m/Y') . ")";

        return "📊 **{$indicateur['label']}**\n"
            . "📅 {$periode}\n\n"
            . "• Valeur brute : **{$brutF} Ar**\n"
            . "• Amortissements / provisions : **{$amortF} Ar**\n"
            . "• Valeur nette : **{$netF} Ar**";
    }

    /**
     * Aide sur les prompts disponibles
     */
    public static function aidePrompts()
    {
        return
            "Voici quelques exemples de questions sur les états financiers (PCG 2005) :\n\n"
            . "• Quel est le chiffre d'affaires ?\n"
            . "• Quel est le résultat net ?\n"
            . "• Quelle est la valeur nette des immobilisations corporelles ?\n"
            . "• Combien en stocks ?\n"
            . "• Quel est le montant des créances clients ?\n"
            . "• Quel est le montant des dettes fournisseurs ?\n"
            . "• Quel est le montant de la trésorerie ?";
    }
}
