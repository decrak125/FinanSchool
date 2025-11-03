<?php

namespace App\Http\Controllers\notifications;

use App\Models\notifications\Notification;
use App\Events\NotificationCreee;
use App\Http\Requests\StoreNotificationRequest;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;

class NotificationController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $notifications = Notification::with(['evenement.typeEvenement', 'niveauUrgence'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($notifications);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreNotificationRequest $request)
    {
        $notification = Notification::create($request->validated());

        // Diffuser l'événement WebSocket
        event(new NotificationCreee($notification));

        return response()->json($notification, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Notification $notification)
    {
        $notification->load(['evenement.typeEvenement', 'niveauUrgence']);

        return response()->json($notification);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Notification $notification)
    {
        $notification->update($request->validated());

        return response()->json($notification);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Notification $notification)
    {
        $notification->delete();

        return response()->json(null, 204);
    }

    /**
     * Marquer une notification comme lue
     */
    public function marquerCommeLue(Notification $notification)
    {
        $notification->update([
            'statut' => 'lu',
            'lu_a' => now()
        ]);

        return response()->json($notification);
    }

    /**
     * Récupérer les notifications non lues
     */
    public function nonLues()
    {
        $notifications = Notification::with(['evenement.typeEvenement', 'niveauUrgence'])
            ->where('statut', 'non_lue')
            ->get();

        return response()->json($notifications);
    }

    /**
     * Marquer toutes les notifications comme lues
     */
    public function marquerToutesLues()
    {
        Notification::nonLues()->update([
            'statut' => 'lu',
            'lu_a' => now()
        ]);

        return response()->json(['message' => 'Toutes les notifications ont été marquées comme lues']);
    }
}