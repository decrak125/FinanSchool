<?php

namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saisie\Devise;

class DeviseController extends Controller
{
    public function index()
    {
        return Devise::all();
    }

    public function show($id)
    {
        return Devise::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Libelle' => 'required|string|max:100',
            'Code' => 'required|string|max:10|unique:devises,Code',
            'Sigle' => 'required|string|max:10|unique:devises,Sigle',
        ]);

        return Devise::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $devise = Devise::findOrFail($id);

        $request->validate([
            'Libelle' => 'required|string|max:100',
            'Code' => 'required|string|max:10|unique:devises,Code,' . $devise->Id_Devise . ',Id_Devise',
            'Sigle' => 'required|string|max:10|unique:devises,Sigle,' . $devise->Id_Devise . ',Id_Devise',
        ]);

        $devise->update($request->all());

        return $devise;
    }

    public function destroy($id)
    {
        $devise = Devise::findOrFail($id);
        $devise->delete();

        return response()->json(['message' => 'Devise supprimée']);
    }
}
