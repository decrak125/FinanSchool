<template>
  <div class="dashboard">
    <!-- ✅ Message personnalisé -->
    <h1 v-if="user">Bienvenue, {{ user.name }} </h1>
    <h1 v-else>Bienvenue sur le Dashboard</h1>

    <!-- ✅ Bouton de déconnexion -->
    <button @click="logout">Déconnexion</button>
    <button @click="journal">Journal</button>
    <button @click="ecriture">Ecriture</button>
    <button @click="logout">Déconnexion</button>
    <button @click="logout">Déconnexion</button>
    <button @click="logout">Déconnexion</button>
    <button @click="logout">Déconnexion</button>
    <button @click="logout">Déconnexion</button>
  </div>
</template>

<script>
import { getUser } from "../services/Auth"; // vérifie le chemin

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
        this.user = res.data; // ⚠️ ici "res.data" doit contenir "name"
      } else {
        this.$router.push("/");
      }
    } catch (err) {
      console.error(err.response?.data);
      this.$router.push("/");
    }
  },
  methods: {
    logout() {
      localStorage.removeItem("token");
      this.$router.push("/");
    },
     journal() {
      
      this.$router.push("/journal");
    },
    ecriture(){
      
      this.$router.push("/ecriture");
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
