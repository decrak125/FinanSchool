<?php

namespace App\Console;

use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Console\Kernel as ConsoleKernel;

class Kernel extends ConsoleKernel
{
    protected $commands = [
        // Mets ici ta commande, exemple :
        \App\Console\Commands\NotifClotureExerciceProche::class,
    ];

    protected function schedule(Schedule $schedule)
    {
        // Mets ici ton planning :
        $schedule->command('exercice:cloture-alertes')->everyMinute();
    }

    protected function commands()
    {
        $this->load(__DIR__.'/Commands');
        require base_path('routes/console.php');
    }
}
