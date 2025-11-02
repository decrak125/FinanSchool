<?php

namespace App\Events;

use App\Models\notifications\Notification;
use Illuminate\Broadcasting\Channel;
use Illuminate\Contracts\Broadcasting\ShouldBroadcast;

class NotificationCreee implements ShouldBroadcast
{
    public $notification;

    public function __construct(Notification $notification)
    {
        $this->notification = $notification;
    }

    public function broadcastOn()
    {
        return new Channel('notifications');
    }
}