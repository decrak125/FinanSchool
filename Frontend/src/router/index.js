import { createRouter, createWebHistory } from "vue-router";
import Produits from "../views/Produits.vue"; // page Produits
import HelloWorld from "../components/HelloWorld.vue"; // page d'accueil

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
  }
];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
