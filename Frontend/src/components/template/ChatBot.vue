<script>
import axios from 'axios';
import { ref } from 'vue';

export default {
  name: 'ChatBot',
  data() {
    return {
      newMessage: '',
      messages: [],
      loading: false,
      sessionId: null,
      suggestions: [],
      recording: false,
      recognition: null,
      // Nouveaux états pour la synthèse vocale
      isSpeaking: false,
      currentlySpeakingId: null,
      speechUtterance: null,
      voicesLoaded: false
    }
  },
  setup() {
    const isOpen = ref(false);
    return {
      isOpen
    }
  },
  mounted() {
    this.generateSessionId();
    this.addWelcomeMessage();
    // Initialiser la synthèse vocale
    this.initializeSpeechSynthesis();
  },
  beforeUnmount() {
    // Arrêter la synthèse vocale quand le composant est détruit
    this.stopSpeaking();
  },
  methods: {
    // Initialiser la synthèse vocale
    initializeSpeechSynthesis() {
      if (!('speechSynthesis' in window)) {
        console.warn('La synthèse vocale n\'est pas supportée par ce navigateur');
        return;
      }
      
      // Attendre que les voix soient chargées
      window.speechSynthesis.onvoiceschanged = () => {
        this.voicesLoaded = true;
        console.log('Voix chargées:', this.loadVoices().length);
      };
      
      // Charger les voix immédiatement si elles sont déjà disponibles
      if (window.speechSynthesis.getVoices().length > 0) {
        this.voicesLoaded = true;
      }
    },
    
    // Charger les voix disponibles
    loadVoices() {
      return window.speechSynthesis.getVoices();
    },
    
    // Trouver la meilleure voix française
    getBestFrenchVoice() {
      if (!this.voicesLoaded) {
        console.log('Les voix ne sont pas encore chargées');
        return null;
      }
      
      const voices = this.loadVoices();
      console.log('Voix disponibles:', voices.map(v => `${v.name} (${v.lang})`));
      
      if (!voices.length) return null;
      
      // Chercher une voix française
      const frenchVoices = voices.filter(voice => 
        voice.lang.includes('fr') || 
        voice.lang.includes('FR') ||
        voice.name.toLowerCase().includes('french') ||
        voice.name.toLowerCase().includes('français')
      );
      
      console.log('Voix françaises trouvées:', frenchVoices.length);
      
      // Préférer les voix françaises
      if (frenchVoices.length > 0) {
        // Chercher une voix spécifique
        const preferred = frenchVoices.find(voice => 
          voice.name.includes('Julie') || 
          voice.name.includes('Google') ||
          voice.name.includes('Microsoft')
        );
        return preferred || frenchVoices[0];
      }
      
      // Sinon utiliser la première voix disponible
      return voices[0];
    },
    
    openChat() {
      this.isOpen = !this.isOpen;
      if (!this.isOpen) {
        // Arrêter la parole quand on ferme le chat
        this.stopSpeaking();
      }
    },
    generateSessionId() {
      this.sessionId = 'chat_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    },
    addWelcomeMessage() {
      this.messages.push({
        content: "👋 Bonjour ! Je suis votre assistant financier pour établissements scolaires. Je suis actuellement en phase de configuration, mais je peux déjà répondre à vos questions basiques !",
        type: 'bot',
        time: new Date().toLocaleTimeString(),
        // Ajouter un ID unique
        id: 'welcome_' + Date.now()
      });
    },
    toggleRecording() {
      if (this.loading) return;
      if (!this.recording) {
        if (!('webkitSpeechRecognition' in window)) {
          alert("Votre navigateur ne supporte pas la reconnaissance vocale.");
          return;
        }
        this.recognition = new webkitSpeechRecognition();
        this.recognition.lang = "fr-FR";
        this.recognition.continuous = false;
        this.recognition.interimResults = false;
        this.recognition.onresult = (event) => {
          const transcript = event.results[0][0].transcript;
          this.newMessage = transcript;
        };
        this.recognition.onend = () => {
          this.recording = false;
          this.recognition = null;
        };
        this.recognition.onerror = () => {
          this.recording = false;
          this.recognition = null;
        };
        this.recording = true;
        this.recognition.start();
      } else {
        if (this.recognition) this.recognition.stop();
        this.recording = false;
      }
    },
    // Nettoie le texte pour la synthèse vocale (plus naturel)
    sanitizeTextForSpeech(text) {
      if (!text) return '';
      
      // Supprimer les emojis
      text = text.replace(
        /([\u2700-\u27BF]|[\uE000-\uF8FF]|\uD83C[\uDC00-\uDFFF]|\uD83D[\uDC00-\uDFFF]|\u2011-\u26FF|\uD83E[\uDD00-\uDDFF])/g,
        ''
      );
      
      // Remplacer les caractères problématiques
      text = text.replace(/[*/_\-]/g, ' ');
      
      // Nettoyer les URL
      text = text.replace(/https?:\/\/[^\s]+/g, 'lien internet');
      
      // Formater les pourcentages
      text = text.replace(/(\d+)%/g, '$1 pour cent');
      
      // Garder la ponctuation utile pour le discours
      text = text.replace(/[^\w\s.,!?;:À-ÿ'-]/g, ' ');
      
      // Éviter les abréviations
      text = text.replace(/\bex\./g, 'exemple');
      text = text.replace(/\bc-à-d/g, 'c\'est à dire');
      text = text.replace(/\bcf\./g, 'voir');
      
      // Espaces multiples
      text = text.replace(/\s{2,}/g, ' ').trim();
      
      return text;
    },
    
    async sendMessage() {
      if (!this.newMessage.trim() || this.loading) return;
      const userMessage = this.newMessage.trim();
      this.addMessage(userMessage, 'user');
      this.newMessage = '';
      this.loading = true;
      this.suggestions = [];
      try {
        const response = await axios.post('http://localhost:8000/api/chat/send', {
          message: userMessage,
          session_id: this.sessionId
        });
        this.addMessage(response.data.response, 'bot');
        this.suggestions = response.data.suggestions || [];
        // NE PAS déclencher la synthèse vocale automatiquement
      } catch (error) {
        console.error('Erreur:', error);
        this.addMessage('Désolé, une erreur est survenue. Veuillez réessayer.', 'bot');
      } finally {
        this.loading = false;
      }
    },
    selectSuggestion(suggestion) {
      this.newMessage = suggestion;
      this.sendMessage();
    },
    addMessage(content, type) {
      const message = {
        content,
        type,
        time: new Date().toLocaleTimeString(),
        // Ajouter un ID unique pour chaque message
        id: 'msg_' + Date.now() + '_' + Math.random().toString(36).substr(2, 5)
      };
      this.messages.push(message);
      this.$nextTick(() => {
        this.scrollToBottom();
      });
      return message;
    },
    formatMessage(content) {
      return content.replace(/\n/g, '<br>');
    },
    scrollToBottom() {
      const container = this.$refs.messagesContainer;
      container.scrollTop = container.scrollHeight;
    },
    
    // --- Synthèse vocale améliorée ---
    speakMessage(message) {
      if (!('speechSynthesis' in window)) {
        console.warn('La synthèse vocale n\'est pas supportée par ce navigateur');
        alert('La synthèse vocale n\'est pas supportée par votre navigateur.');
        return;
      }
      
      // Vérifier si les voix sont chargées
      if (!this.voicesLoaded) {
        console.log('Les voix ne sont pas encore chargées, tentative de chargement...');
        this.voicesLoaded = window.speechSynthesis.getVoices().length > 0;
      }
      
      // Si déjà en train de parler ce message, arrêter
      if (this.currentlySpeakingId === message.id) {
        this.stopSpeaking();
        return;
      }
      
      // Arrêter toute lecture en cours
      this.stopSpeaking();
      
      const text = this.sanitizeTextForSpeech(message.content);
      if (!text.trim()) {
        console.warn('Texte vide après nettoyage');
        return;
      }
      
      console.log('Texte à prononcer:', text);
      
      try {
        this.speechUtterance = new SpeechSynthesisUtterance(text);
        
        // Configurer la voix
        const voice = this.getBestFrenchVoice();
        if (voice) {
          this.speechUtterance.voice = voice;
          this.speechUtterance.lang = 'fr-FR';
          console.log('Voix utilisée:', voice.name, voice.lang);
        } else {
          console.log('Aucune voix spécifique trouvée, utilisation des paramètres par défaut');
          this.speechUtterance.lang = 'fr-FR';
        }
        
        // Paramètres pour un discours naturel
        this.speechUtterance.rate = 0.9;    // Vitesse légèrement réduite pour plus de naturel
        this.speechUtterance.pitch = 1.0;   // Ton normal
        this.speechUtterance.volume = 1.0;
        
        // Événements
        this.speechUtterance.onstart = () => {
          console.log('Début de la lecture');
          this.isSpeaking = true;
          this.currentlySpeakingId = message.id;
        };
        
        this.speechUtterance.onend = () => {
          console.log('Fin de la lecture');
          this.isSpeaking = false;
          this.currentlySpeakingId = null;
          this.speechUtterance = null;
        };
        
        this.speechUtterance.onerror = (event) => {
          console.error('Erreur de synthèse vocale:', event);
          this.isSpeaking = false;
          this.currentlySpeakingId = null;
          this.speechUtterance = null;
          alert('Erreur lors de la synthèse vocale. Veuillez vérifier la console.');
        };
        
        // Lancer la lecture
        window.speechSynthesis.speak(this.speechUtterance);
        
      } catch (error) {
        console.error('Erreur lors de la création de SpeechSynthesisUtterance:', error);
        alert('Erreur lors de l\'initialisation de la synthèse vocale: ' + error.message);
      }
    },
    
    // Arrêter la lecture en cours
    stopSpeaking() {
      if ('speechSynthesis' in window) {
        window.speechSynthesis.cancel();
        this.isSpeaking = false;
        this.currentlySpeakingId = null;
        if (this.speechUtterance) {
          this.speechUtterance = null;
        }
      }
    },
    
    // Toggle lecture d'un message
    toggleMessageSpeech(message) {
      if (this.currentlySpeakingId === message.id) {
        this.stopSpeaking();
      } else {
        this.speakMessage(message);
      }
    }
  }
}
</script>

<template>
<transition name="fade">
    <div class="chatbot-container" v-if="isOpen">
    <div class="chat-header">
      <h3>Assistant Financier</h3>
      <p>Analyse de l'établissement scolaire</p>
    </div>
    
    <div class="chat-messages" ref="messagesContainer">
      <div 
        v-for="(message, index) in messages" 
        :key="index"
        :class="['message', message.type]"
      >
        <div class="message-content" v-html="formatMessage(message.content)"></div>
        <div class="detail-msg">
          <div class="message-time">{{ message.time }}</div>
          <!-- Bouton écouter la réponse pour les réponses bot -->
          <button
            v-if="message.type === 'bot'"
            :class="['listen-btn', { active: currentlySpeakingId === message.id }]"
            @click="toggleMessageSpeech(message)"
            :title="currentlySpeakingId === message.id ? 'Arrêter la lecture' : 'Écouter la réponse'"
          >
            <i 
              v-if="currentlySpeakingId === message.id" 
              class="bi bi-stop-circle-fill"
            ></i>
            <i 
              v-else 
              class="bi bi-volume-up-fill"
            ></i>
          </button>
        </div>
      </div>
      
      <div v-if="loading" class="message bot">
        <div class="message-content typing-indicator">
          <span></span><span></span><span></span>
        </div>
      </div>
    </div>

    <div class="suggestions" v-if="suggestions.length > 0 && !loading">
      <button 
        v-for="suggestion in suggestions" 
        :key="suggestion"
        @click="selectSuggestion(suggestion)"
        class="suggestion-btn"
      >
        {{ suggestion }}
      </button>
    </div>

    <div class="chat-input">
      <input 
        v-model="newMessage" 
        @keyup.enter="sendMessage"
        placeholder="Posez votre question sur les finances..."
        :disabled="loading"
      />
      <button 
        @click="sendMessage" 
        :disabled="loading || !newMessage.trim()"
        class="send-btn"
      >
        <span v-if="loading">⏳</span>
        <span v-else><i class="bi bi-send-fill"></i></span>
      </button>
      <button
          @click="toggleRecording"
          class="send-btn"
          :disabled="loading"
          :title="recording ? 'Arrêter' : 'Dicter une question au micro'"
          style="margin-left:8px"
        >
          <span v-if="!recording"><i class="bi bi-mic-fill"></i></span>
          <span v-else><i class="bi bi-record-circle-fill" style="color: red;"></i></span>
        </button>
    </div>
  </div>

</transition>
<div class="bouton-open" @click="openChat">
    <i class="bi bi-chat-dots-fill" v-if="!isOpen"></i>
    <i class="bi bi-x" v-else></i>
  </div>
</template>


<style lang="scss" scoped>
.detail-msg{
  display: flex;
  justify-content: space-between;
  align-items: center;
  background: transparent;
}
.listen-btn{
  border: none;
  background-color: transparent;
  padding: 3px;
  margin-left: 5px;
  color : $primary;
  transition: all 0.3s ease;
  cursor: pointer;
  
  &.active {
    color: #ff3b30;
    animation: pulse 1.5s infinite;
  }
  
  &:hover {
    transform: scale(1.1);
  }
  
  &:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
}

@keyframes pulse {
  0% { opacity: 1; }
  50% { opacity: 0.6; }
  100% { opacity: 1; }
}

.bouton-open {
  position: fixed;
  bottom: 32px;
  right: 32px;
  z-index: 9999999999;
  width: 64px;
  height: 64px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  border-radius: 50%;
  background-color: $primary;
  color: white;
  i{
    font-size: 24px;
  }
}
.chatbot-container {
  @include glass();
    font-family: $stara-medium;
    font-size: 14px;
    position: fixed;
  bottom: 116px;
  right: 32px;

  width: 360px;
  height: 500px;
  border: 1px solid #ddd;
  border-radius: $radius-pm;
  display: flex;
  flex-direction: column;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  z-index: 9999999999;
}
.fade-enter-active,
.fade-leave-active {
  transition: all 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
  transform: scale(0.9);
}
.chat-header {
  background-color: $primary;
  color: white;
  padding: 15px;
  text-align: center;
  border-radius: $radius-pm $radius-pm 0 0;
}

.chat-header h3 {
  margin: 0 0 5px 0;
}

.chat-header p {
  margin: 0;
  font-size: 0.9em;
  opacity: 0.9;
}

.chat-messages {
  flex: 1;
  padding: 15px;
  overflow-y: auto;
}

.message {
  margin-bottom: 15px;
  display: flex;
  flex-direction: column;
  
}

.message.user {
  align-items: flex-end;
}

.message.bot {
  align-items: flex-start;
}

.message-content {
  padding: 10px 20px;
  display: flex;
  border-radius: $radius-pm;
  max-width: 80%;
  word-wrap: break-word;
  line-height: 1.4;
}

.message.user .message-content {
  border-radius: $radius-pm;
  @include glass();
  background: $primary;
  color: white;
}

.message.bot .message-content {
  border-radius: $radius-pm;
  @include glass();
  color: #333;
}

.message-time {
  flex-direction: column;
  justify-content: center;
  align-items: center;
  font-size: 0.7em;
  color: $dark;
}

.typing-indicator {
  display: flex;
  gap: 3px;
}

.typing-indicator span {
  height: 8px;
  width: 8px;
  border-radius: 50%;
  background: #6c757d;
  animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) { animation-delay: 0s; }
.typing-indicator span:nth-child(2) { animation-delay: 0.2s; }
.typing-indicator span:nth-child(3) { animation-delay: 0.4s; }

@keyframes typing {
  0%, 60%, 100% { transform: translateY(0); }
  30% { transform: translateY(-5px); }
}

.suggestions {
  @include glass();
  display: flex;
  padding: 10px;
  gap: 5px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
  flex-wrap: wrap;
}

.suggestion-btn {
  @include glass();
  padding: 6px 12px;
  background: white;
  border-radius: 15px;
  cursor: pointer;
  font-size: 0.8em;
  color: $primary;
}

.suggestion-btn:hover {
  background: $primary;
  color: white;
}

.chat-input {
  display: flex;
  padding: 15px;
  border-top: 1px solid #ddd;
  border-radius: 0 0 $radius-pm $radius-pm;
}

.chat-input input {
  @include glass();
  flex: 1;
  padding: 10px;
  border-radius: 20px;
  outline: none;
}

.send-btn {
  margin-left: 10px;
  padding: 10px 12px;
  background: $primary;
  color: white;
  border: none;
  border-radius: 20px;
  cursor: pointer;
}

.send-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}
</style>