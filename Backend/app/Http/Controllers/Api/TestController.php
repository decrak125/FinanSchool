<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;

class TestController extends Controller
{
    public function index()
    {
        return response()->json([
            ['id' => 1, 'name' => 'Produit A'],
            ['id' => 2, 'name' => 'Produit B'],
            ['id' => 3, 'name' => 'Produit C'],
        ]);
    }
}
