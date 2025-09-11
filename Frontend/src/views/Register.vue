<template>
  <div class="register">
    <h2>Inscription</h2>

    <!-- Étape 1 : Email -->
    <div v-if="step === 1">
      <input type="email" v-model="email" placeholder="Votre email" />
      <button @click="sendCode">Envoyer le code</button>
    </div>

    <!-- Étape 2 : Code à 6 chiffres -->
    <div v-if="step === 2" class="code-inputs">
      <div class="code-boxes">
        <input v-for="(digit, index) in codeDigits" 
               :key="index" 
               type="text" 
               maxlength="1" 
               v-model="codeDigits[index]"
               @input="focusNext(index, $event)" />
      </div>
      <button @click="verifyCode">Vérifier le code</button>
    </div>

    <!-- Étape 3 : Nom + mot de passe -->
    <div v-if="step === 3">
      <input type="text" v-model="name" placeholder="Votre nom" />
      <input type="password" v-model="password" placeholder="Mot de passe" />
      <input type="password" v-model="password_confirmation" placeholder="Confirmer mot de passe" />
      <button @click="registerUser">Finaliser l'inscription</button>
    </div>

    <!-- Messages -->
    <p v-if="message" :class="{'error': error}">{{ message }}</p>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import axios from 'axios'

const step = ref(1)
const email = ref('')
const name = ref('')
const password = ref('')
const password_confirmation = ref('')
const codeDigits = ref(['', '', '', '', '', ''])
const message = ref('')
const error = ref(false)

const API_URL = 'http://localhost:8000/api'

// Étape 1 : envoyer le code
const sendCode = async () => {
  message.value = ''
  error.value = false
  try {
    const res = await axios.post(`${API_URL}/request-verification`, { email: email.value })
    if (res.data.status === 'success') {
      step.value = 2
      message.value = res.data.message
    }
  } catch (err) {
    error.value = true
    message.value = err.response?.data?.message || 'Erreur lors de l\'envoi du code'
  }
}

// Gérer le focus automatique sur chaque input du code
const focusNext = (index, e) => {
  if (e.inputType === 'insertText' && index < 5) {
    const nextInput = e.target.parentNode.children[index + 1]
    nextInput.focus()
  }
}

// Étape 2 : vérifier le code
const verifyCode = async () => {
  message.value = ''
  error.value = false
  const code = codeDigits.value.join('')
  try {
    const res = await axios.post(`${API_URL}/request-verification`, { email: email.value, code })
    if (res.data.status === 'success') {
      step.value = 3
      message.value = 'Code validé ✅'
    }
  } catch (err) {
    error.value = true
    message.value = err.response?.data?.message || 'Code invalide'
  }
}

// Étape 3 : finaliser inscription
const registerUser = async () => {
  message.value = ''
  error.value = false
  try {
    const res = await axios.post(`${API_URL}/register`, {
      email: email.value,
      name: name.value,
      password: password.value,
      password_confirmation: password_confirmation.value
    })
    if (res.data.status === 'success') {
      message.value = 'Inscription réussie 🎉'
      
      // Réinitialiser les champs
      step.value = 1
      email.value = ''
      name.value = ''
      password.value = ''
      password_confirmation.value = ''
      codeDigits.value = ['', '', '', '', '', '']

      // ✅ Redirection vers login après 1 seconde
      setTimeout(() => {
        window.location.href = '/'  // ou this.$router.push('/') si tu es dans un component classique
      }, 1000)
    }
  } catch (err) {
    error.value = true
    message.value = err.response?.data?.message || 'Erreur lors de la création'
  }
}


</script>

<style scoped>
.register {
  max-width: 400px;
  margin: auto;
  display: flex;
  flex-direction: column;
  gap: 10px;
}

input {
  padding: 8px;
  font-size: 16px;
  width: 100%;
  box-sizing: border-box;
}

button {
  padding: 10px;
  font-size: 16px;
  background-color: #ff3b30;
  color: white;
  border: none;
  cursor: pointer;
}

.error {
  color: red;
}

.code-inputs {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.code-boxes {
  display: flex;
  gap: 5px;
}

.code-boxes input {
  width: 40px;
  text-align: center;
  font-size: 24px;
  padding: 5px;
}
</style>
