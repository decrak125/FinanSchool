import { createRouter, createWebHistory } from "vue-router";
import Produits from "../views/Produits.vue"; // page Produits
import Dashboard from "../views/Dashboard.vue"; // page Dashboard
import HelloWorld from "../components/HelloWorld.vue"; // page d'accueil
import Login from "@/components/pages/Login.vue";
import ForgotPassword from "@/components/pages/ForgotPassword.vue";
import ResetPassword from "@/components/pages/ResetPassword.vue";
import Register from "@/components/pages/Register.vue";

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
  }

];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
