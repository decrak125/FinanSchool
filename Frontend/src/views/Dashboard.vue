<!-- Dashboard.vue -->
<template>
  <div class="dashboard-container">
    <!-- Header -->
    <Header />

    <!-- Sidebar -->
    <Sidebar :current-route="$route.path" @navigation-change="handleNavigation" />

    <!-- Main content -->
    <div class="main-content">
      <div class="dashboard">
        <!-- Personalized message -->
        <h1 v-if="user">Bienvenue, {{ user.name }}</h1>
        <h1 v-else>Bienvenue sur le Dashboard</h1>

        <!-- Buttons -->
        <button @click="journal">Journal</button>
        <button @click="ecriture">Écriture</button>
        <button @click="logout">Déconnexion</button>
      </div>

      <!-- Footer -->
      <AppFooter />
    </div>
  </div>
</template>

<script>
import { getUser } from "../services/Auth"; // Verify the path
import Sidebar from "../components/molecules/Sidebar.vue"; // Adjust path if necessary
import Header from "../components/molecules/Header.vue"; // Added Header import
import AppFooter from "../components/molecules/Footer.vue"; // Adjust path if necessary

export default {
  components: {
    Sidebar,
    Header,
    AppFooter,
  },
  data() {
    return {
      user: null,
    };
  },
  async mounted() {
    try {
      const token = localStorage.getItem("token");
      if (token) {
        const res = await getUser(token);
        this.user = res.data; // Ensure res.data contains 'name'
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
    ecriture() {
      this.$router.push("/ecriture");
    },
    handleNavigation(item) {
      this.$router.push(item.route);
    },
  },
};
</script>

<style scoped>
.dashboard-container {
  display: flex;
  min-height: 100vh;
  flex-direction: column;
}

.main-content {
  margin-left: 278px; /* Match sidebar width */
  padding: 32px;
  flex: 1;
  background: #f8fafc; /* Light background for contrast */
  min-height: calc(100vh - 80px); /* Adjust based on footer height */
}

.dashboard {
  max-width: 1200px;
  margin: 0 auto;
}

button {
  background: red;
  color: white;
  border: none;
  padding: 10px 15px;
  border-radius: 5px;
  cursor: pointer;
  margin-right: 10px;
}

button:hover {
  background: darkred;
}

/* Responsive design */
@media (max-width: 768px) {
  .main-content {
    margin-left: 0; /* No sidebar offset on mobile */
    padding: 16px;
  }
}
</style>