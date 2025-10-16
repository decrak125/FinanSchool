import { createRouter, createWebHistory } from "vue-router";
import Produits from "../views/Produits.vue"; // page Produits
import Dashboard from "../views/Dashboard.vue"; // page Dashboard
import HelloWorld from "../components/HelloWorld.vue"; // page d'accueil
import Login from "@/components/pages/users/Login.vue";
import ForgotPassword from "@/components/pages/users/ForgotPassword.vue";
import ResetPassword from "@/components/pages/users/ResetPassword.vue";
import Register from "@/components/pages/users/Register.vue";
import Compte from "@/components/pages/configuration/Compte.vue";
import SousCompte from "@/components/pages/configuration/SousCompte.vue";
import Rubrique from "@/components/pages/configuration/Rubrique.vue";
import TypeJournal from "@/components/pages/configuration/TypeJournal.vue";
import Devise from "@/components/pages/configuration/Devise.vue";
import Journal from "@/components/pages/configuration/Journal.vue";
import ModePaiement from "@/components/pages/configuration/ModePaiement.vue";
import Ecriture from "@/components/pages/saisie/Ecriture.vue";
import TypeCentre from "@/components/pages/configAnalytique/TypeCentre.vue";
import AxeAnalytique from "@/components/pages/configAnalytique/AxeAnalytique.vue";
import CentreAnalytique from "@/components/pages/configAnalytique/CentreAnalytique.vue";
import AffectationAnalytique from "@/components/pages/configAnalytique/AffectationAnalytique.vue";
import CoutsEtProfits from "@/components/pages/analyses/Couts.vue";
import EcritureJournal from "@/components/pages/configuration/EcritureJournal.vue";
import ListeGrandLivre from "@/components/pages/saisie/ListeGrandLivre.vue";
import GrandLivre from "@/components/pages/saisie/GrandLivre.vue";
import Balance from "@/components/pages/general/Balance.vue";
import ModuleChoice from "@/views/ModuleChoice.vue";
import AnalyseRoutes from "./routesAnalyse.js";
import CRNature from "@/components/pages/general/CRNature.vue";
import CRFonction from "@/components/pages/general/CRFonction.vue";

const routes = [
  {
    path: "/",
    name: "Login",
    component: Login
  },
  ...AnalyseRoutes,
  {
    path: "/produits",
    name: "Produits",
    component: Produits
  },
    
  {
    path: "/home",
    name: "Home",
    component: ModuleChoice
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
  },
  {
    path: "/souscompte",
    name: "SousCompte",
    component: SousCompte
  },
  {
    path: "/rubrique",
    name: "Rubrique",
    component: Rubrique
  },
  {
    path: "/type-journal",
    name: TypeJournal,
    component: TypeJournal
  },
  {
    path: "/devise",
    name: Devise,
    component: Devise
  },
  {
    path: "/journal",
    name: Journal,
    component: Journal
  },

  {
      path: "/paiement-mode",
      name: ModePaiement,
      component: ModePaiement
  },
  {
    path: "/ecriture",
    name: Ecriture,
    component: Ecriture
  },
  // analytique

{
    path: "/type-centre",
    name: TypeCentre,
    component: TypeCentre
  },
  {
    path: "/axe-analytique",
    name: AxeAnalytique,
    component: AxeAnalytique
  },
  {
    path: "/centre-analytique",
    name: CentreAnalytique,
    component: CentreAnalytique
  },
  {
    path: "/affectation-analytique",
    name: AffectationAnalytique,
    component: AffectationAnalytique
  },
  {
    path: "/couts-et-profits",
    name: CoutsEtProfits,
    component: CoutsEtProfits
  },
  {
    path:"/ecritures-journal/:id",
    name: EcritureJournal,
    component: EcritureJournal,
    props: true,
  },
  {
    path:"/liste-grand-livre",
    name: "ListeGrandLivre",
    component: ListeGrandLivre
  },
  {
    path:"/grand-livres/:codeCompte",
    name: "GrandLivre",
    component: GrandLivre,
    props: true,
  },
  {
    path:"/balance",
    name: "Balance",
    component: Balance
  },
  {
    path: "/CR-Nature",
    name : "CR-Nature",
    component : CRNature
  },

  {
    path: "/CR-Fonction",
    name : "CR-Fonction",
    component : CRFonction
  }




];

const router = createRouter({
  history: createWebHistory(),
  routes
});

export default router;
