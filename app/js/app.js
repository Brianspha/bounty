import EmbarkJS from '../../embarkArtifacts/embarkjs';
import {
  BountyContract
} from '../../embarkArtifacts/contracts/Bounty';
import Vue from 'vue'
import App from './App.vue'
import Vuetify from 'vuetify'
import 'vuetify/dist/vuetify.min.css' // Ensure you are using css-loader
import router from "./router"
import VueAxios from 'vue-axios'
import axios from 'axios'
import VueAsyncData from "vue-async-data";
import $ from "jquery";
Vue.use(VueAsyncData)
Vue.use(VueAxios, axios)
Vue.use(Vuetify)
Vue.config.productionTip = false

EmbarkJS.onReady((err) => {
  console.log(BountyContract)
  console.log(err);
  console.log(EmbarkJS)
  Vue.axios.get("https://api.myjson.com/bins/ae01x").then((response) => {
    console.log(response.data);
    for (var i = 0; i < response.data.length; i++) {
      let data = response.data[i];
      if (data.poster == "") {
        BountyContract.methods.addBounty(EmbarkJS.Utils.fromAscii(data.title),
          EmbarkJS.Utils.fromAscii(data.description), EmbarkJS.Utils.fromAscii(data.title),
          EmbarkJS.Utils.fromAscii(data.category.join()), EmbarkJS.Utils.fromAscii(parseInt(data.endDate)),
          EmbarkJS.Utils.fromAscii(parseInt(data.difficulty))).send({
          value: data.offering
        }).then((val, err) => {
          if (err) {
            console.log(err)
          } else {
            console.log(val);
            data.poster = val.from;
            $.ajax({
              url: "https://api.myjson.com/bins/ae01x",
              type: "PUT",
              data: data,
              contentType: "application/json; charset=utf-8",
              dataType: "json",
              success: function (data, textStatus, jqXHR) {}
            });
          }
        })
      }
    }
  });
  new Vue({
    render: h => h(App),
    router
  }).$mount('#app')
})
