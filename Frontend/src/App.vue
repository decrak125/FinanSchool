<script setup>
import { RouterLink, RouterView } from "vue-router";
</script>

<template>
  <div class="app">
    <header>
      <h1>🌿 Mon Application Vue</h1>
      <nav>
        <RouterLink to="/">Accueil</RouterLink>
        <RouterLink to="/produits">Produits</RouterLink>
      </nav>
    </header>

    <main>
      <!-- Ici s'affichent les pages -->
      <RouterView />
    </main>
  </div>
</template>

<style scoped>
.app {
  font-family: "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  background: #f9f9f9;
  min-height: 100vh;
}

header {
  background: #42b883;
  padding: 1rem;
  text-align: center;
  border-bottom: 3px solid #35495e;
}

h1 {
  color: white;
  margin-bottom: 0.5rem;
}

nav {
  display: flex;
  justify-content: center;
  gap: 1.5rem;
}

nav a {
  text-decoration: none;
  font-weight: bold;
  color: white;
  padding: 0.4rem 0.8rem;
  border-radius: 8px;
  transition: background 0.3s ease;
}

nav a:hover {
  background: rgba(255, 255, 255, 0.2);
}

nav a.router-link-exact-active {
  background: #35495e;
}
main {
  padding: 2rem;
}
</style>
