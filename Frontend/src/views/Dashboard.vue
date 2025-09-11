<template>
  <div class="dashboard">
    <h1>Bonjour <strong>{{ user.name }}</strong>, bienvenue sur ton tableau de bord !</h1>

    <!-- Ton ancien code est gardé -->

    <!-- ✅ Bouton de déconnexion ajouté -->
    <button @click="logout">Déconnexion</button>
  </div>
</template>

<script>
import { getUser } from "../services/Auth"; // si tu utilises ce service

export default {
  data() {
    return {
      user: null
    };
  },
  async mounted() {
    try {
      const token = localStorage.getItem("token");
      if (token) {
        const res = await getUser(token);
        this.user = res.data;
      } else {
        // pas de token → retour à login
        this.$router.push("/");
      }
    } catch (err) {
      console.error(err.response?.data);
      this.$router.push("/");
    }
  },
  methods: {
    logout() {
      // Supprimer le token
      localStorage.removeItem("token");

      // Rediriger vers login
      this.$router.push("/");
    }
  }
};
</script>

<style scoped>
button {
  background: red;
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 5px;
  cursor: pointer;
}
button:hover {
  background: darkred;
}
</style>
