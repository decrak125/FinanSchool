<?php

namespace App\Notifications;

use Illuminate\Auth\Notifications\ResetPassword as ResetPasswordBase;
use Illuminate\Notifications\Messages\MailMessage;

class ResetPasswordNotification extends ResetPasswordBase
{
    /**
     * Get the mail representation of the notification.
     */
    public function toMail($notifiable)
    {
        // Récupère l'URL de ton front depuis le fichier .env
        $frontUrl = env('FRONT_URL', 'http://localhost:5173') 
                    . '/reset-password?token=' . $this->token 
                    . '&email=' . urlencode($notifiable->email);

        return (new MailMessage)
            ->subject('Réinitialisation de votre mot de passe')
            ->line('Vous recevez cet email parce que vous avez demandé à réinitialiser votre mot de passe.')
            ->action('Réinitialiser le mot de passe', $frontUrl)
            ->line('Si vous n’avez pas fait cette demande, ignorez cet email.');
    }
}
