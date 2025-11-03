<?php
namespace App\Http\Controllers\notifications;

use App\Http\Controllers\Controller;
use App\Models\notifications\Notification;
use Illuminate\Support\Facades\Auth;
use Illuminate\Http\Request;

class NotificationsController extends Controller
{
    // Liste des notifications de l'utilisateur connecté
    public function index()
    {
        $userId = Auth::id();
        $notifications = Notification::with(['niveauUrgence'])
            
            ->orderBy('created_at', 'desc')
            ->take(50)
            ->get()
            ->map(function ($n) {
                return [
                    'id' => $n->id,
                    'title' => $n->titre,
                    'message' => $n->message,
                    'statut' => $n->statut,
                    'created_at' => $n->created_at->toDateTimeString(),
                    'niveau_urgence' => [
                        'code' => $n->niveauUrgence->code ?? 'info',
                        'icone' => $n->niveauUrgence->icone ?? 'bi-info-circle-fill',
                        'couleur' => $n->niveauUrgence->couleur ?? '#dbeafe',
                    ]
                ];
            });
        return response()->json($notifications);
    }

    // Marquer une notification comme lue
   public function markAsRead($id)
{
    $notification = Notification::findOrFail($id);
    $notification->statut = 'lu';
    $notification->lu_a = now();
    $notification->save();
    return response()->json(['success' => true]);
}

}
