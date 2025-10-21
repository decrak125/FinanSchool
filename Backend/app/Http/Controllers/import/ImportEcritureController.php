<?php

namespace App\Http\Controllers\import;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use App\Models\Saisie\MouvementEcriture;
use App\Models\Saisie\LigneEcriture;
use App\Models\Saisie\Journal;
use App\Models\PlanCompte\SousCompte;
use Illuminate\Support\Facades\Auth;
use App\Models\import\ImportHistory;
use Exception;

class ImportEcritureController extends Controller
{
    public function import(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file_ecritures' => 'required|file|mimes:csv,txt|max:10240',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Fichier invalide',
                'messages' => $validator->errors()
            ], 422);
        }

        DB::beginTransaction();

        try {
            $stats = $this->processImport($request->file('file_ecritures'));

            // Si des erreurs sont détectées, annuler tout
            if (!empty($stats['errors'])) {
                DB::rollBack();
                
                ImportHistory::create([
                    'nom_fichier'       => $request->file('file_ecritures')->getClientOriginalName(),
                    'imported_by'       => Auth::id(),
                    'nombre_mouvements' => 0,
                    'nombre_lignes'     => 0,
                    'statut'            => 'échec',
                    'erreur'            => implode("\n", $stats['errors']),
                ]);

                return response()->json([
                    'error' => 'Erreurs détectées lors de l\'importation',
                    'errors' => $stats['errors'],
                    'message' => 'Aucune donnée n\'a été importée'
                ], 422);
            }

            DB::commit();

            ImportHistory::create([
                'nom_fichier'       => $request->file('file_ecritures')->getClientOriginalName(),
                'imported_by'       => Auth::id(),
                'nombre_mouvements' => $stats['mouvements'],
                'nombre_lignes'     => $stats['lignes'],
                'statut'            => 'réussi',
                'erreur'            => null,
            ]);

            return response()->json([
                'message' => "Importation réussie : {$stats['mouvements']} mouvements et {$stats['lignes']} lignes importés.",
                'data' => $stats
            ]);

        } catch (Exception $e) {
            DB::rollBack();
            ImportHistory::create([
                'nom_fichier'       => $request->file('file_ecritures')->getClientOriginalName(),
                'imported_by'       => Auth::id(),
                'nombre_mouvements' => 0,
                'nombre_lignes'     => 0,
                'statut'            => 'échec',
                'erreur'            => $e->getMessage(),
            ]);
            return response()->json([
                'error' => 'Erreur lors de l\'importation',
                'message' => config('app.debug') ? $e->getMessage() : 'Erreur serveur'
            ], 500);
        }
    }

    public function validateImport(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file_ecritures' => 'required|file|mimes:csv,txt|max:10240',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'error' => 'Fichier invalide',
                'messages' => $validator->errors()
            ], 422);
        }

        try {
            $path = $request->file('file_ecritures')->getRealPath();
            $handle = fopen($path, 'r');
            
            $header = fgetcsv($handle, 0, ';');
            
            $preview = [];
            $count = 0;
            while (($row = fgetcsv($handle, 0, ';')) !== false && $count < 5) {
                $preview[] = [
                    'date' => $row[0] ?? '',
                    'sous_compte' => $row[1] ?? '',
                    'libelle' => $row[2] ?? '',
                    'debit' => $row[3] ?? '',
                    'credit' => $row[4] ?? '',
                    'reference' => $row[5] ?? '',
                    'code_journal' => $row[6] ?? '',
                ];
                $count++;
            }
            
            $totalLignes = $count;
            while (fgetcsv($handle, 0, ';') !== false) {
                $totalLignes++;
            }
            
            fclose($handle);
            
            return response()->json([
                'total_lignes' => $totalLignes,
                'preview' => $preview,
                'format_valide' => true,
                'header' => $header
            ]);
            
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Erreur lors de la validation',
                'message' => $e->getMessage(),
                'format_valide' => false
            ], 500);
        }
    }

    public function historique()
    {
        try {
            $historique = ImportHistory::with('user')
                ->orderBy('created_at', 'desc')
                ->paginate(30);

            return response()->json($historique);
        } catch (Exception $e) {
            return response()->json([
                'error' => 'Erreur lors du chargement de l\'historique',
                'message' => $e->getMessage()
            ], 500);
        }
    }

    private function processImport($file)
    {
        $path = $file->getRealPath();
        $handle = fopen($path, 'r');
        $header = fgetcsv($handle, 0, ';');

        $data = [];
        while (($row = fgetcsv($handle, 0, ';')) !== false) {
            $data[] = $row;
        }
        fclose($handle);

        // ÉTAPE 1: VALIDATION COMPLÈTE AVANT INSERTION
        $errors = $this->validateData($data);
        
        // Si erreurs détectées, on arrête tout de suite
        if (!empty($errors)) {
            return [
                'mouvements' => 0,
                'lignes' => 0,
                'errors' => $errors
            ];
        }

        // ÉTAPE 2: INSERTION (seulement si aucune erreur)
        $groupedData = collect($data)->filter(function($row) {
            return !empty($row[0]) && !empty($row[1]) && !empty($row[6]);
        })->groupBy(function ($row) {
            return $row[0].'|'.($row[5] ?? 'NO_REF').'|'.$row[6];
        });

        $mouvementCount = 0;
        $ligneCount = 0;

        foreach ($groupedData as $key => $lignes) {
            $premiereLigne = $lignes->first();

            $sousCompte = SousCompte::where('Code_sous_compte', $premiereLigne[1])->first();
            $dateFormatted = $this->parseDate($premiereLigne[0]);
            $codeJournal = $premiereLigne[6];
            $journal = Journal::where('Code', $codeJournal)->first();

            $year = date('Y', strtotime($dateFormatted));
            $lastNumero = MouvementEcriture::where('Id_Journal', $journal->Id_Journal)
                ->whereYear('Date_mouvement', $year)
                ->max('Id_Mouvement_ecriture');
            $nextNumero = $lastNumero ? $lastNumero + 1 : 1;
            $numeroPiece = $journal->Code . $year . '-' . str_pad($nextNumero, 4, '0', STR_PAD_LEFT);

            $mouvement = MouvementEcriture::create([
                'Date_mouvement' => $dateFormatted,
                'Numero_piece'   => $numeroPiece,
                'Id_Journal'     => $journal->Id_Journal,
                'created_by'     => Auth::id(),
            ]);

            $mouvementCount++;

            foreach ($lignes as $row) {
                $sousCompteLigne = SousCompte::where('Code_sous_compte', $row[1])->first();
                $debit = floatval($row[3] ?? 0);
                $credit = floatval($row[4] ?? 0);

                LigneEcriture::create([
                    'Libelle'                => $row[2],
                    'Debit'                  => $debit,
                    'Credit'                 => $credit,
                    'Reference'              => $row[5] ?? null,
                    'Quantite'               => null,
                    'Id_Mode_paiement'       => null,
                    'Id_Mouvement_ecriture'  => $mouvement->Id_Mouvement_ecriture,
                    'Id_Journal'             => $journal->Id_Journal,
                    'Id_Sous_compte'         => $sousCompteLigne->Id_Sous_compte,
                    'statut'                 => 'brouillon',
                ]);

                $ligneCount++;
            }
        }

        return [
            'mouvements' => $mouvementCount,
            'lignes' => $ligneCount,
            'errors' => []
        ];
    }

    /**
     * Valide toutes les données AVANT insertion
     */
    private function validateData($data)
    {
        $errors = [];
        $lineNumber = 1; // Pour tracer la ligne d'erreur

        foreach ($data as $row) {
            $lineNumber++;

            // Vérifier colonnes obligatoires
            if (empty($row[0])) {
                $errors[] = "Ligne {$lineNumber}: Date manquante";
            }
            if (empty($row[1])) {
                $errors[] = "Ligne {$lineNumber}: Sous-compte manquant";
            }
            if (empty($row[6])) {
                $errors[] = "Ligne {$lineNumber}: Code journal manquant";
            }

            // Vérifier format date
            if (!empty($row[0]) && !$this->parseDate($row[0])) {
                $errors[] = "Ligne {$lineNumber}: Format de date invalide ({$row[0]})";
            }

            // Vérifier existence sous-compte
            if (!empty($row[1])) {
                $sousCompte = SousCompte::where('Code_sous_compte', $row[1])->first();
                if (!$sousCompte) {
                    $errors[] = "Ligne {$lineNumber}: Sous-compte {$row[1]} introuvable";
                }
            }

            // Vérifier existence journal
            if (!empty($row[6])) {
                $journal = Journal::where('Code', $row[6])->first();
                if (!$journal) {
                    $errors[] = "Ligne {$lineNumber}: Journal {$row[6]} introuvable";
                }
            }
        }

        return $errors;
    }

    private function parseDate($dateString)
    {
        if (is_numeric($dateString)) {
            $unixTimestamp = ($dateString - 25569) * 86400;
            return date('Y-m-d', $unixTimestamp);
        }

        if (preg_match('/^(\d{2})\/(\d{2})\/(\d{4})$/', $dateString, $matches)) {
            return $matches[3] . '-' . $matches[2] . '-' . $matches[1];
        }

        if (preg_match('/^\d{4}-\d{2}-\d{2}$/', $dateString)) {
            return $dateString;
        }

        return false;
    }
}
