<?php

namespace App\Http\Controllers\ParametresAnalytique;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ParametresAnalytique\CentreAnalytique;
use App\Models\ParametresAnalytique\AxeAnalytique;
use App\Models\ParametresAnalytique\TypeCentre;

class CentreAnalytiqueController extends Controller
{
    public function index()
    {
        return CentreAnalytique::with('type')->get();
    }

    public function show($id)
    {
        return CentreAnalytique::findOrFail($id);
    }

    public function store(Request $request)
    {
        $request->validate([
            'nom' => 'required|string|max:150',
            'description' => 'required|string|max:100',
            'id_axe' => 'required|integer',
            'id_type' => 'required|integer',
        ]);

        return CentreAnalytique::create($request->all());
    }

    public function update(Request $request, $id)
    {
        $centre = CentreAnalytique::findOrFail($id);
        $centre->update($request->all());

        return $centre;
    }

    public function destroy($id)
    {
        $centre = CentreAnalytique::findOrFail($id);
        $centre->delete();

        return response()->json(['message' => 'CentreAnalytique supprimé']);
    }

    // Import CSV
    public function import(Request $request)
{
    $request->validate([
        'file' => 'required|mimes:csv,txt'
    ]);

    $imported = 0;
    $skipped = 0;

    try {
        $file = $request->file('file');
        $path = $file->getRealPath();

        if (($handle = fopen($path, "r")) !== false) {
            $header = fgetcsv($handle, 1000, ";");

            while (($row = fgetcsv($handle, 1000, ";")) !== false) {
                $data = [];
                foreach ($header as $i => $key) {
                    $data[$key] = $row[$i] ?? null;
                }

                // Axe insensible à la casse
                $axe = AxeAnalytique::whereRaw('LOWER(axe) = ?', [strtolower($data['axe'] ?? $row[2])])->first();
                $id_axe = $axe ? $axe->id_axe : null;

                // Type insensible à la casse
                $type = TypeCentre::whereRaw('LOWER(code) = ?', [strtolower($data['code_type'] ?? $row[3])])->first();
                $id_type = $type ? $type->id_type : null;

                if (!$id_axe || !$id_type) {
                    $skipped++;
                    continue; // ignore si axe ou type introuvable
                }

                // Vérifier si le centre existe déjà
                $exists = CentreAnalytique::where('nom', $data['nom'] ?? $row[0])
                    ->where('description', $data['description'] ?? $row[1])
                    ->where('id_axe', $id_axe)
                    ->where('id_type', $id_type)
                    ->first();

                if ($exists) {
                    $skipped++; // doublon, on ignore
                    continue;
                }

                // Créer le centre
                CentreAnalytique::create([
                    'nom' => $data['nom'] ?? $row[0],
                    'description' => $data['description'] ?? $row[1],
                    'id_axe' => $id_axe,
                    'id_type' => $id_type,
                ]);

                $imported++;
            }

            fclose($handle);
        }

        return response()->json([
            'success' => true,
            'imported' => $imported,
            'skipped' => $skipped,
            'message' => "Import terminé : $imported importés, $skipped ignorés."
        ]);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
}

}
