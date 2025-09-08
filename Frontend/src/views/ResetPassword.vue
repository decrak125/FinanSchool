<template>
  <div>
    <h2>Réinitialisation du mot de passe</h2>
    <form @submit.prevent="submitForm">
      <input type="email" v-model="email" placeholder="Email" readonly />
      <input type="password" v-model="password" placeholder="Nouveau mot de passe" />
      <input type="password" v-model="password_confirmation" placeholder="Confirmer le mot de passe" />
      <button type="submit">Réinitialiser</button>
    </form>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import axios from 'axios';

const email = ref('');
const password = ref('');
const password_confirmation = ref('');
const token = ref('');

// Récupérer token + email depuis l'URL
onMounted(() => {
    const urlParams = new URLSearchParams(window.location.search);
    token.value = urlParams.get('token');
    email.value = urlParams.get('email');
});

const submitForm = async () => {
  try {
    await axios.post('http://127.0.0.1:8000/api/reset-password', {
      token: token.value,
      email: email.value,
      password: password.value,
      password_confirmation: password_confirmation.value
    });
    alert('Mot de passe réinitialisé avec succès !');
  } catch (error) {
    console.error(error);
    alert('Erreur lors de la réinitialisation.');
  }
};
</script>
