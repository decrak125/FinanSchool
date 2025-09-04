<template>
  <div class="login-page">
    <h1>Connexion</h1>
    <form @submit.prevent="handleLogin">
      <input type="email" placeholder="Email" v-model="email" required />
      <input type="password" placeholder="Mot de passe" v-model="password" required />
      <button type="submit">Se connecter</button>
    </form>
    <p v-if="errorMessage" style="color:red">{{ errorMessage }}</p>
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

<style scoped>
.login-page {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 100px;
}
input {
  display: block;
  margin: 10px 0;
  padding: 8px;
  width: 200px;
}
button {
  padding: 8px 12px;
}
</style>
