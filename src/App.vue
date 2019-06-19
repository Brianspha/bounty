<template>
  <v-app id="inspire">
    <v-navigation-drawer v-model="drawer" :clipped="$vuetify.breakpoint.lgAndUp" fixed app>
      <v-list dense>
        <template v-for="item in items">
          <v-layout v-if="item.heading" :key="item.heading" row align-center>
            <v-flex xs6>
              <v-subheader v-if="item.heading">
                {{ item.heading }}
              </v-subheader>
            </v-flex>
          </v-layout>
          <v-list-group v-else-if="item.children" :key="item.text" v-model="item.model"
            :prepend-icon="item.model ? item.icon : item['icon-alt']" append-icon="">
            <template v-slot:activator>
              <v-list-tile>
                <v-list-tile-content>
                  <v-list-tile-title>
                    {{ item.text }}
                  </v-list-tile-title>
                </v-list-tile-content>
              </v-list-tile>
            </template>
            <v-list-tile v-for="(child, i) in item.children" :key="i" @click="">
              <v-list-tile-action v-if="child.icon" :to="child.to">
                <v-icon>{{ child.icon }}</v-icon>
              </v-list-tile-action>
              <v-list-tile-content>
                <v-list-tile-title>
                  {{ child.text }}
                </v-list-tile-title>
              </v-list-tile-content>
            </v-list-tile>
          </v-list-group>
          <v-list-tile :to="item.to" v-else :key="item.text" @click="">
            <v-list-tile-action>
              <v-icon>{{ item.icon }}</v-icon>
            </v-list-tile-action>
            <v-list-tile-content>
              <v-list-tile-title>
                {{ item.text }}
              </v-list-tile-title>
            </v-list-tile-content>
          </v-list-tile>
        </template>
      </v-list>
    </v-navigation-drawer>
    <v-toolbar :clipped-left="$vuetify.breakpoint.lgAndUp" color="white darken-3" light app fixed>
      <v-toolbar-title style="width: 300px" class="ml-0 pl-3">
        <v-toolbar-side-icon @click.stop="drawer = !drawer"></v-toolbar-side-icon>
        <span class="hidden-sm-and-down">Bounty</span>
      </v-toolbar-title>
      <v-spacer></v-spacer>
      <v-btn icon large>
        <v-avatar size="32px" tile>
          <img src="./images/spiderman.svg">
        </v-avatar>
      </v-btn>
    </v-toolbar>
    <v-btn fab bottom right color="pink" dark fixed @click="dialog = !dialog">
      <v-icon>lock_open</v-icon>
    </v-btn>
    <main>
      <v-content>
        <v-container fluid fill-height>
          <v-layout justify-center align-center>
            <v-flex>
              <router-view></router-view>
            </v-flex>
          </v-layout>
        </v-container>
      </v-content>
    </main>
  </v-app>
</template>

<script>
  import EmbarkJs from "../embarkArtifacts/embarkjs";
  import $ from "jquery";
  import Vue from 'vue';
  export default {
    name: 'app',
    methods: {
      init: async function () {
        EmbarkJs.onReady((err) => {
          this.$log.debug(err)
          this.web3 = EmbarkJS;
          this.BountyContract = require("../embarkArtifacts/contracts/BountyContract").default
        })
      },
      updateBounties() {
        Vue.axios.get("https://api.myjson.com/bins/135rv1").then((response) => {
          this.$log.debug(response.data);
          for (var i = 0; i < response.data.length; i++) {
            let data = response.data[i];
            if (data.poster == "") {
              this.BountyContract.methods.addBounty(this.web3.Utils.fromAscii(data.title),
                this.web3.Utils.fromAscii(data.description), this.web3.Utils.fromAscii(data.title),
                this.web3.Utils.fromAscii(data.category.join()), this.web3.Utils.fromAscii(parseInt(data.endDate)),
                this.web3.Utils.fromAscii(parseInt(data.difficulty))).send({
                value: data.offering
              }).then((val, err) => {
                if (err) {
                  this.$log.debug(err)
                } else {
                  this.$log.debug(val);
                  data.poster = val.from;
                  $.ajax({
                    url: "https://api.myjson.com/bins/135rv1",
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
        })
      }
    },
    mounted() {
      this.init();
      this.updateBounties()
    },
    components: {},
    data: () => ({
      dialog: false,
      drawer: null,
      web3: null,
      BountyContract: null,
      items: [{
          heading: 'Personal'
        },
        {
          icon: 'person_pin',
          text: 'Profile',
          to: "/Profile"
        },
        {
          divider: true
        },
        {
          heading: 'Platform'
        },
        {
          icon: 'image_search',
          text: 'Bounties',
          to: "/Bounties"

        },
        {
          icon: 'add_to_queue',
          text: 'Add Bounty',
          to: "/AddBounty"
        },
        {
          divider: true
        },
        {
          heading: 'Misc'
        },
        {
          icon: 'whatshot',
          text: 'Leaderboard',
          to: "/LeaderBoard"
        },
      ]
    }),
    props: {
      source: String
    }
  }
</script>

<style>
  #app {
    font-family: 'Avenir', Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    text-align: center;
    color: #2c3e50;
  }
</style>