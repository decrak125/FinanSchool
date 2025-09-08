import { createRouter, createWebHistory } from "vue-router";
import Produits from "../views/Produits.vue"; // page Produits
import HelloWorld from "../components/HelloWorld.vue"; // page d'accueil
import Connexion from "../views/Login.vue"; // page de connexion
import ForgotPassword from "@/views/ForgotPassword.vue";
import ResetPassword from "@/views/ResetPassword.vue";

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
  },
  {
    path: "/forgot-password",
    name: "ForgotPassword",
    component: ForgotPassword
  },
  {
    path: "/reset-password",
    name: "ResetPassword",
    component: ResetPassword
  }

];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
