<?php
// app/Events/MouvementCreated.php

namespace App\Events;

use Illuminate\Broadcasting\Channel;
use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Broadcasting\PresenceChannel;
use Illuminate\Broadcasting\PrivateChannel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;

class MouvementCreated
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    public $mouvementData;

    /**
     * Vous pouvez passer des données si nécessaire
     */
    public function __construct($mouvementData = null)
    {
        $this->mouvementData = $mouvementData;
    }

    /**
     * Get the channels the event should broadcast on.
     */
    public function broadcastOn(): array
    {
        return [
            new PrivateChannel('channel-name'),
        ];
    }
}