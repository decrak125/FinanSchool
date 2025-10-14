import Analyse from "@/components/pages/analyses/Dashboard.vue";
import Couts from "@/components/pages/analyses/Couts.vue";
import Profits from "@/components/pages/analyses/Profits.vue";
import Comparaison from "@/components/pages/analyses/Comparaison.vue";
import General from "@/components/pages/indicateurs/General.vue";

export default [
  {
    path: "/analyse",
    name: "Analyse",
    component: Analyse
  },
  {
      path: "/couts",
      name: Couts,
      component: Couts
    },
    {
      path: "/profits",
      name: Profits,
      component: Profits
    },
    {
      path: "/comparatif",
      name: Comparaison,
      component: Comparaison
    },
    {
      path: "/indicateur-general",
      name: General,
      component: General
    }
];
