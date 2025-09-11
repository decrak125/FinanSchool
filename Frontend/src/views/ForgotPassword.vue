<template>
  <div>
    <h2>Mot de passe oublié</h2>
    <input v-model="email" type="email" placeholder="Votre email" />
    <button @click="sendLink">Envoyer le lien</button>

    <!-- Bouton pour ouvrir Gmail après envoi -->
    <div v-if="showOpenMail">
      <button @click="openGmail">📧 Ouvrir Gmail</button>
    </div>
  </div>
</template>

<script setup>
import axios from 'axios'
import { ref } from 'vue'

const email = ref('')
const showOpenMail = ref(false)

const sendLink = async () => {
  try {
    await axios.post('http://127.0.0.1:8000/api/forgot-password', { email: email.value })
    alert('Lien envoyé par email !')
    showOpenMail.value = true
  } catch (err) {
    alert('Erreur : ' + err.response.data.message)
  }
}

// Ouvre Gmail dans un nouvel onglet
const openGmail = () => {
  window.open('https://mail.google.com', '_blank')
}
</script>
