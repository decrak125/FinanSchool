<?php
// app/Http/Controllers/ChatController.php

namespace App\Http\Controllers\ChatBot;

use App\Models\ChatBot\ChatMessage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use App\Http\Controllers\ChatBot\DepensesProfitsController;
use App\Http\Controllers\ChatBot\ChatUtilesController;
use App\Http\Controllers\ChatBot\DiagnosticController;

class ChatController extends Controller
{
    public function sendMessage(Request $request)
    {
        $request->validate([
            'message' => 'required|string',
            'session_id' => 'required|string',
        ]);

        $userMessage = $request->message;
        $sessionId = $request->session_id;
        
        // Récupérer l'utilisateur connecté via le token
        $user = Auth::user();
        $userId = $user ? $user->id : null;

        // Enregistrer le message
        $chatMessage = ChatMessage::create([
            'message' => $userMessage,
            'session_id' => $sessionId,
            'user_id' => $userId,
        ]);

        // Générer une réponse
        $response = $this->generateSimpleResponse($userMessage);

        // Mettre à jour avec la réponse
        $chatMessage->update(['response' => $response]);

        return response()->json([
            'response' => $response,
            'session_id' => $sessionId,
            'suggestions' => $this->getSuggestions($userMessage),
            'user' => $user ? [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email
            ] : null
        ]);
    }

    public function getChatHistory($sessionId)
    {
        $user = Auth::user();
        
        $query = ChatMessage::where('session_id', $sessionId);
        
        // Si l'utilisateur est connecté, on peut filtrer par user_id pour la sécurité
        if ($user) {
            $query->where(function($q) use ($user) {
                $q->where('user_id', $user->id)
                  ->orWhereNull('user_id'); // Inclure aussi les messages sans user_id
            });
        }
        
        $messages = $query->orderBy('created_at', 'asc')->get();

        return response()->json($messages);
    }

    public function getUserChats()
    {
        $user = Auth::user();
        
        if (!$user) {
            return response()->json([]);
        }

        // Récupérer les sessions de chat distinctes pour cet utilisateur
        $sessions = ChatMessage::where('user_id', $user->id)
            ->select('session_id')
            ->distinct()
            ->with(['latestMessage' => function($query) {
                $query->orderBy('created_at', 'desc');
            }])
            ->get();

        return response()->json($sessions);
    }

private function generateSimpleResponse($message)
{
    $messagetext = ChatUtilesController::normalizeText($message);
    
    if (str_contains($messagetext, 'bonjour') || str_contains($messagetext, 'salut') || str_contains($messagetext, 'hello') || str_contains($messagetext, 'hi')) {
        return "Bonjour ! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?";
    }

    // Détection des questions sur les centres de coût
    if (str_contains($messagetext, 'depense') || str_contains($messagetext, 'charge') || str_contains($messagetext, 'cout') || (str_contains($messagetext, 'sorti') && str_contains($messagetext, 'argent'))) {
        $year = ChatUtilesController::extractYearFromMessage($messagetext);
        
        try {
                if ((str_contains($messagetext, 'plus') && str_contains($messagetext, 'grand')) || str_contains($messagetext, 'max')) {
                    if (str_contains($messagetext, 'centre')) {
                    return DepensesProfitsController::getBiggestCentre($year, 1);
                    }
                    else {
                    return DepensesProfitsController::getBiggestAffectation(1, $year, 1);
                    }
                } 
                elseif ($this->containsNormalized($messagetext, ['classement', 'top'])) {
                    if (str_contains($messagetext, 'centre')) {
                    return DepensesProfitsController::getClassementCentre($year, 1, 5);
                    }
                    else {
                    return DepensesProfitsController::getBiggestAffectation(2,$year, 1);
                    }
                }
                elseif ($this->containsNormalized($messagetext, ['tout', 'liste'])) {
                    if (str_contains($messagetext, 'centre')) {
                    return DepensesProfitsController::getClassementCentre($year, 1, 0);
                    }
                    else {
                    return DepensesProfitsController::getBiggestAffectation(3,$year, 1);
                    }
                }

        } catch (\Exception $e) {
            return "Désolé, une erreur s'est produite lors de l'accès aux données financières.";
        }
    }

    // Détection des questions sur le diagnostic complet
    if (str_contains($messagetext, 'resume') || str_contains($messagetext, 'bilan') || str_contains($messagetext, 'analyse globale') || str_contains($messagetext, 'état financier') || str_contains($messagetext, 'santé financière')) {
        try {
            // Extraire les dates du message
            $year = ChatUtilesController::extractYearFromMessage($messagetext);
            
            // Si pas de dates spécifiques, utiliser l'année courante
            if (empty($dates)) {
                $year = ChatUtilesController::extractYearFromMessage($messagetext);
                if ($year) {
                    $dateDebut = "{$year}-01-01";
                    $dateFin = "{$year}-12-31";
                } else {
                    // Par défaut : année en cours
                    $currentYear = date('Y');
                    $dateDebut = "{$currentYear}-01-01";
                    $dateFin = "{$currentYear}-12-31";
                }
            } else {
                $dateDebut = $dates['start'] ?? null;
                $dateFin = $dates['end'] ?? null;
            }
            
            if (!$dateDebut || !$dateFin) {
                return "Pour faire un diagnostic, j'ai besoin de connaître la période. Par exemple : 'diagnostic janvier à mars 2024' ou 'bilan 2023'.";
            }
            
            // Vérifier le type de diagnostic demandé
            // if ($this->containsNormalized($messagetext, ['résumé', 'resume', 'synthèse', 'synthèse'])) {
            //     return DiagnosticController::getDiagnosticResume($dateDebut, $dateFin);
            // }
            // elseif ($this->containsNormalized($messagetext, ['alerte', 'problème', 'risque', 'attention'])) {
            //     return DiagnosticController::getAlertesDiagnostic($dateDebut, $dateFin);
            // }
            // elseif (str_contains($messagetext, 'centre') && $this->extractCentreFromMessage($messagetext)) {
            //     $centreId = $this->extractCentreFromMessage($messagetext);
            //     return DiagnosticController::getDiagnosticParCentre($dateDebut, $dateFin, $centreId);
            // }
            // else {
                // Diagnostic complet par défaut
                return DiagnosticController::getDiagnosticComplet($dateDebut, $dateFin);
            // }
            
        } catch (\Exception $e) {
            return "Désolé, une erreur s'est produite lors de la génération du diagnostic financier.";
        }
    }

    // Ajoutez cette fonction d'extraction pour les centres si nécessaire
    // private function extractCentreFromMessage($message)
    // {
    //     // Logique pour extraire l'ID ou le nom du centre depuis le message
    //     // Par exemple, chercher des motifs comme "centre X", "service Y", etc.
    //     // Retourne l'identifiant du centre ou null
    // }

    return "Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !";
}

// Ajoutez cette méthode utilitaire si elle n'existe pas
private function extractCentreFromMessage($message)
{
    // Exemple simple - à adapter selon vos besoins
    $patterns = [
        '/centre (\d+)/i',
        '/centre de (\w+)/i',
        '/service (\w+)/i',
        '/département (\w+)/i'
    ];
    
    foreach ($patterns as $pattern) {
        if (preg_match($pattern, $message, $matches)) {
            return $matches[1] ?? null;
        }
    }
    
    // Chercher dans une liste prédéfinie de centres
    $centresConnus = [
        'administration' => 1,
        'pedagogique' => 2,
        'maintenance' => 3,
        'restauration' => 4,
        // Ajoutez vos centres ici
    ];
    
    foreach ($centresConnus as $nom => $id) {
        if (str_contains(strtolower($message), $nom)) {
            return $id;
        }
    }
    
    return null;
}private function containsNormalized($haystack, $needles)
    {
        $normalizedHaystack = ChatUtilesController::normalizeText($haystack);
        
        foreach ((array)$needles as $needle) {
            $normalizedNeedle = ChatUtilesController::normalizeText($needle);
            if (str_contains($normalizedHaystack, $normalizedNeedle)) {
                return true;
            }
        }
        return false;
    }
    private function getSuggestions($message)
    {
        return [
            // "Quel est le budget total ?",
            // "Comment sont réparties les dépenses ?", 
            // "Quel est le coût par élève ?",
            "Un résumé des indicateurs financiers de cette année."
        ];
    }
}