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
public static function getClassementCentre($year, $type, $limit)
{
    $year = $year ?? date('Y');
    $service = new CoutEtProfitController();
    $total = 0;
    
    $classement = $service->getClassementCentresLocal($year, $type);
    
    if ($classement->isEmpty() && $type == 1) {
        return "Je n'ai pas trouvé de données de dépenses pour l'année {$year}.";
    }
    if ($classement->isEmpty() && $type == 2) {
        return "Je n'ai pas trouvé de données de profits pour l'année {$year}.";
    }
    
    if ($limit != 0) {
        $response = "Ok, voici le classement des dépenses par centre de {$year}\n\n";
        foreach ($classement->take($limit) as $index => $centre) {
        $total = $total + $centre->montant_ventile;
        $rang = $index + 1;
        $response .= "{$rang}. {$centre->centre}\n";
        $response .= "   Montant : " . number_format($centre->montant_ventile, 0, ',', ' ') . " Ar\n";
        $response .= "   Part : {$centre->part_marche}%\n\n";
    }
    }
    if($limit == 0) {
        $response = "Ok, voici la liste des dépenses par centre de {$year}\n\n";
        foreach ($classement as $index => $centre) {
        $total += $centre->montant_ventile;
        $rang = $index + 1;
        $response .= "{$rang}. {$centre->centre}\n";
        $response .= "   Montant : " . number_format($centre->montant_ventile, 0, ',', ' ') . " Ar\n";
        $response .= "   Part : {$centre->part_marche}%\n\n";
    }
    }
    
    // Ajouter le total
    $response .= "---\n";
    $response .= "Total : " . number_format($total, 0, ',', ' ') . " Ar";
    
    return $response;
}

public static function getBiggestAffectation($mode, $year, $idType, $dateStart = null , $dateEnd = null, $idCentre = null,$idSousCompte = null,$montantMin = null,$montantMax = null){
    if ($year && !$dateStart && !$dateEnd) {
        $dateStart = $year."-01-01";
        $dateEnd = $year."-12-31";
        $phrase = "La plus grosse dépense de l'année {$year} est :" . "\n\n";
    }
    $total = 0;
    $service = new CoutEtProfitController();
    
    $classement = $service->classementSousCompteLocal($idType,$dateStart,$dateEnd,$idCentre,$idSousCompte,$montantMin,$montantMax);
    
    // Correction : utiliser == au lieu de =
    if ($classement->isEmpty() && $idType == 1) {
        return "Je n'ai aucune donnée de dépenses selon vos critères malheureusement ...";
    }
    if ($classement->isEmpty() && $idType == 2) {
        return "Je n'ai aucune donnée de profits selon vos critères malheureusement ...";
    }
    if ($mode == 1) {
        $biggest = $classement->first();
        return $phrase .
           "- " . $biggest->libelle_sous_compte . "(".$biggest->centre_nom.")\n" .
           "- Montant : " . number_format($biggest->montant_ventile, 0, ',', ' ') . " Ar";
    }
    if($mode == 2) {
        $response = "Ok, voici un classement des 5 plus grandes dépenses:\n\n";
        foreach ($classement->take(5) as $index => $centre) {
        $total = $total + $centre->montant_ventile;
        $rang = $index + 1;
        $response .= $rang.". ". $centre->libelle_sous_compte."(".$centre->centre_nom .")\n";
        $response .= "- Montant : " . number_format($centre->montant_ventile, 0, ',', ' ') . " Ar\n\n";
    }   
        $response .= "---\n";
        $response .= "Total : " . number_format($total, 0, ',', ' ') . " Ar";
        return $response;
    }
    if($mode == 3) {
        $response = "Ok, voici la liste de vos dépenses:\n\n";
        foreach ($classement as $index => $centre) {
        $total = $total + $centre->montant_ventile;
        $rang = $index + 1;
        $response .= $rang.". ". $centre->libelle_sous_compte."(".$centre->centre_nom .")\n";
        $response .= "- Montant : " . number_format($centre->montant_ventile, 0, ',', ' ') . " Ar\n\n";
    }   
        $response .= "---\n";
        $response .= "Total : " . number_format($total, 0, ',', ' ') . " Ar";
        return $response;
    }
}

}