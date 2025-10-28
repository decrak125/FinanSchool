import Analyse from "@/components/pages/analyses/Dashboard.vue";
import Couts from "@/components/pages/analyses/Couts.vue";
import Profits from "@/components/pages/analyses/Profits.vue";
import Comparaison from "@/components/pages/analyses/Comparaison.vue";
import General from "@/components/pages/indicateurs/General.vue";
import Liquidite from "@/components/pages/indicateurs/Liquidite.vue";
import Solvabilite from "@/components/pages/indicateurs/Solvabilite.vue";
import Rentabilite from "@/components/pages/indicateurs/Rentabilite.vue";
import NonAffected from "@/components/pages/configAnalytique/NonAffected.vue";

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
    },
    {
      path: "/indicateur-liquidite",
      name: Liquidite,
      component: Liquidite
    },
    {
      path: "/indicateur-solvabilite",
      name: Solvabilite,
      component: Solvabilite
    },
    {
      path: "/indicateur-rentabilite",
      name: Rentabilite,
      component: Rentabilite
    },
    {
      path: "/non-affected",
      name: NonAffected,
      component: NonAffected
    }
];
