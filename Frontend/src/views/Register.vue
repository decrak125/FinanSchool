<template>
  <div class="register">
    <h2>Inscription</h2>

    <!-- Étape 1 : Email -->
    <div v-if="step === 1">
      <input type="email" v-model="email" placeholder="Votre email" />
      <button @click="sendCode">Envoyer le code</button>
    </div>

    <!-- Étape 2 : Code + Nom + Mot de passe -->
    <div v-if="step === 2">
      <input type="text" v-model="name" placeholder="Votre nom" />
      <input type="password" v-model="password" placeholder="Mot de passe" />
      <input type="password" v-model="password_confirmation" placeholder="Confirmer mot de passe" />
      <input type="text" v-model="code" placeholder="Code de vérification" />
      <button @click="verifyCode">Valider l'inscription</button>
    </div>

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
const code = ref('')
const message = ref('')
const error = ref(false)

const API_URL = 'http://localhost:8000/api'

// Étape 1 : envoyer le code
const sendCode = async () => {
  message.value = ''
  error.value = false
  try {
    const res = await axios.post(`${API_URL}/request-verification`, { email: email.value })
    if(res.data.status === 'success'){
      step.value = 2
      message.value = res.data.message
    }
  } catch (err) {
    error.value = true
    message.value = err.response?.data?.message || 'Erreur lors de l\'envoi du code'
  }
}

// Étape 2 : vérifier le code et créer l’utilisateur
const verifyCode = async () => {
  message.value = ''
  error.value = false
  try {
    const res = await axios.post(`${API_URL}/register`, {
      email: email.value,
      code: code.value,
      name: name.value,
      password: password.value,
      password_confirmation: password_confirmation.value
    })
    if(res.data.status === 'success'){
      message.value = 'Inscription réussie 🎉'
      step.value = 1
      // Réinitialiser les champs
      email.value = ''
      name.value = ''
      password.value = ''
      password_confirmation.value = ''
      code.value = ''
    }
  } catch(err) {
    error.value = true
    message.value = err.response?.data?.message || 'Erreur lors de la vérification'
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
</style>
