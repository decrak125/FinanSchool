<template>
  <div class="login-page">
    <h1>Connexion</h1>
    <form @submit.prevent="handleLogin">
      <input type="email" placeholder="Email" v-model="email" required />
      <input type="password" placeholder="Mot de passe" v-model="password" required />
      <button type="submit">Se connecter</button>
    </form>

    <p>Mot de passe oublié? <RouterLink to="/forgot-password">Cliquez ici</RouterLink></p>
    <p>Vous venez d'arriver? <RouterLink to="/signup">S'inscrire</RouterLink></p>

    <div v-if="user">
      <h2>Utilisateur connecté :</h2>
      <pre>{{ user }}</pre>
      <button @click="handleLogout">Déconnecter</button>
    </div>

    <!-- Message d'erreur -->
    <p v-if="errorMessage" style="color:red">{{ errorMessage }}</p>

    <!-- Message de succès -->
    <p v-if="successMessage" style="color:green">{{ successMessage }}</p>
  </div>
</template>

<script>
import { login, getUser, logout } from '../services/Auth';

export default {
  data() {
    return {
      email: '',
      password: '',
      token: '',
      user: null,
      errorMessage: '',
      successMessage: ''
    };
  },
  methods: {
    async handleLogin() {
      try {
        const res = await login(this.email, this.password);
        this.token = res.data.token;
        this.user = res.data.user;

        // Stocker le token
        localStorage.setItem('token', this.token);

        // Message de succès
        this.successMessage = `Bonjour ${this.user.name}, connexion réussie !`;
        this.errorMessage = '';

        // Redirection après 1.5s
        setTimeout(() => {
          this.$router.push('/home');
        }, 500);

      } catch (err) {
        console.log(err); // Debug pour voir exactement la réponse
        // Affiche le message envoyé par Laravel
        this.errorMessage = err.response?.data?.message || 'Erreur inconnue';
        this.successMessage = '';
      }
    },

    async fetchUser() {
      try {
        const token = localStorage.getItem('token');
        if (!token) return;

        const res = await getUser(token);
        this.user = res.data;
      } catch (err) {
        console.error(err.response?.data);
      }
    },

    async handleLogout() {
      try {
        const token = localStorage.getItem('token');
        if (token) {
          await logout(token);
          localStorage.removeItem('token');
          this.user = null;
          this.token = '';
        }
      } catch (err) {
        console.error(err.response?.data);
      }
    }
  },
  mounted() {
    this.fetchUser();
  }
};
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
