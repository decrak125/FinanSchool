<?php

namespace App\Helpers;

use Carbon\Carbon;

class DateHelper
{
    /**
     * Nettoie et formate une date pour PostgreSQL
     * Convertit: 2025-12-01-01 -> 2025-12-01
     */
    public static function cleanDateForSql($dateString)
    {
        if (empty($dateString)) {
            return null;
        }
        
        // Si format YYYY-MM-DD-HH (problème détecté)
        if (preg_match('/^(\d{4}-\d{2}-\d{2})-\d{2}$/', $dateString, $matches)) {
            return $matches[1];
        }
        
        // Si format YYYY-MM-DD
        if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateString)) {
            return $dateString;
        }
        
        // Essayer de parser avec Carbon
        try {
            return Carbon::parse($dateString)->format('Y-m-d');
        } catch (\Exception $e) {
            return null;
        }
    }
    
    /**
     * Valide une période de dates
     */
    public static function validatePeriod($dateDebut, $dateFin)
    {
        $cleanDebut = self::cleanDateForSql($dateDebut);
        $cleanFin = self::cleanDateForSql($dateFin);
        
        if (!$cleanDebut || !$cleanFin) {
            return [
                'success' => false,
                'message' => 'Format de date invalide'
            ];
        }
        
        if ($cleanDebut > $cleanFin) {
            return [
                'success' => false,
                'message' => 'La date de début doit être avant la date de fin'
            ];
        }
        
        return [
            'success' => true,
            'date_debut' => $cleanDebut,
            'date_fin' => $cleanFin
        ];
    }
}