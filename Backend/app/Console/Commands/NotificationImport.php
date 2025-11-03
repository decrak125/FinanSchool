<?php

namespace App\Console\Commands;

use App\Models\notifications\Evenement;
use App\Models\notifications\Notification;
use App\Events\NotificationCreee;

class NotificationImport
{
    public static function notifyImportSuccess($userId, $fileName, $mouvements, $lignes)
    {
        $evenement = Evenement::create([
            'type_evenement_id' => 2,  // ← adapte selon ton referentiel
            'donnees_evenement' => [
                'nom_fichier' => $fileName,
                'nombre_mouvements' => $mouvements,
                'nombre_lignes' => $lignes,
            ]
        ]);
        
        $notification = Notification::create([
            'evenement_id' => $evenement->id,
            'niveau_urgence_id' => 1, // Info/succès
            'titre' => "Importation réussie",
            'message' => "Le fichier '{$fileName}' a été importé avec succès : {$mouvements} mouvements, {$lignes} lignes.",
            'statut' => 'non_lu',
            'user_id' => $userId,
        ]);
        
        event(new NotificationCreee($notification));
    }

    public static function notifyImportError($userId, $fileName, $error)
    {
        $evenement = Evenement::create([
            'type_evenement_id' => 1, // ← adapte selon ton referentiel
            'donnees_evenement' => [
                'nom_fichier' => $fileName,
                'erreur' => $error,
            ]
        ]);
        
        $notification = Notification::create([
            'evenement_id' => $evenement->id,
            'niveau_urgence_id' => 3, // Erreur/haut niveau
            'titre' => "Échec importation",
            'message' => "Erreur lors de l'import du fichier '{$fileName}' : {$error}",
            'statut' => 'non_lu',
            'user_id' => $userId,
        ]);
        
        event(new NotificationCreee($notification));
    }
}
