<template>
  <v-form ref="form" v-model="valid" lazy-validation>
    <v-text-field v-model="title" :counter="100" :rules="titleRules" label="Title" required></v-text-field>

    <v-textarea v-model="description" :rules="descriptionRules" label="Description"
      hint="Descrition of what you want done be thorough as possible" required></v-textarea>
    <v-layout wrap align-center>
      <v-flex xs12 sm6 d-flex>
        <v-select :items="difficulty" label="Difficulty"></v-select>
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
  </v-form>
</template>

<script>
  import Vue from 'vue';
  import {
    BountyContract
  } from "../../../embarkArtifacts/contracts/BountyContract";
  import { web3 } from "../../../embarkArtifacts/embarkjs";
  export default {
    data: () => ({
      valid: true,
      name: '',
      titleRules: [
        v => !!v || 'Title is required',
        v => (v && v.length >= 3) || 'Title must be greater than 3 characters'
      ],
      description: '',
      descriptionRules: [
        v => !!v || 'Description is required',
        v => (v && v.length >= 20) || 'Description must be greater than 20 characters'
      ],
      offeringRules: [
        v => !!v || 'Offering is required',
        v => (v && parseInt(v) > 0) || 'Offering must be greater than 0 Eth'
      ],
      select: null,
      items: [
        'Item 1',
        'Item 2',
        'Item 3',
        'Item 4'
      ],
      checkbox: false,
      chips: [],
      items: [], //@dev get all available categories on platform,
      date: new Date().toISOString().substr(0, 10),
      title: '',
      description: '',
      offering: '',
      difficulty: ['Begginner', 'Intermediate', 'Hard', 'Extreme'],
      web3:web3
    }),

    methods: {
      validate() {
        if (this.$refs.form.validate()) {
          this.snackbar = true
          console.log(this.web3)
          //BountyContract.methods.addBounty(web3.utils.fromAscii(this.title),web3.utils.fromAscii(this.description),web3.utils.fromAscii(this.chips.join()),this.offering,this.difficulty);

        }
          console.log(this.web3)
        console.log("date: " + this.date.toString())

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
    }
  }
</script>