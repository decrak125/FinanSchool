import { createRouter, createWebHistory } from "vue-router";
import Produits from "../views/Produits.vue"; // page Produits
import HelloWorld from "../components/HelloWorld.vue"; // page d'accueil
import Connexion from "../views/Login.vue"; // page de connexion

const routes = [
  {
    path: "/",
    name: "Accueil",
    component: HelloWorld
  },
  {
    path: "/produits",
    name: "Produits",
    component: Produits
  },
  {
    path: "/login",
    name: "Login",
    component: Connexion
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
