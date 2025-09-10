<template>
  <div class="dashboard">
    <h1>Tableau de bord</h1>

    <p v-if="user">
      👋 Bonjour <strong>{{ user.name }}</strong>, bienvenue sur ton tableau de bord !
    </p>

    <p v-else>
      Chargement de vos informations...
    </p>
  </div>
</template>

<script>
import { getUser } from "../services/Auth";

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
  }
};
</script>

<style scoped>
.dashboard {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 80px;
  font-size: 20px;
}
</style>
