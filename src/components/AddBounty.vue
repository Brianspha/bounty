<template>
  <v-form ref="form" v-model="valid" lazy-validation>
    <v-text-field v-model="title" :counter="100" :rules="titleRules" label="Title" required></v-text-field>

    <v-textarea v-model="description" :rules="descriptionRules" label="Description"
      hint="Descrition of what you want done be thorough as possible" required></v-textarea>
    <v-layout wrap align-center>
      <v-flex xs12 sm6 d-flex>
        <v-select :items="difficulty" v-model="selectedDifficulty" label="Difficulty"></v-select>
      </v-flex>
    </v-layout>
    <v-combobox v-model="chips" :items="items" label="Category" chips clearable multiple>
      <template v-slot:selection="data">
        <v-chip :selected="data.selected" close @input="remove(data.item)">
          <strong>{{ data.item }}</strong>&nbsp;
        </v-chip>
      </template>
    </v-combobox>
    <v-text-field v-model="offering" :counter="100" :rules="offeringRules" label="Offering" required></v-text-field>
    <v-checkbox v-model="token" label="Pledge token"></v-checkbox>
    <v-text-field v-if="token" v-model="tokenAddress" :counter="42" :rules="tokenAdressRule" label="Token Address"
      required>
    </v-text-field>

    <v-flex xs12 sm6 md4>
      <v-dialog ref="dialog" :return-value.sync="date" persistent lazy full-width width="290px">
        <template v-slot:activator="{ on }">
          <v-text-field v-model="date" label="Picker in dialog" prepend-icon="event" readonly v-on="on"></v-text-field>
        </template>
        <v-date-picker v-model="date" scrollable>
          <v-spacer></v-spacer>
          <v-btn flat color="primary" @click="modal = false">Cancel</v-btn>
          <v-btn flat color="primary" @click="$refs.dialog.save(date)">OK</v-btn>
        </v-date-picker>
      </v-dialog>
    </v-flex>
    <v-checkbox v-model="checkbox" :rules="[v => !!v || 'You must agree to continue!']"
      label="Agree to terms and conditions?" required></v-checkbox>
    <v-btn :disabled="!valid" color="success" @click="validate">
      Submit
    </v-btn>

    <v-btn color="white" @click="reset">
      Reset Form
    </v-btn>
    <loading :active.sync="isLoading" :can-cancel="false" :is-full-page="fullPage">
    </loading>
  </v-form>
</template>

<script>
  import EmbarkJS from "../../embarkArtifacts/embarkjs";
  import Loading from 'vue-loading-overlay';
  // Import stylesheet
  import 'vue-loading-overlay/dist/vue-loading.css';
  import Swal from 'sweetalert2'
  import SecureLS from 'secure-ls'
/* eslint-disable */
  export default {
    components: {
      Loading
    },
    data: () => ({
      tokenAddress: "",
      token: false,
      valid: true,
      name: '',
      tokenAdressRule: [v => !!v || 'Token address is required and cannot be null',
        v => (v && v.length == 42) || 'Token address must be 42 characters long'
      ],
      titleRules: [
        v => !!v || 'Title is required',
        v => (v && v.length >= 3 && v.length <= 100) ||
        'Title must be greater than 3 characters and less than a 100'
      ],
      descriptionRules: [
        v => !!v || 'Description is required',
        v => (v && v.length >= 20) || 'Description must be greater than 20 characters'
      ],
      offeringRules: [
        v => !!v || 'Offering is required',
        v => (v && parseInt(v) > 0 ) &&!!v.trim() && !isNaN(+v)|| 'Offering must be greater than 0 Eth and must not contain characters'
      ],
      select: null,
      checkbox: false,
      chips: [],
      items: [], //@dev get all available categories on platform,
      date: new Date().toISOString().substr(0, 10),
      title: '',
      description: '',
      offering: '',
      difficulty: ['Begginner', 'Intermediate', 'Hard', 'Extreme'],
      web3: null,
      BountyContract: null,
      selectedDifficulty: null,
      isLoading: false,
      fullPage: true,
      address: "",
      SecureLS: new SecureLS()
    }),
    mounted() {
      this.init()
    },
    methods: {
      validCategoryItemLenght() {
        return this.chips.filter((chip) => {
          return (chip.length > 15)
          console.log(chip.length>0,chip)
        }).length>0
      },
      validate() {
        if (this.$refs.form.validate()) {
          if (new Date(this.date).getTime() < new Date().getTime()) {
            this.error("Date has to be a later date than today")
            return
          }            
          this.isLoading = true;
          this.snackbar = true
          if (this.token) {
            if (this.validCategoryItemLenght()) {
              this.error("Invalid Category item please ensure that each item has at most 15 characters")
              this.isLoading = false;
              return
            }
            this.BountyContract.methods.addBountyOfferToken(
              this.web3.Utils.fromAscii(this.title),
              this.web3.Utils.fromAscii(this.description),
              this.web3.Utils.fromAscii(this.chips.join()),
              new Date(this.date).getTime(),
              this.difficultyToInt(this.selectedDifficulty), this.tokenAddress, this.offering).send({
              gas: 8000000
            }).then((val, err) => {
              if (err) {
                this.error("OH no something went wrong wont you try again :D")
              } else {
                this.success(
                  "Successfully submitted Bounty please see if it appears under the bounties section of the platform"
                )
                let id = val.events.bountyIdLogger.returnValues.Id
                this.address =
                  this.updateBounties(this.title, this.description, this.chips, new Date(this.date).getTime(), this
                    .selectedDifficulty, this.offering, id)
              }
              this.isLoading = false;

            }).catch((err) => {
              console.log(err)
              this.isLoading = false;
            });
          } else {
            if (this.validCategoryItemLenght()) {
              this.error("Invalid Category item please ensure that each item has at most 15 characters")
              this.isLoading = false;
              return
            }
            this.BountyContract.methods.addBounty(
              this.web3.Utils.fromAscii(this.title),
              this.web3.Utils.fromAscii(this.description),
              this.web3.Utils.fromAscii(this.chips.join()),
              new Date(this.date).getTime(),
              this.difficultyToInt(this.selectedDifficulty)).send({
              value: this.offering,
              gas: 8000000
            }).then((val, err) => {
              if (err) {
                this.error("OH no something went wrong wont you try again :D")
              } else {
                this.success(
                  "Successfully submitted Bounty please see if it appears under the bounties section of the platform"
                )
                let id = val.events.bountyIdLogger.returnValues.Id
                this.updateBounties(this.title, this.description, this.chips, new Date(this.date).getTime(), this
                  .selectedDifficulty, this.offering, id)
              }
              this.isLoading = false;

            }).catch((err) => {
              this.error("You seem to have cancelled the transaction wont you try again? :D")
              this.isLoading = false;
            });
          }
        }

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

      init: async function () {
        EmbarkJS.onReady((err) => {
          this.web3 = EmbarkJS;
          this.BountyContract = require("../../embarkArtifacts/contracts/BountyContract").default
        })
      },
      reset() {
        this.$refs.form.reset()
      },
      resetValidation() {
        this.$refs.form.resetValidation()
      },
      remove(item) {
        this.chips.splice(this.chips.indexOf(item), 1)
        this.chips = [...this.chips]
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
        Swal.fire(
          'Success',
          message,
          'success'
        )
      },
      updateBounties(title, description, categories, endDate, difficulty, offering, id) {
        let req = new XMLHttpRequest();
        req.onreadystatechange = () => {
          if (req.readyState == XMLHttpRequest.DONE) {
            let response = JSON.parse(req.responseText)
            response.push({
              "title": title,
              "description": description,
              "endDate": endDate,
              "offering": offering,
              "difficulty": difficulty,
              "category": categories,
              "submissions": 0,
              "fiat": Math.floor(Math.random() * 5000000),
              "poster": this.getAddress(),
              "stage": "Active",
              "winner": "",
              "indispute": [
                false,
                [

                ]
              ],
              "hunterAddresses": [

              ],
              "solutionHashes": [

              ],
              "id": id,
              "paused": false
            })
            let post = new XMLHttpRequest()
            post.onreadystatechange = () => {
              if (post.readyState == XMLHttpRequest.DONE) {}
            };
            post.open("PUT", "https://api.myjson.com/bins/13mpql", true)
            post.setRequestHeader("Content-type", "application/json")
            post.send(JSON.stringify(response));

          };

        }
        req.open("GET", "https://api.myjson.com/bins/13mpql", true);
        req.send();
      },
      getLoggedIn() {
        return this.SecureLS.get("loggedIn")
      },
      getAddress() {
        return this.SecureLS.get("address")
      }
    }
  }
</script>