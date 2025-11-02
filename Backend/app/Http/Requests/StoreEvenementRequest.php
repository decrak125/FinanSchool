<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreEvenementRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'type_evenement_id' => 'required|exists:types_evenement,id',
            'donnees_evenement' => 'required|array',
        ];
    }
}