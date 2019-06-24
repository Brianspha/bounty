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
            <v-list-tile v-for="(child, i) in item.children" :key="i">
              <v-list-tile-action v-if="child.render &&child.icon" :to="child.to">
                <v-icon>{{ child.icon }}</v-icon>
              </v-list-tile-action>
              <v-list-tile-content v-if="child.render">
                <v-list-tile-title>
                  {{ child.text }}
                </v-list-tile-title>
              </v-list-tile-content>
            </v-list-tile>
          </v-list-group>
          <v-list-tile :to="item.to" v-else :key="item.text">
            <v-list-tile-action v-if="item.render">
              <v-icon>{{ item.icon }}</v-icon>
            </v-list-tile-action>
            <v-list-tile-content>
              <v-list-tile-title v-if="item.render">
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
        <v-avatar size="32px" tile @click="toHomepage()">
          <img src="./images/spiderman.svg">
        </v-avatar>
      </v-btn>
    </v-toolbar>
    <v-btn fab bottom right color="pink" dark fixed @click="logOut()">
      <v-icon>lock_open</v-icon>
    </v-btn>
    <v-btn fab bottom left color="pink" dark fixed @click="logIn()">
      <v-icon>lock</v-icon>
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
    <loading :active.sync="isLoading" :can-cancel="false" :is-full-page="fullPage">
    </loading>
  </v-app>
</template>

<script>
  import EmbarkJS from "../embarkArtifacts/embarkjs";
  import Swal from 'sweetalert2'
  import SecureLS from 'secure-ls'
  import Vue from 'vue'
  import Loading from 'vue-loading-overlay';
  // Import stylesheet
  import 'vue-loading-overlay/dist/vue-loading.css';
  import Snotify from 'vue-snotify'; // 1. Import Snotify
  Vue.use(Snotify)

  export default {
    name: 'app',
    components: {
      Loading
    },
    data: () => ({
      dialog: false,
      drawer: null,
      web3: null,
      isLoading: false,
      fullPage: true,
      BountyContract: null,
      items: [{
          heading: 'Platform',
          render: true
        },
        {
          icon: 'image_search',
          text: 'Bounties',
          to: "/Bounties",
          render: true

        },
        {
          icon: 'whatshot',
          text: 'Rankings',
          to: "/Rankings",
          render: true

        }

      ],
      loggedIn: false,
      SecureLS: new SecureLS(),
      canLogin: false
    }),
    beforeMount() {},
    mounted() {

      this.init();
    },
    watch: {
      loggedIn: function () {
        this.$forceUpdate()
      }
    },
    methods: {
      toHomepage() {
        location.replace("/")
      },
      difficultyToInt(stringDifficulty) {
        switch (stringDifficulty) {
          case "Begginner":
            return 1;
          case "Intermediate":
            return 2;
          case "Hard":
            return 3;
          case "Extreme":
            return 4;
        }
      },
      error(message) {
        Swal.fire({
          type: 'error',
          title: 'Oops...',
          text: message,
          allowOutsideClick: true
        })
      },
      success(message) {
        this.$snotify.success(message, {
          timeout: 2000,
          showProgressBar: false,
          closeOnClick: false,
          pauseOnHover: true
        })
      },
      logOutMessage(message) {
        this.$snotify.info(message, {
          timeout: 2000,
          showProgressBar: false,
          closeOnClick: false,
          pauseOnHover: true
        })
      },
      init: async function () {
        EmbarkJS.onReady((err) => {
          if (err) {
            this.errorWithFooter(
              "<a href='https://metamask.io/;';>Please visit their website for instructions of how to download it</a>",
              'MetaMask is not installed!'
            )
            this.setLoggedIn(false, null)
          } else {
            this.canLogin = true
            this.web3 = EmbarkJS;
            if (this.getLoggedIn()) {
              this.initialiseUserData()
            }
            this.BountyContract = require("../embarkArtifacts/contracts/BountyContract").default
            this.watchForAccountChanges()
          }
        })

      },
      watchForAccountChanges() {
        let tempThis = this
        window.ethereum.on('accountsChanged', function (accounts) {
          tempThis.logOut()
        })
        window.ethereum.on('networkChanged', function (netId) {
          tempThis.logOut()
        })
        window.ethereum.on('networkChanged', function (netId) {
          tempThis.logOut()
        })
      },
      errorWithFooter(footerMessage, text) {
        Swal.fire({
          type: 'error',
          title: 'OH Noo',
          text: text,
          footer: footerMessage
        })
      },
      setDefualt() {
        this.items.push({
          icon: 'add_to_queue',
          text: 'Add Bounty',
          to: "/AddBounty",
          render: this.getLoggedIn(),
        })
        this.items.push({
          divider: true
        })
        this.items.push({
          heading: 'Personal',
          render: this.getLoggedIn()

        })
        this.items.push({
          icon: 'person_pin',
          text: 'Added Bounties',
          to: "/CreatedBounties",
          render: this.getLoggedIn()
        })
        this.items.push({
          icon: 'build',
          text: 'View Solutions to Created Bounties',
          to: "/createdbountysolutions",
          render: this.getLoggedIn()
        })
        this.items.push({
          icon: 'query_builder',
          text: 'Resolve Added Bounties',
          to: "/Disputes",
          render: this.getLoggedIn()
        })
        this.items.push({
          icon: 'report_problem',
          text: 'Pending Bounties',
          to: "/PendingBounties",
          render: this.getLoggedIn()
        })
     this.items.push({
          icon: 'done_all',
          text: 'View Completed Bounties',
          to: "/HuntedBounties",
          render: this.getLoggedIn()
        })
      },
      registerUser() {
        let tempThis = this;
        this.isLoading = true
        this.BountyContract.methods.userExists().call({
          gas: 8000000
        }).then(function (val, err) {
          if (err) {
            console.log(err)
            tempThis.initialiseUserData()
          } else if (!val) {
            tempThis.registerNewUser()
          } else {
            tempThis.initialiseUserData()
            tempThis.isLoading = false
            location.replace("/")

          }

        }).catch((err) => {
          this.error("Something went wrong for the following reasons You cancelled the transaction ")
          this.isLoading = true

        })
      },
      initialiseUserData() {
        if (!this.getLoggedIn()) {
          this.setLoggedIn(true, web3.eth.defaultAccount)
        }
        this.setDefualt()
      },
      registerNewUser() {
        this.BountyContract.methods.registerUser().send({
          gas: 8000000
        }).then(function (val, err) {
          if (!err) {
            tempThis.initialiseUserData()
            this.isLoading = false
            location.replace("/")
          }
        }).catch((err) => {
          this.error(
            "Something went wrong for the following reasons You cancelled the transaction You currently suspended for bad behaviour on the platform"
          )
          this.isLoading = false
          location.reload()
        })
      },
      resetItems() {
        this.SecureLS.removeAll()
        this.items = []
        this.items.push({
          heading: 'Platform'
        }, {
          icon: 'image_search',
          text: 'Bounties',
          to: "/Bounties",
          render: true
        }, {
          icon: 'whatshot',
          text: 'Rankings',
          to: "/Rankings",
          render: true

        })
        this.loggedIn = false
        location.replace("/")
      },
      setLoggedIn(bool, address) {
        this.SecureLS.set('loggedIn', bool);
        this.SecureLS.set('address', address)
      },
      getLoggedIn() {
        return this.SecureLS.get("loggedIn")
      },
      getAddress() {
        return this.SecureLS.get("address")
      },
      logOut() {
        this.resetItems()
      },
      logIn() {
        if (!this.getLoggedIn() && this.canLogin) {
          this.registerUser()
        }
      },
      rerender() {}
    },
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

  .wrapText {
    overflow-wrap: break-word;
    word-wrap: break-word;
  }
</style>