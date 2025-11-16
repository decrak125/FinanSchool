<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\exercice\ExerciceComptable;
use App\Models\notifications\Evenement;
use App\Models\notifications\Notification;
use App\Events\NotificationCreee;
use Carbon\Carbon;

class NotifOuvertureClotureExercice extends Command
{
    protected $signature = 'exercice:ouverture-cloture-alertes';
    protected $description = "Alerte automatique à l’ouverture et à la clôture de l'exercice comptable";

    public function handle()
    {
        $exercices = ExerciceComptable::where('Statut', 'OUVERT')->get();
        $today = Carbon::now()->toDateString();

        foreach ($exercices as $exercice) {
            $dateOuverture = Carbon::parse($exercice->Date_debut)->toDateString();
            $dateCloture   = Carbon::parse($exercice->Date_fin)->toDateString();

            // Alerte ouverture
            if ($today === $dateOuverture) {
                $evenement = Evenement::create([
                    'type_evenement_id' => 7, // Id à choisir
                    'donnees_evenement' => [
                        'date_ouverture' => $dateOuverture,
                        'exercice_id' => $exercice->Id_Exercice_comptable,
                        'annee_fiscale' => $exercice->Annee_fiscale
                    ]
                ]);
                $notification = Notification::create([
                    'evenement_id' => $evenement->id,
                    'niveau_urgence_id' => 2,
                    'titre' => "Ouverture d'un exercice",
                    'message' => "L'exercice {$exercice->Annee_fiscale} débute aujourd'hui ({$dateOuverture}).",
                    'statut' => 'non_lu'
                ]);
                event(new NotificationCreee($notification));
                $this->info("✅ Notif ouverture envoyée : Exercice {$exercice->Annee_fiscale}");
            }

            // Alerte clôture
            if ($today === $dateCloture) {
                $evenement = Evenement::create([
                    'type_evenement_id' => 6, // Id à choisir
                    'donnees_evenement' => [
                        'date_cloture' => $dateCloture,
                        'exercice_id' => $exercice->Id_Exercice_comptable,
                        'annee_fiscale' => $exercice->Annee_fiscale
                    ]
                ]);
                $notification = Notification::create([
                    'evenement_id' => $evenement->id,
                    'niveau_urgence_id' => 3,
                    'titre' => "Clôture de l'exercice",
                    'message' => "L'exercice {$exercice->Annee_fiscale} est clôturé aujourd'hui ({$dateCloture}).",
                    'statut' => 'non_lu'
                ]);
                event(new NotificationCreee($notification));
                $this->info("✅ Notif clôture envoyée : Exercice {$exercice->Annee_fiscale}");
            }
        }

        return 0;
    }
}
