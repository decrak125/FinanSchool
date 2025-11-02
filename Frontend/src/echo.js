import Echo from 'laravel-echo';
import Pusher from 'pusher-js';

window.Pusher = Pusher;  // ← CRUCIAL !

window.Echo = new Echo({
    broadcaster: 'reverb',  // ← Rester sur 'reverb'
    key: import.meta.env.VITE_REVERB_APP_KEY || 'local',
    wsHost: import.meta.env.VITE_REVERB_HOST || window.location.hostname,
    wsPort: import.meta.env.VITE_REVERB_PORT || 8080,
    wssPort: import.meta.env.VITE_REVERB_PORT || 443,
    forceTLS: false,
    enabledTransports: ['ws', 'wss'],
});