<?php

namespace App\Http\Controllers\Export;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\ExportDiagnosticDataService;

class ExportDataController extends Controller
{
    protected $dataService;
    
    public function __construct(ExportDiagnosticDataService $dataService)
    {
        $this->dataService = $dataService;
    }
    
    /**
     * Récupérer les données pour l'export
     */
    public function getDonneesExport(Request $request, $annee = null)
    {
        // Si l'année est dans l'URL paramètre
        if ($annee) {
            $anneeExercice = $annee;
        } 
        // Si l'année est dans la query string
        else if ($request->has('annee_exercice')) {
            $anneeExercice = $request->input('annee_exercice');
        }
        // Si l'année est dans le body (POST)
        else if ($request->filled('annee_exercice')) {
            $anneeExercice = $request->input('annee_exercice');
        }
        else {
            return response()->json([
                'success' => false,
                'message' => 'Le champ année d\'exercice est requis'
            ], 400);
        }
        
        try {
            $data = $this->dataService->preparerDonneesExport($anneeExercice);
            
            return response()->json([
                'success' => true,
                'data' => $data,
                'message' => 'Données préparées pour l\'export'
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la préparation des données',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    /**
     * Version POST pour compatibilité
     */
    public function postDonneesExport(Request $request)
    {
        return $this->getDonneesExport($request);
    }
}