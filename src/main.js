import Vue from 'vue'
import App from './App.vue'
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css' // Ensure you are using css-loader
import router from "./router"
import VueAxios from 'vue-axios'
import axios from 'axios'
import VueAsyncData from "vue-async-data";
Vue.use(VueAsyncData)
Vue.use(VueAxios, axios)
Vue.use(Vuetify)
Vue.config.productionTip = false
new Vue({
  render: h => h(App),
  router
}).$mount('#app')