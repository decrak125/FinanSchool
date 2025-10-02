<?php

namespace App\Http\Controllers\ParametresAnalytique;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\AxeAnalytique;


class AxeAnalytiqueController extends Controller
{
    public function index()
    {
        return AxeAnalytique::all();
    }

    public function show($id)
    {
        return AxeAnalytique::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'axe' => 'required|string|max:100',
            'description' => 'required|string|max:255',
        ]);

        return AxeAnalytique::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $axe = AxeAnalytique::findOrFail($id);
        $axe->update($request->all());

        return $axe;
    }

    public function destroy($id)
    {
        $axe = AxeAnalytique::findOrFail($id);
        $axe->delete();

        return response()->json(['message' => 'AxeAnalytique supprimé']);
    }

    public function import(Request $request)
    {
        // Validation simple
        $request->validate([
            'file' => 'required|mimes:csv,txt'
        ]);

        $file = $request->file('file');
        $path = $file->getRealPath();

        if (($handle = fopen($path, "r")) !== false) {
            $header = fgetcsv($handle, 1000, ","); // lire la première ligne (header)

            while (($row = fgetcsv($handle, 1000, ",")) !== false) {
                $data = [];
                foreach ($header as $i => $key) {
                    $data[$key] = $row[$i] ?? null;
                }

                AxeAnalytique::create([
                    'axe' => $data['axe'] ?? $row[0],
                    'description' => $data['description'] ?? $row[1],
                ]);
            }
            fclose($handle);
        }

        return response()->json([
            'success' => true,
            'message' => 'Import CSV réussi !'
        ]);
    }


}
