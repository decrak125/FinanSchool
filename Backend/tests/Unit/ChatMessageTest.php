<?php

namespace Tests\Unit;

use App\Models\ChatBot\ChatMessage;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ChatMessageTest extends TestCase
{
    use RefreshDatabase;

    /** @test */
    public function it_allows_mass_assignment_for_fillable_fields()
    {
        $data = [
            'message' => 'Hello',
            'response' => 'Hi there',
            'session_id' => 'session-123',
            'user_id' => 1,
        ];

        $message = new ChatMessage($data);

        $this->assertSame('Hello', $message->message);
        $this->assertSame('Hi there', $message->response);
        $this->assertSame('session-123', $message->session_id);
        $this->assertSame(1, $message->user_id);
    }

    /** @test */
    public function it_ignores_mass_assignment_for_non_fillable_fields()
    {
        $data = [
            'message' => 'Hello',
            'response' => 'Hi there',
            'session_id' => 'session-123',
            'user_id' => 1,
            'non_fillable' => 'should be ignored',
        ];

        $message = new ChatMessage($data);

        $this->assertObjectNotHasProperty('non_fillable', $message);
    }

    /** @test */
    public function it_has_a_user_relationship()
    {
        $user = User::factory()->create();

        $chat = ChatMessage::create([
            'message' => 'Hello',
            'response' => 'World',
            'session_id' => 'abc',
            'user_id' => $user->id,
        ]);

        $this->assertInstanceOf(User::class, $chat->user);
        $this->assertTrue($chat->user->is($user));
    }

    /** @test */
    public function user_relationship_returns_null_when_no_user()
    {
        $chat = ChatMessage::create([
            'message' => 'Hello',
            'response' => 'World',
            'session_id' => 'abc',
            'user_id' => null,
        ]);

        $this->assertNull($chat->user);
    }

    /** @test */
    public function it_can_be_persisted_and_retrieved()
    {
        $user = User::factory()->create();

        $created = ChatMessage::create([
            'message' => 'How are you?',
            'response' => 'Fine',
            'session_id' => 'sess-999',
            'user_id' => $user->id,
        ]);

        $found = ChatMessage::find($created->id);

        $this->assertNotNull($found);
        $this->assertSame('How are you?', $found->message);
        $this->assertSame('Fine', $found->response);
        $this->assertSame('sess-999', $found->session_id);
        $this->assertSame($user->id, $found->user_id);
    }
}
