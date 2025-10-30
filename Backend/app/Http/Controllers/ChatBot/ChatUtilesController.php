<?php
// app/Http/Controllers/ChatController.php

namespace App\Http\Controllers\ChatBot;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;

class ChatUtilesController extends Controller
{

    public static function extractYearFromMessage($message)
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

    public static function normalizeText($text)
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

}