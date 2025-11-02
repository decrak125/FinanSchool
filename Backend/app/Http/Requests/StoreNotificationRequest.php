<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreNotificationRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'evenement_id' => 'required|exists:evenements,id',
            'niveau_urgence_id' => 'required|exists:niveaux_urgence,id',
            'titre' => 'required|string|max:255',
            'message' => 'required|string',
        ];
    }
}