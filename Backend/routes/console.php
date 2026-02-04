<?php

require __DIR__ . '/notificationsAnalyse.php';
require __DIR__ . '/notifications.php';

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Schedule::command('exercice:cloture-alertes')->everyMinute();
