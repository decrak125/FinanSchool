<template>
    <div>
      <h2>Mot de passe oublié</h2>
      <input v-model="email" type="email" placeholder="Votre email" />
      <button @click="sendLink">Envoyer le lien</button>
    </div>
  </template>
  
  <script setup>
  import axios from 'axios'
  import { ref } from 'vue'
  
  const email = ref('')
  
  const sendLink = async () => {
    try {
      await axios.post('http://127.0.0.1:8000/api/forgot-password', { email: email.value })
      alert('Lien envoyé par email !')
    } catch (err) {
      alert('Erreur : ' + err.response.data.message)
    }
  }
  </script>
  