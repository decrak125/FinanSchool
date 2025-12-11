<?php

namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;

class DiagnosticControllerUnifie extends Controller
{
    /**
     * Récupère TOUS les indicateurs pour le dashboard
     */
    public function getDashboardComplet(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);

        $dateDebut = $this->formatDate($request->date_debut);
        $dateFin = $this->formatDate($request->date_fin);
        
        $cacheKey = "dashboard_complet_{$dateDebut}_{$dateFin}";
        
        return Cache::remember($cacheKey, 3600, function() use ($dateDebut, $dateFin) {
            return $this->collecterDashboardComplet($dateDebut, $dateFin);
        });
    }
    
    private function collecterDashboardComplet($dateDebut, $dateFin)
    {
        $resultats = [
            'rentabilite' => $this->collecterRentabilite($dateDebut, $dateFin),
            'solvabilite' => $this->collecterSolvabilite($dateDebut, $dateFin),
            'liquidite' => $this->collecterLiquidite($dateDebut, $dateFin),
            'pedagogique' => $this->collecterPedagogique($dateDebut, $dateFin)
        ];
        
        return [
            'success' => true,
            'periode' => [
                'date_debut' => $dateDebut,
                'date_fin' => $dateFin
            ],
            'aspects' => $resultats,
            'metadata' => [
                'generated_at' => now()->toIso8601String(),
                'version' => '3.0'
            ]
        ];
    }
    
    /**
     * COLLECTE RENTABILITÉ
     */
    private function collecterRentabilite($dateDebut, $dateFin)
    {
        $controller = app(IndicateurRentabiliteController::class);
        $request = new Request(['date_debut' => $dateDebut, 'date_fin' => $dateFin]);
        
        $resultat = ['success' => true];
        
        try {
            // Marge Brute
            $response = $controller->calculMargeBrute($request);
            $data = json_decode($response->getContent(), true);
            if ($data['success']) $resultat['marge_brute'] = $data['marge_brute'];
            
            // Marge Nette
            $response = $controller->calculMargeNette($request);
            $data = json_decode($response->getContent(), true);
            if ($data['success']) $resultat['marge_nette'] = $data['marge_nette'];
            
            // ROE
            $response = $controller->calculROE($request);
            $data = json_decode($response->getContent(), true);
            if ($data['success']) $resultat['roe'] = $data['roe'];
            
            // ROA
            $response = $controller->calculROA($request);
            $data = json_decode($response->getContent(), true);
            if ($data['success']) $resultat['roa'] = $data['roa'];
            
        } catch (\Exception $e) {
            $resultat['success'] = false;
            $resultat['error'] = $e->getMessage();
        }
        
        return $resultat;
    }
    
    /**
     * COLLECTE SOLVABILITÉ
     */
    private function collecterSolvabilite($dateDebut, $dateFin)
    {
        $controller = app(IndicateurSolvabiliteController::class);
        $request = new Request(['date_debut' => $dateDebut, 'date_fin' => $dateFin]);
        
        $resultat = ['success' => true];
        
        try {
            // Autonomie Financière
            $response = $controller->calculAutonomieFinanciere($request);
            $data = json_decode($response->getContent(), true);
            if ($data['success']) $resultat['autonomie_financiere'] = $data['autonomie_financiere'];
            
            // Ratio Endettement
            $response = $controller->calculRatioEndettement($request);
            $data = json_decode($response->getContent(), true);
            if ($data['success']) $resultat['ratio_endettement'] = $data['ratio_endettement'];
            
            // Capacité Remboursement
            $response = $controller->calculCapaciteRemboursement($request);
            $data = json_decode($response->getContent(), true);
            if ($data['success']) $resultat['capacite_remboursement'] = $data['capacite_remboursement'];
            
        } catch (\Exception $e) {
            $resultat['success'] = false;
            $resultat['error'] = $e->getMessage();
        }
        
        return $resultat;
    }
    
    /**
     * COLLECTE LIQUIDITÉ
     */
    private function collecterLiquidite($dateDebut, $dateFin)
    {
        $controller = app(IndicateurLiquiditeController::class);
        $request = new Request(['date_debut' => $dateDebut, 'date_fin' => $dateFin]);
        
        $resultat = ['success' => true];
        
        try {
            // Trésorerie Nette
            $response = $controller->calculTresorerieNette($request);
            $data = json_decode($response->getContent(), true);
            if ($data['success']) $resultat['tresorerie_nette'] = $data['tresorerie_nette'];
            
            // Ratio Liquidité Générale
            $response = $controller->calculRatioLiquiditeGenerale($request);
            $data = json_decode($response->getContent(), true);
            if ($data['success']) $resultat['ratio_liquidite_generale'] = $data['ratio_liquidite_generale'];
            
            // BFR
            $response = $controller->calculBFR($request);
            $data = json_decode($response->getContent(), true);
            if ($data['success']) $resultat['bfr'] = $data['bfr'];
            
        } catch (\Exception $e) {
            $resultat['success'] = false;
            $resultat['error'] = $e->getMessage();
        }
        
        return $resultat;
    }
    
    /**
     * COLLECTE PÉDAGOGIQUE
     */
    private function collecterPedagogique($dateDebut, $dateFin)
    {
        $controller = app(IndicateurPedagogiqueController::class);
        $request = new Request(['date_debut' => $dateDebut, 'date_fin' => $dateFin]);
        
        try {
            // Cette méthode retourne déjà tous les indicateurs
            $response = $controller->calculTousIndicateursPedagogiques($request);
            $data = json_decode($response->getContent(), true);
            
            if ($data['success']) {
                return [
                    'success' => true,
                    'indicateurs_pedagogiques' => $data['indicateurs_pedagogiques']
                ];
            }
            
            return ['success' => false, 'error' => 'Échec pédagogique'];
            
        } catch (\Exception $e) {
            return ['success' => false, 'error' => $e->getMessage()];
        }
    }
    
    /**
     * Formate une date pour éviter les erreurs PostgreSQL
     */
    private function formatDate($dateString)
    {
        // Corrige le format 2025-12-01-01 → 2025-12-01
        if (preg_match('/^(\d{4}-\d{2}-\d{2})-\d{2}$/', $dateString, $matches)) {
            return $matches[1];
        }
        
        // Si déjà bon format
        if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateString)) {
            return $dateString;
        }
        
        // Sinon parse avec Carbon
        try {
            return \Carbon\Carbon::parse($dateString)->format('Y-m-d');
        } catch (\Exception $e) {
            return $dateString; // La validation s'en occupera
        }
    }
}