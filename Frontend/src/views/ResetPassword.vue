<template>
    <div>
      <h2>Réinitialiser le mot de passe</h2>
      <input v-model="email" type="email" placeholder="Votre email" />
      <input v-model="password" type="password" placeholder="Nouveau mot de passe" />
      <input v-model="password_confirmation" type="password" placeholder="Confirmez le mot de passe" />
      <button @click="resetPassword">Réinitialiser</button>
    </div>
  </template>
  
  <script setup>
  import axios from 'axios'
  import { ref } from 'vue'
  import { useRoute } from 'vue-router'
  
  const route = useRoute()
  const email = ref('')
  const password = ref('')
  const password_confirmation = ref('')
  const token = route.query.token // récupéré depuis l'URL envoyée par mail
  
  const resetPassword = async () => {
    try {
      await axios.post('http://127.0.0.1:8000/api/reset-password', {
        email: email.value,
        password: password.value,
        password_confirmation: password_confirmation.value,
        token: token
      })
      alert('Mot de passe réinitialisé avec succès !')
    } catch (err) {
      alert('Erreur : ' + err.response.data.message)
    }
  }
  </script>
  