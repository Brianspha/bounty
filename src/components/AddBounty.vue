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
    <loading :active.sync="isLoading" :can-cancel="true" :on-cancel="onCancel" :is-full-page="fullPage" :loader="bars">
    </loading>
  </v-form>
</template>

<script>
  import EmbarkJs from "../../embarkArtifacts/embarkjs";
  import Loading from 'vue-loading-overlay';
  // Import stylesheet
  import 'vue-loading-overlay/dist/vue-loading.css';
  import Swal from 'sweetalert2'

  export default {
    components: {
      Loading
    },
    data: () => ({
      valid: true,
      name: '',
      titleRules: [
        v => !!v || 'Title is required',
        v => (v && v.length >= 3) || 'Title must be greater than 3 characters'
      ],
      descriptionRules: [
        v => !!v || 'Description is required',
        v => (v && v.length >= 20) || 'Description must be greater than 20 characters'
      ],
      offeringRules: [
        v => !!v || 'Offering is required',
        v => (v && parseInt(v) > 0) || 'Offering must be greater than 0 Eth'
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
      isLoading: false
    }),
    mounted() {
      this.init()
    },
    methods: {
      validate() {
        if (this.$refs.form.validate()) {
          this.isLoading = true;
          this.snackbar = true
          this.$log.debug(this.selectedDifficulty)
          this.BountyContract.methods.addBounty(this.web3.Utils.fromAscii(this.title),
            this.web3.Utils.fromAscii(this.description),
            this.web3.Utils.fromAscii(this.chips.join()), new Date(this.date).getTime(), this.difficultyToInt(this
              .selectedDifficulty)).send({
            value: this.offering,
            gas: 5000000
          }).then((val, err) => {
            if (err) {
              this.$log.debug(err)
              this.error("OH no something went wrong wont you try again :D")
            } else {
              this.success("Successfully submitted Bounty please see if it appears under the bounties section of the platform")
              this.$log.debug(val)
            }
            this.isLoading = false;

          });
        }
        this.$log.debug(this.web3)
        this.$log.debug("date: " + this.date.toString())
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
        EmbarkJs.onReady((err) => {
          this.$log.debug(err)
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
          text: 'Something went wrong!',
          allowOutsideClick: true
        })
      },
      success(message) {
        Swal.fire(
          'Success',
          message,
          'success'
        )
      }
    }
  }
</script>