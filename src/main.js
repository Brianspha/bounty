import EmbarkJS from '../embarkArtifacts/embarkjs';

import Vue from 'vue'
import App from './App.vue'
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css' // Ensure you are using css-loader
import router from "./router"
import VueAxios from 'vue-axios'
import axios from 'axios'
import VueAsyncData from "vue-async-data";
import VueLogger from 'vuejs-logger';
const isProduction = process.env.NODE_ENV === 'production';
Vue.use(VueAsyncData)
Vue.use(VueAxios, axios)
Vue.use(Vuetify)
Vue.config.productionTip = false


const options = {
  isEnabled: true,
  logLevel: isProduction ? 'error' : 'debug',
  stringifyArguments: false,
  showLogLevel: true,
  showMethodName: true,
  separator: '|',
  showConsoleColors: true
};

Vue.use(VueLogger, options);
EmbarkJS.onReady(() => {
  new Vue({
    render: h => h(App),
    router
  }).$mount('#app')
})