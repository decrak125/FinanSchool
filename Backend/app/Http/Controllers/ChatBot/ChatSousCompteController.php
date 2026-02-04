<?php

namespace App\Http\Controllers\ChatBot;

use App\Http\Controllers\Controller;
use App\Http\Controllers\PlanCompte\SousCompteController;
use App\Models\PlanCompte\SousCompte;
use App\Models\PlanCompte\Compte;
use App\Http\Controllers\ChatBot\ChatUtilesController;

class ChatSousCompteController extends Controller
{
    /**
     * Récupère tous les sous-comptes avec formatage pour le chat
     */
    public static function getAllSousComptes($limit = 15)
    {
        try {
            $sousComptes = SousCompte::with('compte')
                ->limit($limit)
                ->get();
            
            if ($sousComptes->isEmpty()) {
                return "Aucun sous-compte disponible dans la base de données.";
            }
            
            $response = "📊 Les sous-comptes disponibles :\n\n";
            
            foreach ($sousComptes as $index => $sc) {
                $rang = $index + 1;
                $response .= "{$rang}. **{$sc->Code_sous_compte}** - {$sc->Libelle}\n";
                $response .= "   └─ Compte parent : {$sc->compte->Code_compte}\n\n";
            }
            
            $totalCount = SousCompte::count();
            if ($totalCount > $limit) {
                $response .= "... et " . ($totalCount - $limit) . " autres sous-comptes\n";
                $response .= "Demandez-moi des détails sur un code spécifique !";
            }
            
            return $response;
        } catch (\Exception $e) {
            return "Erreur lors de la récupération des sous-comptes : " . $e->getMessage();
        }
    }
    
    /**
     * Recherche un sous-compte par code
     */
    public static function searchByCode($message)
{
    try {
        // Extraire uniquement 6 chiffres consécutifs
        preg_match('/\b(\d{6})\b/', $message, $matches);
        
        if (empty($matches[1])) {
            return "Veuillez préciser le code du sous-compte (ex: 401001, 512001).";
        }
        
        $code = $matches[1];
        $sousCompte = SousCompte::with('compte')
            ->where('Code_sous_compte', $code)
            ->first();
        
        if (!$sousCompte) {
            return "❌ Le sous-compte **{$code}** n'existe pas en base de données.";
        }
        
        return self::formatDetailSousCompte($sousCompte);
    } catch (\Exception $e) {
        return "Erreur lors de la recherche : " . $e->getMessage();
    }
}

    
    /**
     * Récupère les sous-comptes d'un compte parent
     */
    public static function getSousComptesParCompte($message)
    {
        try {
            // Extraire le code du compte (format : 401, 512, etc.)
            preg_match('/compte\s+([A-Z0-9]{2,4})|([A-Z0-9]{2,4})/i', $message, $matches);
            
            $codeCompte = $matches[1] ?? $matches[2] ?? null;
            
            if (!$codeCompte) {
                return "Veuillez préciser le code du compte (ex: 401, 512, 401).";
            }
            
            $codeCompte = strtoupper($codeCompte);
            
            // Chercher le compte
            $compte = Compte::where('Code_compte', $codeCompte)
                ->first();
            
            if (!$compte) {
                return "❌ Le compte **{$codeCompte}** n'existe pas.";
            }
            
            $sousComptes = SousCompte::where('Id_Compte', $compte->Id_Compte)
                ->get();
            
            if ($sousComptes->isEmpty()) {
                return "Aucun sous-compte trouvé pour le compte {$codeCompte} ({$compte->Libelle}).";
            }
            
            $response = "📋 Sous comptes du compte **{$codeCompte}** :\n";
            $response .= "{$compte->Libelle}\n\n";
            
            foreach ($sousComptes as $index => $sc) {
                $rang = $index + 1;
                $response .= "{$rang}. **{$sc->Code_sous_compte}** - {$sc->Libelle}\n";
            }
            
            $response .= "\n---\n";
            $response .= "📊 Total : **" . count($sousComptes) . "** sous-comptes";
            
            return $response;
        } catch (\Exception $e) {
            return "Erreur lors de la récupération : " . $e->getMessage();
        }
    }
    
    /**
     * Recherche par libellé (description)
     */
    public static function searchByLibelle($message)
    {
        try {
            // Nettoyer le message
            $searchText = ChatUtilesController::normalizeText($message);
            $searchText = str_replace(['cherche', 'trouve', 'recherche', 'sous-compte', 'sous compte'], '', $searchText);
            $searchText = trim($searchText);
            
            if (strlen($searchText) < 2) {
                return "Veuillez préciser au moins 2 caractères pour la recherche.";
            }
            
            $sousComptes = SousCompte::with('compte')
                ->where('Libelle', 'LIKE', "%{$searchText}%")
                ->limit(10)
                ->get();
            
            if ($sousComptes->isEmpty()) {
                return "Aucun sous-compte trouvé avec '{$searchText}'.";
            }
            
            $response = "🔍 Résultats de recherche pour '**{$searchText}**' :\n\n";
            
            foreach ($sousComptes as $index => $sc) {
                $rang = $index + 1;
                $response .= "{$rang}. **{$sc->Code_sous_compte}** - {$sc->Libelle}\n";
                $response .= "   └─ Compte : {$sc->compte->Code_compte}\n\n";
            }
            
            return $response;
        } catch (\Exception $e) {
            return "Erreur lors de la recherche : " . $e->getMessage();
        }
    }
    
    /**
     * Obtient les statistiques sur les sous-comptes
     */
    public static function getStatistiques()
    {
        try {
            $totalSousComptes = SousCompte::count();
            $comptes = Compte::count();
            $comptesAyantSousComptes = SousCompte::distinct('Id_Compte')->count();
            
            $response = "📈 Statistiques des sous-comptes :\n\n";
            $response .= "• **Total de sous-comptes** : {$totalSousComptes}\n";
            $response .= "• **Comptes disponibles** : {$comptes}\n";
            $response .= "• **Comptes avec sous-comptes** : {$comptesAyantSousComptes}\n";
            
            if ($comptesAyantSousComptes > 0) {
                $moyenne = number_format($totalSousComptes / $comptesAyantSousComptes, 2);
                $response .= "• **Moyenne par compte** : {$moyenne}\n";
            }
            
            return $response;
        } catch (\Exception $e) {
            return "Erreur lors du calcul des statistiques : " . $e->getMessage();
        }
    }
    
    /**
     * Formate les détails complets d'un sous-compte
     */
    private static function formatDetailSousCompte($sousCompte)
    {
        $response = "✅ Détails du sous-compte :\n\n";
        $response .= "**Code** : {$sousCompte->Code_sous_compte},\n";
        $response .= "**Libellé** : {$sousCompte->Libelle},\n";
        $response .= "**Compte parent** : {$sousCompte->compte->Code_compte} - {$sousCompte->compte->Libelle},\n";
        $response .= "Avez-vous d'autres questions sur ce sous-compte ?";
        
        return $response;
    }
}
