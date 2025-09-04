<template>
  <p>Se connecter</p>
  <div>
    <input v-model="email" type="email" placeholder="Email" />
    <input v-model="password" type="password" placeholder="Mot de passe" />
    <button @click="handleLogin">Se connecter</button>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import axios from 'axios';

const email = ref('');
const password = ref('');
const errorMessage = ref('');

async function handleLogin() {
  try {
    // Remplace l'URL par ton API Laravel
    const response = await axios.post('http://localhost:8000/api/login', {
      email: email.value,
      password: password.value
    });

    console.log(response.data); // Affiche la réponse de Laravel
    // Ici tu peux stocker le token ou rediriger l'utilisateur
    alert('Connexion réussie !');
  } catch (error) {
    console.error(error);
    errorMessage.value = 'Email ou mot de passe incorrect';
  }
}
</script>