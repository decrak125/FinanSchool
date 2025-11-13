<template>
  <transition name="fade">
    <div class="chatbot-container">
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
          <div class="message-time">
            {{ message.time }}
            <!-- Bouton écouter la réponse pour les réponses bot -->
            <button
              v-if="message.type === 'bot'"
              class="listen-btn"
              @click="speakMessage(sanitizeText(message.content))"
              title="Écouter la réponse"
              style="margin-left:8px;padding:2px 7px;"
            >🔊</button>
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
          <span v-else><i class="bi bi-send" style="height: 20px; width: 20px;"></i></span>
        </button>
        <button
          @click="toggleRecording"
          class="micro-btn"
          :disabled="loading"
          :title="recording ? 'Arrêter' : 'Dicter une question au micro'"
          style="margin-left:8px"
        >
          <span v-if="!recording"><i class="bi bi-mic"></i></span>
          <span v-else><i class="bi bi-record-circle-fill" style="color: red;"></i></span>
        </button>
      </div>
    </div>
  </transition>
</template>

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
  },
  methods: {
    openChat() {
      this.isOpen = !this.isOpen;
    },
    generateSessionId() {
      this.sessionId = 'chat_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    },
    addWelcomeMessage() {
      this.messages.push({
        content: "👋 Bonjour ! Je suis votre assistant financier pour établissements scolaires. Je suis actuellement en phase de configuration, mais je peux déjà répondre à vos questions basiques !",
        type: 'bot',
        time: new Date().toLocaleTimeString()
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
    // Nettoie le texte (retire tout sauf . , ! % ? = + et lettres/chiffres/espaces)
    sanitizeText(text) {
      // Supprimer les emojis unicode
      text = text.replace(
        /([\u2700-\u27BF]|[\uE000-\uF8FF]|\uD83C[\uDC00-\uDFFF]|\uD83D[\uDC00-\uDFFF]|\u2011-\u26FF|\uD83E[\uDD00-\uDDFF])/g,
        ''
      );
      // Garder seulement ce qui est utile
      text = text.replace(/[^a-z0-9\s.,!%?=+À-ÿ:'-]/gi, ' ');
      // Espaces multiples
      return text.replace(/\s{2,}/g, ' ').trim();
    },
    async sendMessage() {
      if (!this.newMessage.trim() || this.loading) return;
      const userMessage = this.newMessage.trim();
      this.addMessage(userMessage, 'user');
      this.newMessage = '';
      this.loading = true;
      this.suggestions = [];
      try {
        const response = await axios.post('http://localhost:8000/api/chat/sending', {
          message: userMessage,
          session_id: this.sessionId
        });
        this.addMessage(response.data.response, 'bot');
        this.suggestions = response.data.suggestions || [];
        // Synthèse vocale (réponse nettoyée, pas d'emoji ni de ponctuation bizarre)
        this.speakMessage(this.sanitizeText(response.data.response));
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
      this.messages.push({
        content,
        type,
        time: new Date().toLocaleTimeString()
      });
      this.$nextTick(() => {
        this.scrollToBottom();
      });
    },
    formatMessage(content) {
      return content.replace(/\n/g, '<br>');
    },
    scrollToBottom() {
      const container = this.$refs.messagesContainer;
      container.scrollTop = container.scrollHeight;
    },
    // --- Synthèse vocale ---
    
speakMessage(text) {
  if ('speechSynthesis' in window) {
    window.speechSynthesis.cancel();
    const utterance = new window.SpeechSynthesisUtterance(text);
    utterance.lang = 'fr-FR';
    utterance.volume = 1;

    // Chercher et sélectionner la meilleure voix française
    const setVoice = () => {
      const voices = window.speechSynthesis.getVoices();
      const frenchVoices = voices.filter(v => v.lang.startsWith('fr'));
      
      // Prioriser les meilleures voix
      utterance.voice =
        frenchVoices.find(v => v.name.toLowerCase().includes('julie')) ||
        frenchVoices.find(v => v.name.toLowerCase().includes('thomas')) ||
        frenchVoices.find(v => v.name.toLowerCase().includes('google')) ||
        frenchVoices.find(v => v.name.toLowerCase().includes('natural')) ||
        frenchVoices[0] ||
        voices[0];

      // ✅ MEILLEURE INTONATION - Analyse approfondie
      const cleanText = text.trim();
      
      // Compter la ponctuation
      const questionMarks = (cleanText.match(/\?/g) || []).length;
      const exclamations = (cleanText.match(/!/g) || []).length;
      const ellipsis = cleanText.includes('...');
      
      // Intonation pour QUESTIONS
      if (questionMarks > 0) {
        if (questionMarks >= 2) {
          // Plusieurs questions = très enthousiaste
          utterance.pitch = 1.8;
          utterance.rate = 1.3;
        } else {
          // Une question = montée naturelle en fin
          utterance.pitch = 1.6;
          utterance.rate = 1.1;
        }
      }
      // Intonation pour EXCLAMATIONS
      else if (exclamations > 0) {
        if (exclamations >= 2) {
          // Plusieurs exclamations = emphase forte
          utterance.pitch = 1.4;
          utterance.rate = 0.8;
          utterance.volume = 1;
        } else {
          // Une exclamation = emphase modérée
          utterance.pitch = 1.25;
          utterance.rate = 0.95;
        }
      }
      // Intonation pour POINTS DE SUSPENSION
      else if (ellipsis) {
        // Ralenti pour créer du suspense
        utterance.pitch = 0.95;
        utterance.rate = 0.7;
      }
      // Intonation pour TEXTE NORMAL
      else {
        // Neutre et naturel
        utterance.pitch = 1.0;
        utterance.rate = 1.0;
      }

      // Bonus : améliorer l'intonation selon la longueur du texte
      const words = cleanText.split(' ').length;
      
      // Texte court = un peu plus rapide (plus naturel)
      if (words < 5 && exclamations === 0 && questionMarks === 0) {
        utterance.rate = utterance.rate * 1.1;
      }
      // Texte long = un peu plus lent (pour mieux comprendre)
      else if (words > 20) {
        utterance.rate = utterance.rate * 0.95;
      }

      // Ajouter des événements pour un meilleur contrôle
      utterance.onstart = () => {
        console.log('🔊 Début de la lecture avec intonation');
      };
      
      utterance.onend = () => {
        console.log('✅ Lecture terminée');
      };
      
      utterance.onerror = (event) => {
        console.error('❌ Erreur de synthèse vocale:', event.error);
      };

      window.speechSynthesis.speak(utterance);
    };

    // Charger les voix si pas disponibles
    if (window.speechSynthesis.getVoices().length === 0) {
      window.speechSynthesis.onvoiceschanged = setVoice;
    } else {
      setVoice();
    }
  }
}
    


  }
}
</script>

<style lang="scss" scoped>
.bouton-open {
  position: fixed;
  bottom: 64px;
  right: 64px;
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
  i {
    font-size: 24px;
  }
}
.chatbot-container {
  font-family: $stara-medium;
  font-size: 14px;
  position: fixed;
  bottom: 136px;
  right: 64px;
  width: 360px;
  height: 500px;
  border: 1px solid #ddd;
  border-radius: 10px;
  display: flex;
  flex-direction: column;
  background: white;
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
  background :linear-gradient(135deg,#1c45bd 0%,#011244 100%);
  color: white;
  padding: 15px;
  text-align: center;
  border-radius: 10px 10px 0 0;
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
  background: #fafafa;
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
  padding: 10px 15px;
  border-radius: 18px;
  max-width: 80%;
  word-wrap: break-word;
  line-height: 1.4;
}
.message.user .message-content {
  background: #007bff;
  color: white;
}
.message.bot .message-content {
  background: white;
  color: #333;
  border: 1px solid #dee2e6;
}
.message-time {
  font-size: 0.7em;
  color: #999;
  margin-top: 5px;
  display: flex;
  align-items: center;
}
.listen-btn {
  background: transparent;
  border: none;
  color: #1c45bd;
  font-size: 1.15em;
  margin-left: 5px;
  cursor: pointer;
  opacity: 0.7;
  transition: opacity .15s;
}
.listen-btn:hover {
  opacity: 1;
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
  display: flex;
  padding: 10px;
  gap: 5px;
  background: #f8f9fa;
  border-top: 1px solid #e9ecef;
  flex-wrap: wrap;
}
.suggestion-btn {
  padding: 6px 12px;
  background: white;
  border: 1px solid #007bff;
  border-radius: 15px;
  cursor: pointer;
  font-size: 0.8em;
  color: #007bff;
}
.suggestion-btn:hover {
  background: #007bff;
  color: white;
}
.chat-input {
  display: flex;
  padding: 15px;
  border-top: 1px solid #ddd;
  background: white;
  border-radius: 0 0 10px 10px;
}
.chat-input input {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 20px;
  outline: none;
}
.send-btn {
  margin-left: 10px;
  padding: 10px 15px;
  background: #007bff;
  color: white;
  border: none;
  border-radius: 20px;
  cursor: pointer;
}
.send-btn:disabled {
  background: #ccc;
  cursor: not-allowed;
}
.micro-btn {
  background: #f5f5f5;
  border: none;
  color: #2d6cdf;
  border-radius: 50%;
  width: 38px;
  height: 38px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2em;
  transition: background .2s;
  margin-left: 6px;
}
.micro-btn:active, .micro-btn:focus, .micro-btn:hover {
  background: #e1eafe;
}
.micro-btn[disabled] {
  opacity: 0.6;
  pointer-events: none;
}
</style>
