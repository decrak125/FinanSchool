<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    protected $commands = [
        // Ajoute ta commande artisan ici
        \App\Console\Commands\NotifClotureExerciceProche::class,
    ];

    protected function schedule(Schedule $schedule)
    {
        // C'est ICI et seulement ici qu'on met le scheduling !
        $schedule->command('exercice:cloture-alertes')->everyMinute();
    }

    protected function commands()
    {
        $this->load(__DIR__.'/Commands');
        require base_path('routes/console.php');
    }
}
