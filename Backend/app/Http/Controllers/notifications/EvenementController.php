<?php

namespace App\Http\Controllers\notifications;

use App\Models\notifications\Evenement;
use App\Http\Requests\StoreEvenementRequest;
use App\Http\Requests\UpdateEvenementRequest;
use App\Http\Controllers\Controller;

class EvenementController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $evenements = Evenement::with(['typeEvenement', 'notification'])->get();

        return response()->json($evenements);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreEvenementRequest $request)
    {
        $evenement = Evenement::create($request->validated());

        return response()->json($evenement, 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Evenement $evenement)
    {
        $evenement->load(['typeEvenement', 'notification.niveauUrgence']);

        return response()->json($evenement);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Evenement $evenement)
    {
        $evenement->delete();

        return response()->json(null, 204);
    }
}