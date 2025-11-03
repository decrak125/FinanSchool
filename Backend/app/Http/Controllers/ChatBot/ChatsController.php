<?php
// app/Http/Controllers/ChatController.php

namespace App\Http\Controllers\ChatBot;

use App\Models\ChatBot\ChatMessage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use App\Http\Controllers\ChatBot\ChatSousCompteController;
use App\Http\Controllers\ChatBot\ChatUtilesController;

class ChatsController extends Controller
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
     $user = Auth::user();
    $userName = $user ? $user->name : "Utilisateur";
    
    if (str_contains($messagetext, 'bonjour') || str_contains($messagetext, 'salut') || str_contains($messagetext, 'hello') || str_contains($messagetext, 'hi')) {
        return "Bonjour {$userName}! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?";
    }

    // Détection des questions sur les centres de coût

    // Dans la méthode generateSimpleResponse() du ChatController

// Détection des questions sur les sous-comptes
if (str_contains($messagetext, 'sous-compte') || 
    str_contains($messagetext, 'sous compte') || 
    str_contains($messagetext, 'souscompte')) {
    
    try {
        // "Liste tous les sous-comptes"
        if (str_contains($messagetext, 'liste') || str_contains($messagetext, 'tous') || str_contains($messagetext, 'affiche')) {
            return ChatSousCompteController::getAllSousComptes();
        }
        
        // "Cherche le sous-compte 401001"
        if (str_contains($messagetext, 'cherche') || str_contains($messagetext, 'code') || str_contains($messagetext, 'numero')) {
            return ChatSousCompteController::searchByCode($messagetext);
        }
        
        // "Quels sont les sous-comptes du compte 401"
        if (str_contains($messagetext, 'compte') && preg_match('/\d{3,4}/', $messagetext)) {
            return ChatSousCompteController::getSousComptesParCompte($messagetext);
        }
        
        // "Cherche les sous-comptes avec trésorerie"
        if (str_contains($messagetext, 'libelle') || str_contains($messagetext, 'description')) {
            return ChatSousCompteController::searchByLibelle($messagetext);
        }
        
        // "Statistiques sous-comptes"
        if (str_contains($messagetext, 'statistique') || str_contains($messagetext, 'stats')) {
            return ChatSousCompteController::getStatistiques();
        }
        
        
        // Par défaut
        return ChatSousCompteController::getAllSousComptes();
    } catch (\Exception $e) {
        return "Erreur lors du traitement de la question : " . $e->getMessage();
    }
}

if (str_contains($messagetext, 'journal') || str_contains($messagetext, 'journaux') || str_contains($messagetext, 'journals')) {
    if (str_contains($messagetext, 'tous') || str_contains($messagetext, 'liste') || str_contains($messagetext, 'affiche')) {
        return ChatJournalController::getAllJournaux();
    }
    if (preg_match('/journal\s+[A-Za-z0-9]+/', $messagetext)) {
        return ChatJournalController::detailJournal($messagetext);
    }
    
    return "Veuillez préciser votre demande concernant les journaux. Vous pouvez demander la liste des journaux ou le détail d'un journal spécifique en mentionnant son code.";
            // Ajouter d'autres cas (par libellé, par type, ...)
    }

        
    return "Bonjour {$userName}, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !";
}
private function containsNormalized($haystack, $needles)
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
            "Quels sont nos ratios financiers ?"
        ];
    }
}