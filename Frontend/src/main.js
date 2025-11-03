import './echo.js'
import { createPinia } from 'pinia'
import { createApp } from "vue";
import './echo';
import App from "./App.vue";
import router from "./router";
import '../src/assets/styles/style.css'
// Import Bootstrap Icons
import 'bootstrap-icons/font/bootstrap-icons.css'
import VueApexCharts from "vue3-apexcharts";
createApp(App)
  .use(createPinia())
  .use(router)
  .use(VueApexCharts)
  .mount("#app");
