<?php

namespace Tests\Feature;

use App\Console\Commands\CheckComptesNonAffectes;
use App\Events\NotificationCreee;
use App\Models\PlanCompte\SousCompte;
use App\Models\notifications\Evenement;
use App\Models\notifications\Notification;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Event;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schema;
use Tests\TestCase;

class CheckComptesNonAffectesTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        // Ensure minimal schema for the test since we use in-memory sqlite
        Schema::create('comptes', function($table){
            $table->increments('Id_compte');
            $table->integer('Code_compte');
        });
        Schema::create('sous_comptes', function($table){
            $table->increments('Id_Sous_compte');
            $table->unsignedInteger('Id_compte');
        });
        Schema::create('affectationanalytique', function($table){
            $table->increments('id');
            $table->unsignedInteger('Id_Sous_compte');
        });
        Schema::create('types_evenement', function($table){
            $table->increments('id');
            $table->string('libelle')->nullable();
        });
        Schema::create('niveaux_urgence', function($table){
            $table->increments('id');
            $table->string('libelle')->nullable();
        });
        Schema::create('evenements', function($table){
            $table->increments('id');
            $table->unsignedInteger('type_evenement_id');
            $table->text('donnees_evenement')->nullable();
            $table->timestamps();
        });
        Schema::create('notifications', function($table){
            $table->increments('id');
            $table->unsignedInteger('evenement_id');
            $table->unsignedInteger('niveau_urgence_id');
            $table->string('titre');
            $table->text('message');
            $table->string('statut');
            $table->timestamps();
        });

        // Seed minimal lookup rows used by command
        \DB::table('types_evenement')->insert(['id' => 4, 'libelle' => 'Alerte comptes non affectes']);
        \DB::table('niveaux_urgence')->insert(['id' => 2, 'libelle' => 'Moyen']);
    }

    public function test_no_notification_when_no_unassigned_accounts(): void
    {
        // comptes 600..799 but all sous_comptes are assigned
        $idCompte = \DB::table('comptes')->insertGetId(['Code_compte' => 650]);
        $sc1 = \DB::table('sous_comptes')->insertGetId(['Id_compte' => $idCompte]);
        \DB::table('affectationanalytique')->insert(['Id_Sous_compte' => $sc1]);

        Event::fake();

        Artisan::call('comptes:check-non-affectes');

        $this->assertDatabaseCount('evenements', 0);
        $this->assertDatabaseCount('notifications', 0);
        Event::assertNotDispatched(NotificationCreee::class);
    }

    public function test_creates_notification_for_unassigned_accounts_in_target_range(): void
    {
        $compteInRange = \DB::table('comptes')->insertGetId(['Code_compte' => 701]);
        $scA = \DB::table('sous_comptes')->insertGetId(['Id_compte' => $compteInRange]);
        // leave scA unassigned

        $compteOutOfRange = \DB::table('comptes')->insertGetId(['Code_compte' => 550]);
        $scB = \DB::table('sous_comptes')->insertGetId(['Id_compte' => $compteOutOfRange]);
        // assign scB to ensure it doesn't count anyway
        \DB::table('affectationanalytique')->insert(['Id_Sous_compte' => $scB]);

        Event::fake();

        Artisan::call('comptes:check-non-affectes');

        $this->assertDatabaseCount('evenements', 1);
        $this->assertDatabaseCount('notifications', 1);
        $this->assertDatabaseHas('notifications', [
            'titre' => 'Comptes non affectés détectés',
            'statut' => 'non_lu'
        ]);
        Event::assertDispatched(NotificationCreee::class);
    }

    public function test_notification_payload_contains_count_and_link(): void
    {
        $compteInRange = \DB::table('comptes')->insertGetId(['Code_compte' => 600]);
        $sc1 = \DB::table('sous_comptes')->insertGetId(['Id_compte' => $compteInRange]);
        $sc2 = \DB::table('sous_comptes')->insertGetId(['Id_compte' => $compteInRange]);
        // assign only one
        \DB::table('affectationanalytique')->insert(['Id_Sous_compte' => $sc1]);

        Artisan::call('comptes:check-non-affectes');

        $evenement = \DB::table('evenements')->first();
        $this->assertNotNull($evenement);
        $payload = json_decode($evenement->donnees_evenement, true);
        $this->assertEquals(1, $payload['nombre_comptes'] ?? null);
        $this->assertEquals('http://localhost:5173/non-affected', $payload['lien_redirection'] ?? null);
    }

    public function test_command_outputs_proper_info_messages(): void
    {
        $this->artisan('comptes:check-non-affectes')
            ->expectsOutput('Aucun compte non affecté trouvé')
            ->assertExitCode(0);

        $compteInRange = \DB::table('comptes')->insertGetId(['Code_compte' => 700]);
        $sc = \DB::table('sous_comptes')->insertGetId(['Id_compte' => $compteInRange]);

        $this->artisan('comptes:check-non-affectes')
            ->expectsOutput('Notification créée pour 1 comptes non affectés')
            ->assertExitCode(0);
    }

    public function test_only_unassigned_in_range_are_counted_when_mix_present(): void
    {
        $compteInRange = \DB::table('comptes')->insertGetId(['Code_compte' => 605]);
        $sc1 = \DB::table('sous_comptes')->insertGetId(['Id_compte' => $compteInRange]); // unassigned
        $sc2 = \DB::table('sous_comptes')->insertGetId(['Id_compte' => $compteInRange]); // assigned
        \DB::table('affectationanalytique')->insert(['Id_Sous_compte' => $sc2]);

        $compteOutRange = \DB::table('comptes')->insertGetId(['Code_compte' => 800]);
        $sc3 = \DB::table('sous_comptes')->insertGetId(['Id_compte' => $compteOutRange]); // unassigned but out of range

        Artisan::call('comptes:check-non-affectes');

        $evenement = \DB::table('evenements')->first();
        $payload = json_decode($evenement->donnees_evenement, true);
        $this->assertEquals(1, $payload['nombre_comptes'] ?? null);
    }
}
