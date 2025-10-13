<?php
// app/Listeners/RafraichirVuesTemporelles.php

namespace App\Listeners;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use App\Events\MouvementCreated;

class RafraichirVuesTemporelles
{
    /**
     * Handle the event.
     */
    public function handle(MouvementCreated $event): void
    {
        try {
            Log::info('🚀 Début du rafraîchissement des vues matérialisées');
            
            // Appeler la fonction PostgreSQL
            DB::select('SELECT rafraichir_vues_temporelles()');
            
            Log::info('✅ Vues matérialisées rafraîchies avec succès');
            
        } catch (\Exception $e) {
            Log::error('❌ Erreur lors du rafraîchissement des vues: ' . $e->getMessage());
        }
    }
}