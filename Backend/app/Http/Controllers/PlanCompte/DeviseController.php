<?php

namespace App\Http\Controllers\PlanCompte;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\JsonResponse;
use App\Http\Controllers\Controller;

class DeviseController extends Controller
{
    /**
     * Display a listing of the devises.
     */
    public function index(): JsonResponse
    {
        $devises = DB::table('devises')->get();
        return response()->json($devises);
    }

    /**
     * Store a newly created devise in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'Libelle' => 'required|string|max:100',
            'Code' => 'required|string|max:10|unique:devises',
            'Sigle' => 'required|string|max:10|unique:devises',
        ]);

        $id = DB::table('devises')->insertGetId($validated);
        $devise = DB::table('devises')->find($id);

        return response()->json($devise, 201);
    }

    /**
     * Display the specified devise.
     */
    public function show($id): JsonResponse
    {
        $devise = DB::table('devises')->find($id);

        if (!$devise) {
            return response()->json(['message' => 'Devise not found'], 404);
        }

        return response()->json($devise);
    }

    /**
     * Update the specified devise in storage.
     */
    public function update(Request $request, $id): JsonResponse
    {
        $devise = DB::table('devises')->find($id);

        if (!$devise) {
            return response()->json(['message' => 'Devise not found'], 404);
        }

        $validated = $request->validate([
            'Libelle' => 'string|max:100',
            'Code' => 'string|max:10|unique:devises,Code,' . $id . ',Id_Devise',
            'Sigle' => 'string|max:10|unique:devises,Sigle,' . $id . ',Id_Devise',
        ]);

        DB::table('devises')->where('Id_Devise', $id)->update($validated);

        return response()->json(DB::table('devises')->find($id));
    }

    /**
     * Remove the specified devise from storage.
     */
    public function destroy($id): JsonResponse
    {
        $devise = DB::table('devises')->find($id);

        if (!$devise) {
            return response()->json(['message' => 'Devise not found'], 404);
        }

        DB::table('devises')->where('Id_Devise', $id)->delete();

        return response()->json(['message' => 'Devise deleted']);
    }
}