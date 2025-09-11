import { createApp } from "vue";
import App from "./App.vue";
import router from "./router";
// Import Bootstrap Icons
import 'bootstrap-icons/font/bootstrap-icons.css'
createApp(App)
  .use(router)
  .mount("#app");
