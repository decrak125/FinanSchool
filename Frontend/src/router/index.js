import { createRouter, createWebHistory } from "vue-router";
import Produits from "../views/Produits.vue"; // page Produits
import Dashboard from "../views/Dashboard.vue"; // page Dashboard
import HelloWorld from "../components/HelloWorld.vue"; // page d'accueil
import Login from "@/components/pages/users/Login.vue";
import ForgotPassword from "@/components/pages/users/ForgotPassword.vue";
import ResetPassword from "@/components/pages/users/ResetPassword.vue";
import Register from "@/components/pages/users/Register.vue";
import Compte from "@/components/pages/configuration/Compte.vue";

const routes = [
  {
    path: "/",
    name: "Login",
    component: Login
  },
  {
    path: "/produits",
    name: "Produits",
    component: Produits
  },
    
    
  {
    path: "/dashboard",
    name: "Dashboard",
    component: Dashboard
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
  },
  {
    path: "/signup",
    name: "Register",
    component: Register
  },
  {
    path: "/compte",
    name: "Compte",
    component: Compte
  }


];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
