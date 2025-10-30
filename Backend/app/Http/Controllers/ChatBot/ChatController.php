<?php
// app/Http/Controllers/ChatController.php

namespace App\Http\Controllers\ChatBot;

use App\Models\ChatBot\ChatMessage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use App\Http\Controllers\ChatBot\DepensesProfitsController;

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
    $messagetext = $this->normalizeText($message);
    
    if (str_contains($messagetext, 'bonjour') || str_contains($messagetext, 'salut') || str_contains($messagetext, 'hello') || str_contains($messagetext, 'hi')) {
        return "Bonjour ! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?";
    }

    // Détection des questions sur les centres de coût
    if (str_contains($messagetext, 'depense') || str_contains($messagetext, 'charge') || str_contains($messagetext, 'cout')) {
        $year = $this->extractYearFromMessage($messagetext);
        
        try {
            if (str_contains($messagetext, 'centre')) {
                if ((str_contains($messagetext, 'plus') && str_contains($messagetext, 'grand')) || str_contains($messagetext, 'max')) {
                    return DepensesProfitsController::getBiggestCentre($year, 1);
                } 
                elseif ($this->containsNormalized($messagetext, ['classement', 'top', 'liste'])) {
                    return DepensesProfitsController::getClassementCentre($year, 1);
                }
            }
        } catch (\Exception $e) {
            return "Désolé, une erreur s'est produite lors de l'accès aux données financières.";
        }
    }
        
    return "Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !";
}
    private function containsNormalized($haystack, $needles)
    {
        $normalizedHaystack = $this->normalizeText($haystack);
        
        foreach ((array)$needles as $needle) {
            $normalizedNeedle = $this->normalizeText($needle);
            if (str_contains($normalizedHaystack, $normalizedNeedle)) {
                return true;
            }
        }
        return false;
    }
    private function extractYearFromMessage($message)
    {
        // Recherche d'un motif année (4 chiffres)
        if (preg_match('/\b(20\d{2})\b/', $message, $matches)) {
            return $matches[1];
        }
        
        // Recherche d'années en toutes lettres
        $yearKeywords = [
            'cette année' => date('Y'),
            'l\'année dernière' => date('Y') - 1,
            'l\'année prochaine' => date('Y') + 1,
            'année en cours' => date('Y'),
            'année courante' => date('Y'),
        ];
        
        foreach ($yearKeywords as $keyword => $year) {
            if (str_contains($message, $keyword)) {
                return $year;
            }
        }
        
        // Par défaut, année courante
        return date('Y');
    }

    private function normalizeText($text)
    {
        $text = strtolower(trim($text));
        
        // Remplacer les caractères accentués
        $search = [
            'à', 'â', 'ä', 'á', 'ã', 'å',
            'è', 'é', 'ê', 'ë', 
            'ì', 'í', 'î', 'ï',
            'ò', 'ó', 'ô', 'ö', 'õ',
            'ù', 'ú', 'û', 'ü', 
            'ç', 'ñ',
            'œ', 'æ'
        ];
        
        $replace = [
            'a', 'a', 'a', 'a', 'a', 'a',
            'e', 'e', 'e', 'e',
            'i', 'i', 'i', 'i',
            'o', 'o', 'o', 'o', 'o',
            'u', 'u', 'u', 'u',
            'c', 'n',
            'oe', 'ae'
        ];
        
        return str_replace($search, $replace, $text);
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