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

    public static function extractCodeCompte($message)
{
    if (preg_match('/\b(\d{3,6})\b/', $message, $matches)) {
        return $matches[1];
    }
    return null;
}

public static function extractDateRange($message)
{
    if (preg_match('/du\s+(\d{2}\/\d{2}\/\d{4})\s+au\s+(\d{2}\/\d{2}\/\d{4})/i', $message, $matches)) {
        return ['start' => $matches[1], 'end' => $matches[2]];
    }
    return null;
}

public static function extractMonthFromMessage($message)
{
    $months = [
        'janvier' => 1, 'février' => 2, 'mars' => 3, 'avril' => 4,
        'mai' => 5, 'juin' => 6, 'juillet' => 7, 'août' => 8,
        'septembre' => 9, 'octobre' => 10, 'novembre' => 11, 'décembre' => 12
    ];
    foreach ($months as $name => $num) {
        if (str_contains(self::normalizeText($message), self::normalizeText($name))) {
            return $num;
        }
    }
    return null;
}


}