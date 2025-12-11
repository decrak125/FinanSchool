<?php
namespace App\Http\Controllers\Analyse;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\DiagnosticService;

class DiagnosticController extends Controller
{
    protected $diagnosticService;
    
    public function __construct(DiagnosticService $diagnosticService)
    {
        $this->diagnosticService = $diagnosticService;
    }
    
    public function getDiagnostic(Request $request)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);
        
        try {
            $diagnostic = $this->diagnosticService->calculerDiagnosticGlobal(
                $request->date_debut,
                $request->date_fin
            );
            
            return response()->json([
                'success' => true,
                'data' => $diagnostic,
                'metadata' => [
                    'version' => '1.0',
                    'generated_at' => now()->toIso8601String()
                ]
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors du calcul du diagnostic',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    
    public function getDiagnosticAspect(Request $request, $aspect)
    {
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin' => 'required|date|after_or_equal:date_debut'
        ]);
        
        $aspectsValides = ['rentabilite', 'solvabilite', 'liquidite', 'pedagogique'];
        
        if (!in_array($aspect, $aspectsValides)) {
            return response()->json([
                'success' => false,
                'message' => 'Aspect non valide. Choisissez parmi: ' . implode(', ', $aspectsValides)
            ], 400);
        }
        
        try {
            $diagnostic = $this->diagnosticService->calculerDiagnosticGlobal(
                $request->date_debut,
                $request->date_fin
            );
            
            return response()->json([
                'success' => true,
                'data' => $diagnostic['aspects'][$aspect] ?? null,
                'metadata' => [
                    'aspect' => $aspect,
                    'periode' => [
                        'date_debut' => $request->date_debut,
                        'date_fin' => $request->date_fin
                    ]
                ]
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => "Erreur lors de l'analyse de l'aspect {$aspect}",
                'error' => $e->getMessage()
            ], 500);
        }
    }
}