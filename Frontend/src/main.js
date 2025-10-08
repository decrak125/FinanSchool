import { createApp } from "vue";
import App from "./App.vue";
import router from "./router";
import '../src/assets/styles/style.css'
// Import Bootstrap Icons
import 'bootstrap-icons/font/bootstrap-icons.css'
import VueApexCharts from "vue3-apexcharts";
createApp(App)
  .use(router)
  .use(VueApexCharts)
  .mount("#app");
