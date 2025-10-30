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
      suggestions: []
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
    }
  }
}
</script>

<template>
<transition name="fade">
    <div class="chatbot-container" v-if="isOpen">
    <div class="chat-header">
      <h3>🤖 Assistant Financier</h3>
      <p>Analyse de l'établissement scolaire</p>
    </div>
    
    <div class="chat-messages" ref="messagesContainer">
      <div 
        v-for="(message, index) in messages" 
        :key="index"
        :class="['message', message.type]"
      >
        <div class="message-content" v-html="formatMessage(message.content)"></div>
        <div class="message-time">{{ message.time }}</div>
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
        <span v-else>📤</span>
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
  i{
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
  background-color: $primary;
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
</style>