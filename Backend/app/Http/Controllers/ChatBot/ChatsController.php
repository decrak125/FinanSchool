<?php
// app/Http/Controllers/ChatBot/ChatsController.php

namespace App\Http\Controllers\ChatBot;

use App\Models\ChatBot\ChatMessage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use App\Http\Controllers\ChatBot\ChatSousCompteController;
use App\Http\Controllers\ChatBot\ChatUtilesController;
use App\Http\Controllers\ChatBot\ChatJournalController; // Assurez-vous que ce contrôleur existe
use App\Http\Controllers\ChatBot\ChatGrandLivresController;
use App\Http\Controllers\ChatBot\ChatEtatsFinanciersController; // <--- NOUVEL IMPORT

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
        
        if ($user) {
            $query->where(function($q) use ($user) {
                $q->where('user_id', $user->id)
                  ->orWhereNull('user_id');
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
        
        // 1. Salutations
        if (str_contains($messagetext, 'bonjour') || str_contains($messagetext, 'salut') || str_contains($messagetext, 'hello') || str_contains($messagetext, 'hi')) {
            return "Bonjour {$userName}! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?";
        }

        // 2. DÉTECTION ÉTATS FINANCIERS (Nouveau bloc)
        // Liste des mots-clés liés au Bilan et Compte de Résultat
        $keywordsEtatsFinanciers = [
            'chiffre d\affaire', 'ca ', 'resultat', 'benefice', 'perte', 
            'immobilisation', 'stock', 'creance', 'dette', 'emprunt', 
            'capital', 'tresorerie', 'charge personnel', 'achat', 'impot'
        ];

        // On vérifie si le message contient l'un de ces mots-clés
        if ($this->containsNormalized($messagetext, $keywordsEtatsFinanciers)) {
             // Cas spécifique pour l'aide
             if (str_contains($messagetext, 'aide') || str_contains($messagetext, 'comment')) {
                 return ChatEtatsFinanciersController::aidePrompts();
             }
             // Sinon, on lance le calcul financier
             return ChatEtatsFinanciersController::getIndicateurFinancier($message);
        }

        // 3. DÉTECTION SOUS-COMPTES
        if (str_contains($messagetext, 'sous-compte') || 
            str_contains($messagetext, 'sous compte') || 
            str_contains($messagetext, 'souscompte')) {
            
            try {
                if (str_contains($messagetext, 'liste') || str_contains($messagetext, 'tous') || str_contains($messagetext, 'affiche')) {
                    return ChatSousCompteController::getAllSousComptes();
                }
                if (str_contains($messagetext, 'cherche') || str_contains($messagetext, 'code') || str_contains($messagetext, 'numero')) {
                    return ChatSousCompteController::searchByCode($messagetext);
                }
                if (str_contains($messagetext, 'compte') && preg_match('/\d{3,4}/', $messagetext)) {
                    return ChatSousCompteController::getSousComptesParCompte($messagetext);
                }
                if (str_contains($messagetext, 'libelle') || str_contains($messagetext, 'description')) {
                    return ChatSousCompteController::searchByLibelle($messagetext);
                }
                if (str_contains($messagetext, 'statistique') || str_contains($messagetext, 'stats')) {
                    return ChatSousCompteController::getStatistiques();
                }
                return ChatSousCompteController::getAllSousComptes();
            } catch (\Exception $e) {
                return "Erreur lors du traitement de la question : " . $e->getMessage();
            }
        }

        // 4. DÉTECTION JOURNAUX
        if (str_contains($messagetext, 'journal') || str_contains($messagetext, 'journaux') || str_contains($messagetext, 'journals')) {
            if (str_contains($messagetext, 'tous') || str_contains($messagetext, 'liste') || str_contains($messagetext, 'affiche')) {
                return ChatJournalController::getAllJournaux();
            }
            if (preg_match('/journal\s+[A-Za-z0-9]+/', $messagetext)) {
                return ChatJournalController::detailJournal($messagetext);
            }
            return "Veuillez préciser votre demande concernant les journaux. Vous pouvez demander la liste des journaux ou le détail d'un journal spécifique en mentionnant son code.";
        }

        // 5. DÉTECTION GRAND LIVRE
        if (str_contains($messagetext, 'grand livre')) {
            if (str_contains($messagetext, 'aide') || str_contains($messagetext, 'exemple')) {
                return ChatGrandLivresController::aidePrompts();
            }
            if (str_contains($messagetext, 'solde')) {
                return ChatGrandLivresController::getSoldeGrandLivre($message);
            }
            if (str_contains($messagetext, 'libellé') || str_contains($messagetext, 'motif') || str_contains($messagetext, 'cherche') || str_contains($messagetext, 'tiers')) {
                return ChatGrandLivresController::searchByLibelle($message);
            }
            return ChatGrandLivresController::getEcrituresParCompte($message);
        }

        // 6. RÉPONSE PAR DÉFAUT
        return "Bonjour {$userName}, Je suis votre assistant financier. Je peux vous aider sur :\n\n" .
               "• 📊 **États Financiers** : CA, Résultat, Immobilisations, Dettes...\n" .
               "• 📒 **Grand Livre** : Soldes, recherche d'écritures...\n" .
               "• 🔢 **Sous-comptes** : Recherche, liste par compte...\n" .
               "• 📓 **Journaux** : Liste et détails.\n\n" .
               "Posez simplement votre question !";
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
            "Quel est le chiffre d'affaires ?",
            "Quel est le résultat net ?",
            "Solde du compte 512",
            "Liste des journaux"
        ];
    }
}
