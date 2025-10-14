<?php
// app/Providers/EventServiceProvider.php

namespace App\Providers;

use Illuminate\Auth\Events\Registered;
use Illuminate\Auth\Listeners\SendEmailVerificationNotification;
use Illuminate\Foundation\Support\Providers\EventServiceProvider as ServiceProvider;
use Illuminate\Support\Facades\Event;

// Importez vos événements et listeners
use App\Events\MouvementCreated;
use App\Listeners\RafraichirVuesTemporelles;

class EventServiceProvider extends ServiceProvider
{
    protected $listen = [
        Registered::class => [
            SendEmailVerificationNotification::class,
        ],
        
        // Ajoutez votre événement ici
        MouvementCreated::class => [
            RafraichirVuesTemporelles::class,
        ],
    ];

    public function boot()
    {
        parent::boot();
    }
}