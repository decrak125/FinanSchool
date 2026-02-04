<?php
// app/Http/Controllers/ChatBot/DiagnosticController.php

namespace App\Http\Controllers\ChatBot;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Analyse\DiagnosticControllerUnifie as DiagnosticService;

class DiagnosticController extends Controller
{
    // Changez private en public et static
public static function getDiagnosticComplet($dateDebut, $dateFin)
{
    $service = new DiagnosticService();
    
    $diagnostic = $service->getDashboardCompletLocal($dateDebut, $dateFin);
    
    if (empty($diagnostic) || !isset($diagnostic['success']) || !$diagnostic['success']) {
        return "Je n'ai pas trouvé de données de diagnostic pour la période du {$dateDebut} au {$dateFin}.";
    }
    
    // Formater la réponse selon la structure de votre diagnostic
    $response = "Ok, voici un résumés complet de vos indicateurs financiers\n";
    $response .= "Periode : du {$dateDebut} au {$dateFin}\n\n";
    
    // 1. RENTABILITÉ
    if (isset($diagnostic['aspects']['rentabilite']) && $diagnostic['aspects']['rentabilite']['success']) {
        $rentabilite = $diagnostic['aspects']['rentabilite'];
        $response .= "RENTABILITE\n";
        
        if (isset($rentabilite['marge_brute'])) {
            $mb = $rentabilite['marge_brute'];
            $response .= "- Marge brute : {$mb['valeur']}{$mb['unite']} ({$mb['interpretation']})\n";
        }
        
        if (isset($rentabilite['marge_nette'])) {
            $mn = $rentabilite['marge_nette'];
            $response .= "- Marge nette : {$mn['valeur']}{$mn['unite']} ({$mn['interpretation']})\n";
        }
        
        if (isset($rentabilite['roe'])) {
            $roe = $rentabilite['roe'];
            $response .= "- ROE (Rentabilite capitaux propres) : {$roe['valeur']}{$roe['unite']} ({$roe['interpretation']})\n";
        }
        
        if (isset($rentabilite['roa'])) {
            $roa = $rentabilite['roa'];
            $response .= "- ROA (Rentabilite actifs) : {$roa['valeur']}{$roa['unite']} ({$roa['interpretation']})\n";
        }
        
        $response .= "\n";
    }
    
    // 2. SOLVABILITÉ
    if (isset($diagnostic['aspects']['solvabilite']) && $diagnostic['aspects']['solvabilite']['success']) {
        $solvabilite = $diagnostic['aspects']['solvabilite'];
        $response .= "SOLVABILITE\n";
        
        if (isset($solvabilite['autonomie_financiere'])) {
            $af = $solvabilite['autonomie_financiere'];
            $response .= "- Autonomie financiere : {$af['valeur']}{$af['unite']} ({$af['interpretation']})\n";
        }
        
        if (isset($solvabilite['ratio_endettement'])) {
            $endettement = $solvabilite['ratio_endettement'];
            $response .= "- Ratio d'endettement : {$endettement['valeur']}% ({$endettement['interpretation']})\n";
        }
        
        if (isset($solvabilite['capacite_remboursement']) && $solvabilite['capacite_remboursement']['niveau_alerte']) {
            $cr = $solvabilite['capacite_remboursement'];
            $value = round($cr['valeur']);
            $response .= "- Capacite de remboursement : {$value} {$cr['unite']} ({$cr['interpretation']})\n";
        }
        
        $response .= "\n";
    }
    
    // 3. LIQUIDITÉ
    if (isset($diagnostic['aspects']['liquidite']) && $diagnostic['aspects']['liquidite']['success']) {
        $liquidite = $diagnostic['aspects']['liquidite'];
        $response .= "LIQUIDITE\n";
        
        if (isset($liquidite['tresorerie_nette'])) {
            $tn = $liquidite['tresorerie_nette'];
            $montant = number_format($tn['valeur'], 0, ',', ' ');
            $response .= "- Tresorerie nette : {$montant} {$tn['unite']} ({$tn['interpretation']})\n";
        }
        
        if (isset($liquidite['bfr']) && $liquidite['bfr']['niveau_alerte']) {
            $bfr = $liquidite['bfr'];
            $response .= "- BFR (Besoin en fonds de roulement) : {$bfr['valeur']} ({$bfr['interpretation']})\n";
        }

        if (isset($liquidite['ratio_liquidite_generale']) && $liquidite['ratio_liquidite_generale']['niveau_alerte']) {
            $rlg = $liquidite['ratio_liquidite_generale'];
            $response .= "- Ratio de liquidité générale : {$rlg['valeur']} ({$rlg['interpretation']})\n";
        }
        
        $response .= "\n";
    }
    
    // 4. PÉDAGOGIQUE
    if (isset($diagnostic['aspects']['pedagogique']) && $diagnostic['aspects']['pedagogique']['success']) {
        $pedagogique = $diagnostic['aspects']['pedagogique']['indicateurs_pedagogiques'];
        $response .= "INDICATEURS PEDAGOGIQUES\n";
        
        if (isset($pedagogique['cout_fonctionnement_par_eleve'])) {
            $cpe = $pedagogique['cout_fonctionnement_par_eleve'];
            $montant = number_format($cpe['valeur'], 0, ',', ' ');
            $response .= "- Cout par eleve : {$montant} {$cpe['unite']} ({$cpe['interpretation']})\n";
        }
        
        if (isset($pedagogique['chiffre_affaires_par_eleve'])) {
            $cape = $pedagogique['chiffre_affaires_par_eleve'];
            $montant = number_format($cape['valeur'], 0, ',', ' ');
            $response .= "- Chiffre d'affaires par eleve : {$montant} {$cape['unite']} ({$cape['interpretation']})\n";
        }
        
        if (isset($pedagogique['marge_par_eleve'])) {
            $mpe = $pedagogique['marge_par_eleve'];
            $montant = number_format($mpe['valeur'], 0, ',', ' ');
            $response .= "- Marge par eleve : {$montant} {$mpe['unite']} ({$mpe['interpretation']})\n";
        }

        if (isset($pedagogique['part_masse_salariale_enseignante'])) {
            $mspe = $pedagogique['part_masse_salariale_enseignante'];
            $montant = number_format($mspe['valeur'], 0, ',', ' ');
            $response .= "- Part de la masse salariale enseignante : {$montant} {$mspe['unite']} ({$mspe['interpretation']})\n";
        }
        
        $response .= "\n";
    }
    
    // 5. SYNTHÈSE
    $response .= "SYNTHESE\n";
    
    $alertes = self::extractAlertesFromDiagnostic($diagnostic);
    
    if (empty($alertes['mauvais']) && empty($alertes['moyen'])) {
        $response .= "Tous les indicateurs sont dans les normes. Excellente sante financiere.\n\n";
    } else {
        if (!empty($alertes['mauvais'])) {
            $response .= "Points critiques a surveiller :\n";
            foreach ($alertes['mauvais'] as $alerte) {
                $response .= "- {$alerte}\n";
            }
            $response .= "\n";
        }
        
        if (!empty($alertes['moyen'])) {
            $response .= "Points a ameliorer :\n";
            foreach ($alertes['moyen'] as $alerte) {
                $response .= "- {$alerte}\n";
            }
            $response .= "\n";
        }
        
        if (!empty($alertes['bon'])) {
            $response .= "Points forts :\n";
            foreach ($alertes['bon'] as $alerte) {
                $response .= "- {$alerte}\n";
            }
        }
    }
    
    // // 6. RECOMMANDATIONS
    // $response .= "\nRECOMMANDATIONS PRIORITAIRES\n";
    
    // $recommandations = self::generateRecommandations($diagnostic);
    // foreach ($recommandations as $index => $reco) {
    //     $response .= ($index + 1) . ". {$reco}\n";
    // }
    
    // $response .= "\n\n";
    // $response .= "N'hésites pas si tu as d'autres questions";
    
    return $response;
}

private static function extractAlertesFromDiagnostic($diagnostic)
{
    $alertes = ['mauvais' => [], 'moyen' => [], 'bon' => []];
    
    $aspects = ['rentabilite', 'solvabilite', 'liquidite', 'pedagogique'];
    
    foreach ($aspects as $aspect) {
        if (!isset($diagnostic['aspects'][$aspect])) continue;
        
        $data = $diagnostic['aspects'][$aspect];
        
        foreach ($data as $key => $indicateur) {
            if (is_array($indicateur) && isset($indicateur['niveau_alerte']) && $indicateur['niveau_alerte']) {
                $niveau = $indicateur['niveau_alerte']['id_niveau_alerte'];
                $interpretation = $indicateur['interpretation'] ?? '';
                
                $nomIndicateur = self::getIndicateurName($key);
                
                switch($niveau) {
                    case 1: // Mauvais
                        $alertes['mauvais'][] = "{$nomIndicateur} : {$interpretation}";
                        break;
                    case 2: // Moyen
                        $alertes['moyen'][] = "{$nomIndicateur} : {$interpretation}";
                        break;
                    case 3: // Bon
                        $alertes['bon'][] = "{$nomIndicateur} : {$interpretation}";
                        break;
                }
            }
        }
    }
    
    return $alertes;
}

private static function getIndicateurName($key)
{
    $noms = [
        'marge_brute' => 'Marge brute',
        'marge_nette' => 'Marge nette',
        'roe' => 'Rentabilite capitaux propres (ROE)',
        'roa' => 'Rentabilite actifs (ROA)',
        'autonomie_financiere' => 'Autonomie financiere',
        'ratio_endettement' => "Ratio d'endettement",
        'capacite_remboursement' => 'Capacite de remboursement',
        'tresorerie_nette' => 'Tresorerie nette',
        'bfr' => 'Besoin en fonds de roulement (BFR)',
        'cout_fonctionnement_par_eleve' => 'Cout fonctionnement par eleve',
        'chiffre_affaires_par_eleve' => "Chiffre d'affaires par eleve",
        'marge_par_eleve' => 'Marge par eleve'
    ];
    
    return $noms[$key] ?? str_replace('_', ' ', $key);
}

private static function generateRecommandations($diagnostic)
{
    $recommandations = [];
    
    // 1. Endettement critique
    if (isset($diagnostic['aspects']['solvabilite']['ratio_endettement'])) {
        $endettement = $diagnostic['aspects']['solvabilite']['ratio_endettement'];
        if ($endettement['niveau_alerte']['id_niveau_alerte'] == 1) {
            $recommandations[] = "Reduire le niveau d'endettement (actuellement {$endettement['valeur']}%)";
        }
    }
    
    // 2. Cout par eleve eleve
    if (isset($diagnostic['aspects']['pedagogique']['indicateurs_pedagogiques']['cout_fonctionnement_par_eleve'])) {
        $coutEleve = $diagnostic['aspects']['pedagogique']['indicateurs_pedagogiques']['cout_fonctionnement_par_eleve'];
        if ($coutEleve['niveau_alerte']['id_niveau_alerte'] == 1) {
            $recommandations[] = "Optimiser les couts de fonctionnement par eleve";
        }
    }
    
    // 3. Probleme de BFR
    if (isset($diagnostic['aspects']['liquidite']['bfr'])) {
        $bfr = $diagnostic['aspects']['liquidite']['bfr'];
        if ($bfr['niveau_alerte']['id_niveau_alerte'] == 2) {
            $recommandations[] = "Ameliorer la gestion du besoin en fonds de roulement";
        }
    }
    
    // 4. Recommandations par defaut
    if (empty($recommandations)) {
        $recommandations[] = "Maintenir l'excellente performance financiere actuelle";
        $recommandations[] = "Continuer a surveiller les indicateurs cles mensuellement";
    }
    
    return array_slice($recommandations, 0, 5);
}


// Méthodes utilitaires
private static function getEmojiFromAlerte($niveauAlerte)
{
    return match($niveauAlerte) {
        1 => '🔴', // Mauvais
        2 => '🟡', // Moyen
        3 => '🟢', // Bon
        default => '⚪' // Non défini
    };
}

    
    public static function getDiagnosticParCentre($dateDebut, $dateFin, $centreId = null)
    {
        $service = new DiagnosticService();
        
        $diagnostic = $service->getDiagnosticCompletLocal($dateDebut, $dateFin);
        
        if (empty($diagnostic)) {
            return "Je n'ai pas trouvé de données de diagnostic pour la période du {$dateDebut} au {$dateFin}.";
        }
        
        $response = "📊 Diagnostic par Centre du {$dateDebut} au {$dateFin}\n\n";
        
        // Si un centre spécifique est demandé
        if ($centreId && isset($diagnostic['centres'][$centreId])) {
            $centre = $diagnostic['centres'][$centreId];
            $response .= "Centre : {$centre['nom']}\n";
            $response .= "Dépenses : " . number_format($centre['depenses'] ?? 0, 0, ',', ' ') . " Ar\n";
            $response .= "Profits : " . number_format($centre['profits'] ?? 0, 0, ',', ' ') . " Ar\n";
            $response .= "Balance : " . number_format($centre['balance'] ?? 0, 0, ',', ' ') . " Ar\n";
            $response .= "Marge : " . ($centre['marge'] ?? 0) . "%\n\n";
            
            if (isset($centre['sous_comptes']) && !empty($centre['sous_comptes'])) {
                $response .= "📋 Détail par sous-compte :\n";
                foreach ($centre['sous_comptes'] as $sousCompte) {
                    $response .= "- {$sousCompte['nom']} : " . number_format($sousCompte['montant'] ?? 0, 0, ',', ' ') . " Ar\n";
                }
            }
            
            return $response;
        }
        
        // Sinon afficher tous les centres
        if (isset($diagnostic['centres'])) {
            $total = 0;
            foreach ($diagnostic['centres'] as $centre) {
                $total++;
                $response .= "{$total}. {$centre['nom']}\n";
                $response .= "   Dépenses : " . number_format($centre['depenses'] ?? 0, 0, ',', ' ') . " Ar\n";
                $response .= "   Profits : " . number_format($centre['profits'] ?? 0, 0, ',', ' ') . " Ar\n";
                $response .= "   Balance : " . number_format($centre['balance'] ?? 0, 0, ',', ' ') . " Ar\n";
                $response .= "   Marge : " . ($centre['marge'] ?? 0) . "%\n\n";
            }
        }
        
        return $response;
    }
    
    public static function getDiagnosticResume($dateDebut, $dateFin)
    {
        $service = new DiagnosticService();
        
        $diagnostic = $service->getDiagnosticCompletLocal($dateDebut, $dateFin);
        
        if (empty($diagnostic)) {
            return "Je n'ai pas trouvé de données de diagnostic pour la période du {$dateDebut} au {$dateFin}.";
        }
        
        $response = "📈 Résumé du Diagnostic du {$dateDebut} au {$dateFin}\n\n";
        
        if (isset($diagnostic['resume'])) {
            $resume = $diagnostic['resume'];
            
            $response .= "💰 Chiffre d'Affaires : " . number_format($resume['chiffre_affaires'] ?? 0, 0, ',', ' ') . " Ar\n";
            $response .= "📉 Total Dépenses : " . number_format($resume['total_depenses'] ?? 0, 0, ',', ' ') . " Ar\n";
            $response .= "📊 Total Profits : " . number_format($resume['total_profits'] ?? 0, 0, ',', ' ') . " Ar\n";
            $response .= "⚖️  Balance Nette : " . number_format($resume['balance'] ?? 0, 0, ',', ' ') . " Ar\n";
            $response .= "📈 Marge Brute : " . ($resume['marge_brute'] ?? 0) . "%\n";
            $response .= "📊 Marge Nette : " . ($resume['marge'] ?? 0) . "%\n\n";
            
            // Ajouter des indicateurs de performance
            if (isset($resume['evolution'])) {
                $response .= "📅 Évolution vs Période Précédente :\n";
                $response .= "CA : " . ($resume['evolution']['ca'] >= 0 ? '+' : '') . $resume['evolution']['ca'] . "%\n";
                $response .= "Dépenses : " . ($resume['evolution']['depenses'] >= 0 ? '+' : '') . $resume['evolution']['depenses'] . "%\n";
                $response .= "Profits : " . ($resume['evolution']['profits'] >= 0 ? '+' : '') . $resume['evolution']['profits'] . "%\n";
            }
        }
        
        return $response;
    }
    
    public static function getAlertesDiagnostic($dateDebut, $dateFin)
    {
        $service = new DiagnosticService();
        
        $diagnostic = $service->getDiagnosticCompletLocal($dateDebut, $dateFin);
        
        if (empty($diagnostic)) {
            return "Je n'ai pas trouvé de données de diagnostic pour la période du {$dateDebut} au {$dateFin}.";
        }
        
        if (!isset($diagnostic['alertes']) || empty($diagnostic['alertes'])) {
            return "✅ Aucune alerte détectée pour la période du {$dateDebut} au {$dateFin}.";
        }
        
        $response = "⚠️ Alertes du Diagnostic du {$dateDebut} au {$dateFin}\n\n";
        
        $count = 1;
        foreach ($diagnostic['alertes'] as $alerte) {
            $severity = match($alerte['niveau'] ?? 'info') {
                'critique' => '🔴 CRITIQUE',
                'haute' => '🟠 HAUTE',
                'moyenne' => '🟡 MOYENNE',
                'basse' => '🔵 BASSE',
                default => 'ℹ️ INFO'
            };
            
            $response .= "{$count}. {$severity}\n";
            $response .= "   {$alerte['message']}\n";
            
            if (isset($alerte['centre'])) {
                $response .= "   Centre : {$alerte['centre']}\n";
            }
            
            if (isset($alerte['montant'])) {
                $response .= "   Montant : " . number_format($alerte['montant'], 0, ',', ' ') . " Ar\n";
            }
            
            $response .= "\n";
            $count++;
        }
        
        return $response;
    }
}