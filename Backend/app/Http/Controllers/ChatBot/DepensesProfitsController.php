<?php
// app/Http/Controllers/ChatController.php

namespace App\Http\Controllers\ChatBot;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Analyse\CoutEtProfitController;

class DepensesProfitsController extends Controller
{
// Changez private en public et static
public static function getBiggestCentre($year, $type)
{
    $year = $year ?? date('Y');
    $service = new CoutEtProfitController();
    
    $classement = $service->getClassementCentresLocal($year, $type);
    
    // Correction : utiliser == au lieu de =
    if ($classement->isEmpty() && $type == 1) {
        return "Je n'ai pas trouvé de données de dépenses pour l'année {$year}.";
    }
    if ($classement->isEmpty() && $type == 2) {
        return "Je n'ai pas trouvé de données de profits pour l'année {$year}.";
    }
    
    $biggest = $classement->first();
    return "Le centre avec la plus grosse dépense de l'année " .$year . " est :" . "\n\n" .
           "Centre de coût :" . $biggest->centre . "\n" .
           "Montant : " . number_format($biggest->montant_ventile, 0, ',', ' ') . " Ar\n" .
           "Part du centre : " . $biggest->part_marche . "%";
           
}
public static function getClassementCentre($year, $type, $limit = 10)
{
    $year = $year ?? date('Y');
    $service = new CoutEtProfitController();
    
    $classement = $service->getClassementCentresLocal($year, $type);
    
    if ($classement->isEmpty() && $type == 1) {
        return "Je n'ai pas trouvé de données de dépenses pour l'année {$year}.";
    }
    if ($classement->isEmpty() && $type == 2) {
        return "Je n'ai pas trouvé de données de profits pour l'année {$year}.";
    }
    
    $response = "Ok, voici le classement des dépenses de {$year}\n\n";
    
    foreach ($classement->take($limit) as $index => $centre) {
        $rang = $index + 1;
        $response .= "{$rang}. {$centre->centre}\n";
        $response .= "   Montant : " . number_format($centre->montant_ventile, 0, ',', ' ') . " Ar\n";
        $response .= "   Part : {$centre->part_marche}%\n\n";
    }
    
    // Ajouter le total
    $total = $classement->sum('montant_ventile');
    $response .= "---\n";
    $response .= "Total : " . number_format($total, 0, ',', ' ') . " Ar";
    
    return $response;
}


}