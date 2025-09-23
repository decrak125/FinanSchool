<?php

namespace App\Http\Controllers\Saisie;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Saisie\TypeJournal;

class TypeJournalController extends Controller
{
    public function index()
    {
        return TypeJournal::all();
    }

    public function show($id)
    {
        return TypeJournal::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'Type' => 'required|string|max:50|unique:type_journals,Type',
        ]);

        return TypeJournal::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $typeJournal = TypeJournal::findOrFail($id);
        $typeJournal->update($request->all());

        return $typeJournal;
    }

    public function destroy($id)
    {
        $typeJournal = TypeJournal::findOrFail($id);
        $typeJournal->delete();

        return response()->json(['message' => 'Type Journal supprimé']);
    }
}
