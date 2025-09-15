<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Error;

class ErrorSeeder extends Seeder
{
    public function run(): void
    {
        $errors = [
            ['id' => 1, 'message' => 'Identifiants incorrects'],
            ['id' => 2, 'message' => 'Code de vérification invalide'],
            ['id' => 3, 'message' => 'Impossible d\'envoyer le code'],
            ['id' => 4, 'message' => 'Email requis'],
            ['id' => 5, 'message' => 'Mot de passe requis'],
            ['id' => 6, 'message' => 'Email déjà utilisé'],
            ['id' => 7, 'message' => 'Email introuvable'],
            ['id' => 8, 'message' => 'Erreur lors de l\'envoi de l\'email'],
            ['id' => 9, 'message' => 'Utilisateur non authentifié'],
            ['id' => 10, 'message' => 'Code expiré. Veuillez demander un nouveau code.'],
            ['id' => 11, 'message' => 'Données invalides fournies.'],
            ['id' => 12, 'message' => 'Méthode non autorisée.'],
            ['id' => 13, 'message' => 'Conflit de données. Veuillez vérifier vos informations.'],
            // tu peux ajouter d'autres messages ici
        ];

        foreach ($errors as $err) {
            Error::updateOrCreate(['id' => $err['id']], $err);
        }
    }
}
