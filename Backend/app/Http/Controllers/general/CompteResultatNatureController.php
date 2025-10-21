<?php
namespace App\Http\Controllers\general;

use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;

class CompteResultatNatureController extends Controller
{
    /**
     * Renvoie le compte de résultat par nature complet (structure PCG Madagascar)
     * avec toutes les formules et agrégats calculés, y compris subventions.
     * Appel : GET /api/compte-resultat/nature?date_debut=YYYY-MM-DD&date_fin=YYYY-MM-DD
     */
    public function index(Request $request)
    {
        // Validation des paramètres de date
        $request->validate([
            'date_debut' => 'required|date',
            'date_fin'   => 'required|date|after_or_equal:date_debut',
        ]);
        $dateDebut = $request->date_debut;
        $dateFin   = $request->date_fin;

        // Helper pour chaque poste simple
        $get = function ($code) use ($dateDebut, $dateFin) {
            $resultat = \App\Http\Controllers\calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return $resultat && $resultat->montant_total ? floatval($resultat->montant_total) : 0;
        };

        // Les montants de chaque poste
        $ca             = $get('CA');
        $prodStock      = $get('PRODSTOCK');
        $prodImmo       = $get('PRODIMMO');
        $subventionExp  = $get('SUBVENT'); // Subventions d'exploitation (comptes 740–749)
        $subvInvQtPart  = $get('AUTPRODOP'); // 754 (dans autres produits d'exploitation, comptes 750–759)
        $achatConsom    = $get('ACHATCONSOM');
        $servExt        = $get('SERVEXT');
        $chPers         = $get('CHPERS');
        $impTax         = $get('IMPTAX');
        $autChOp        = $get('AUTCHOP');
        $amortProv      = $get('AMORTPROV');
        $repriseProv    = $get('REPRISEPROV');
        $prodFin        = $get('PRODFIN');
        $chargeFin      = $get('CHARGEFIN');
        $impot          = $get('IMPOT');
        $impotDiff      = $get('IMPOTDIFF');
        $prodExcept     = $get('PRODEXCEPT');
        $chargExcept    = $get('CHAREXCEPT');

        // Formules agrégées avec subventions
        $prodExercice        = $ca + $prodStock + $prodImmo + $subventionExp;
        $consoExercice       = $achatConsom + $servExt;
        $valAjoutee          = $prodExercice - $consoExercice;
        $excBrutExploitation = $valAjoutee - $chPers - $impTax;
        $resOp               = $excBrutExploitation + $subvInvQtPart - $autChOp - $amortProv + $repriseProv;
        $resFinancier        = $prodFin - $chargeFin;
        $resAvantImpots      = $resOp + $resFinancier;
        $totalProduits       = $ca + $prodStock + $prodImmo + $subventionExp + $subvInvQtPart + $repriseProv + $prodFin + $prodExcept;
        $totalCharges        = $achatConsom + $servExt + $chPers + $impTax + $autChOp + $amortProv + $chargeFin + $impot + $impotDiff + $chargExcept;
        $resNetActivOrdin    = $totalProduits - $totalCharges;
        $resExtraordinaire   = $prodExcept - $chargExcept;
        $resNetExercice      = $resNetActivOrdin + $resExtraordinaire;

        $structure = [
            ['label'=>'Chiffre d’affaires',                  'note'=>'', 'montant'=>$ca],
            ['label'=>'Production stockée',                  'note'=>'', 'montant'=>$prodStock],
            ['label'=>'Production immobilisée',              'note'=>'', 'montant'=>$prodImmo],
            ['label'=>'Subventions d’exploitation',          'note'=>'comptes 740-749', 'montant'=>$subventionExp],
            ['label'=>'I – Production de l’exercice',        'note'=>'CA + stockée + immobilisée + subventions', 'montant'=>$prodExercice],
            ['label'=>'Achats consommés',                    'note'=>'', 'montant'=>$achatConsom],
            ['label'=>'Services extérieurs et autres consommations', 'note'=>'', 'montant'=>$servExt],
            ['label'=>'II – Consommation de l’exercice',     'note'=>'', 'montant'=>$consoExercice],
            ['label'=>'III – Valeur ajoutée d’exploitation', 'note'=>'I – II', 'montant'=>$valAjoutee],
            ['label'=>'Charges de personnel',                'note'=>'', 'montant'=>$chPers],
            ['label'=>'Impôts, taxes et versements assimilés', 'note'=>'', 'montant'=>$impTax],
            ['label'=>'IV – Excédent brut d’exploitation',   'note'=>'', 'montant'=>$excBrutExploitation],
            ['label'=>'Quote-part subventions d’immobilisation virée au résultat', 'note'=>'comptes 754, inclus AUTPRODOP', 'montant'=>$subvInvQtPart],
            ['label'=>'Autres charges opérationnelles',      'note'=>'', 'montant'=>$autChOp],
            ['label'=>'Dotations aux amortissements, provisions et pertes de valeur', 'note'=>'', 'montant'=>$amortProv],
            ['label'=>'Reprises sur provisions et pertes de valeur', 'note'=>'', 'montant'=>$repriseProv],
            ['label'=>'V – Résultat opérationnel',           'note'=>'', 'montant'=>$resOp],
            ['label'=>'Produits financiers',                 'note'=>'', 'montant'=>$prodFin],
            ['label'=>'Charges financières',                 'note'=>'', 'montant'=>$chargeFin],
            ['label'=>'VI – Résultat financier',             'note'=>'', 'montant'=>$resFinancier],
            ['label'=>'VII – Résultat avant impôts (V + VI)', 'note'=>'', 'montant'=>$resAvantImpots],
            ['label'=>'Impôts exigibles sur résultats',      'note'=>'', 'montant'=>$impot],
            ['label'=>'Impôts différés',                     'note'=>'', 'montant'=>$impotDiff],
            ['label'=>'Total des produits des activités ordinaires',   'note'=>'', 'montant'=>$totalProduits],
            ['label'=>'Total des charges des activités ordinaires',    'note'=>'', 'montant'=>$totalCharges],
            ['label'=>'VIII – Résultat net des activités ordinaires',  'note'=>'', 'montant'=>$resNetActivOrdin],
            ['label'=>'Éléments extraordinaires produits',   'note'=>'', 'montant'=>$prodExcept],
            ['label'=>'Éléments extraordinaires charges',    'note'=>'', 'montant'=>$chargExcept],
            ['label'=>'IX – Résultat extraordinaire',        'note'=>'', 'montant'=>$resExtraordinaire],
            ['label'=>'X – Résultat net de l’exercice',      'note'=>'', 'montant'=>$resNetExercice]
        ];

        return response()->json($structure);
    }

     public static function calculerCompteResultat($dateDebut, $dateFin)
    {
        // Helper pour chaque poste simple
        $get = function ($code) use ($dateDebut, $dateFin) {
            $resultat = \App\Http\Controllers\Calcul\UtilesController::calculerSommeCategorie($code, $dateDebut, $dateFin);
            return $resultat && $resultat->montant_total ? floatval($resultat->montant_total) : 0;
        };

        // Les montants de chaque poste
        $ca             = $get('CA');
        $prodStock      = $get('PRODSTOCK');
        $prodImmo       = $get('PRODIMMO');
        $subventionExp  = $get('SUBVENT'); // Subventions d'exploitation (comptes 740–749)
        $subvInvQtPart  = $get('AUTPRODOP'); // 754 (dans autres produits d'exploitation, comptes 750–759)
        $achatConsom    = $get('ACHATCONSOM');
        $servExt        = $get('SERVEXT');
        $chPers         = $get('CHPERS');
        $impTax         = $get('IMPTAX');
        $autChOp        = $get('AUTCHOP');
        $amortProv      = $get('AMORTPROV');
        $repriseProv    = $get('REPRISEPROV');
        $prodFin        = $get('PRODFIN');
        $chargeFin      = $get('CHARGEFIN');
        $impot          = $get('IMPOT');
        $impotDiff      = $get('IMPOTDIFF');
        $prodExcept     = $get('PRODEXCEPT');
        $chargExcept    = $get('CHAREXCEPT');

        // Formules agrégées avec subventions
        $prodExercice        = $ca + $prodStock + $prodImmo + $subventionExp;
        $consoExercice       = $achatConsom + $servExt;
        $valAjoutee          = $prodExercice - $consoExercice;
        $excBrutExploitation = $valAjoutee - $chPers - $impTax;
        $resOp               = $excBrutExploitation + $subvInvQtPart - $autChOp - $amortProv + $repriseProv;
        $resFinancier        = $prodFin - $chargeFin;
        $resAvantImpots      = $resOp + $resFinancier;
        $totalProduits       = $ca + $prodStock + $prodImmo + $subventionExp + $subvInvQtPart + $repriseProv + $prodFin + $prodExcept;
        $totalCharges        = $achatConsom + $servExt + $chPers + $impTax + $autChOp + $amortProv + $chargeFin + $impot + $impotDiff + $chargExcept;
        $resNetActivOrdin    = $totalProduits - $totalCharges;
        $resExtraordinaire   = $prodExcept - $chargExcept;
        $resNetExercice      = $resNetActivOrdin + $resExtraordinaire;

        return [
            'date_debut' => $dateDebut,
            'date_fin' => $dateFin,
            'structure' => [
                ['label'=>'Chiffre d’affaires',                  'note'=>'', 'montant'=>$ca],
                ['label'=>'Production stockée',                  'note'=>'', 'montant'=>$prodStock],
                ['label'=>'Production immobilisée',              'note'=>'', 'montant'=>$prodImmo],
                ['label'=>'Subventions d’exploitation',          'note'=>'comptes 740-749', 'montant'=>$subventionExp],
                ['label'=>'I – Production de l’exercice',        'note'=>'CA + stockée + immobilisée + subventions', 'montant'=>$prodExercice],
                ['label'=>'Achats consommés',                    'note'=>'', 'montant'=>$achatConsom],
                ['label'=>'Services extérieurs et autres consommations', 'note'=>'', 'montant'=>$servExt],
                ['label'=>'II – Consommation de l’exercice',     'note'=>'', 'montant'=>$consoExercice],
                ['label'=>'III – Valeur ajoutée d’exploitation', 'note'=>'I – II', 'montant'=>$valAjoutee],
                ['label'=>'Charges de personnel',                'note'=>'', 'montant'=>$chPers],
                ['label'=>'Impôts, taxes et versements assimilés', 'note'=>'', 'montant'=>$impTax],
                ['label'=>'IV – Excédent brut d’exploitation',   'note'=>'', 'montant'=>$excBrutExploitation],
                ['label'=>'Quote-part subventions d’immobilisation virée au résultat', 'note'=>'comptes 754, inclus AUTPRODOP', 'montant'=>$subvInvQtPart],
                ['label'=>'Autres charges opérationnelles',      'note'=>'', 'montant'=>$autChOp],
                ['label'=>'Dotations aux amortissements, provisions et pertes de valeur', 'note'=>'', 'montant'=>$amortProv],
                ['label'=>'Reprises sur provisions et pertes de valeur', 'note'=>'', 'montant'=>$repriseProv],
                ['label'=>'V – Résultat opérationnel',           'note'=>'', 'montant'=>$resOp],
                ['label'=>'Produits financiers',                 'note'=>'', 'montant'=>$prodFin],
                ['label'=>'Charges financières',                 'note'=>'', 'montant'=>$chargeFin],
                ['label'=>'VI – Résultat financier',             'note'=>'', 'montant'=>$resFinancier],
                ['label'=>'VII – Résultat avant impôts (V + VI)', 'note'=>'', 'montant'=>$resAvantImpots],
                ['label'=>'Impôts exigibles sur résultats',      'note'=>'', 'montant'=>$impot],
                ['label'=>'Impôts différés',                     'note'=>'', 'montant'=>$impotDiff],
                ['label'=>'Total des produits des activités ordinaires',   'note'=>'', 'montant'=>$totalProduits],
                ['label'=>'Total des charges des activités ordinaires',    'note'=>'', 'montant'=>$totalCharges],
                ['label'=>'VIII – Résultat net des activités ordinaires',  'note'=>'', 'montant'=>$resNetActivOrdin],
                ['label'=>'Éléments extraordinaires produits',   'note'=>'', 'montant'=>$prodExcept],
                ['label'=>'Éléments extraordinaires charges',    'note'=>'', 'montant'=>$chargExcept],
                ['label'=>'IX – Résultat extraordinaire',        'note'=>'', 'montant'=>$resExtraordinaire],
                ['label'=>'X – Résultat net de l’exercice',      'note'=>'', 'montant'=>$resNetExercice]
            ]
        ];
    }
}
