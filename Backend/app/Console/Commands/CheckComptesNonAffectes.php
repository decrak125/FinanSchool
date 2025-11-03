<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\PlanCompte\SousCompte; // ← IMPORTANT : importer ton modèle
use App\Models\notifications\Evenement;
use App\Models\notifications\Notification;
use App\Events\NotificationCreee;

class CheckComptesNonAffectes extends Command
{
    protected $signature = 'comptes:check-non-affectes';
    protected $description = 'Vérifier les comptes non affectés et notifier';

    public function handle()
    {
        $count = SousCompte::whereNotIn('Id_Sous_compte', function($query) {
            $query->select('Id_Sous_compte')
                  ->from('affectationanalytique');
        })
        ->whereHas('compte', function($query) {
            $query->whereBetween('Code_compte', [600, 799]);
        })
        ->count();

        if ($count > 0) {
            $evenement = Evenement::create([
                'type_evenement_id' => 4,
                'donnees_evenement' => [
                    'nombre_comptes' => $count,
                    'lien_redirection' => 'http://localhost:5173/non-affected',
                ]
            ]);

            $notification = Notification::create([
                'evenement_id' => $evenement->id,
                'niveau_urgence_id' => 2,
                'titre' => 'Comptes non affectés détectés',
                'message' => "{$count} compte(s) non affecté(s) nécessitent votre attention",
                'statut' => 'non_lu'
            ]);

            event(new NotificationCreee($notification));
            
            $this->info("Notification créée pour {$count} comptes non affectés");
        } else {
            $this->info("Aucun compte non affecté trouvé");
        }

        return 0;
    }
}