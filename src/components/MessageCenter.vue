<template>
    <v-container grid-list-md text-xs-center id="messageCenter">
        <v-flex xs12 v-if="Show">
            <v-flex xs12>
                <v-card dark color="white" class="black--text" v-for="message in Messages">
                    <v-card-title primary-title>
                        {{message.Title}}
                    </v-card-title>
                    <v-card-actions>
                        Number of Solutions {{message.Meesage}}
                    </v-card-actions>
                    <v-card-actions>
                        {{message.NewSolutions}}
                    </v-card-actions>
                </v-card>
            </v-flex>
        </v-flex>
    </v-container>
</template>

<script>
    import MugenScroll from 'vue-mugen-scroll'
    import Multiselect from 'vue-multiselect'
    import InfiniteLoading from 'vue-infinite-loading';
    import Vue from 'vue';
    import EmbarkJS from "../../embarkArtifacts/embarkjs";
    import {
        async
    } from 'q';
    import 'vue-loading-overlay/dist/vue-loading.css';
    import Swal from 'sweetalert2'
    import SecureLS from 'secure-ls'
    import Loading from 'vue-loading-overlay';
    import {
        setTimeout
    } from 'timers';
    import MagicGrid from "magic-grid"

    export default {
        name: "Bounties",
        data() {
            return {
                isLoading: false,
                fileUploadDialogue: false,
                dialog: false,
                Postedbounties: [],
                loading: false,
                Categoryvalue: null,
                Stagevalue: null,
                Sortvalue: null,
                Difficultyvalue: null,
                Difficulties: ['Defualt', 'Begginner', 'Intermediate', 'Hard', 'Extreme'],
                Stage: ["Active", "Completed", "Dead"],
                Sort: ["Defualt", "Expiry", "Value:Low to High", "Value:High to Low"],
                Category: ["Defualt"],
                loggedIn: false,
                descriptionDialogue: false,
                description: "No desription",
                defualtPostedBounties: [],
                solutionText: "",
                selectedBounty: null,
                address: "",
                SecureLS: new SecureLS(),
                fullPage: true,
                Show: true,
                Messages: []
            }
        },
        mounted() {
            this.init()
            this.getBounties()
        },
        methods: {
            init: async function () {
                this.web3 = EmbarkJS;
                this.BountyContract = require("../../embarkArtifacts/contracts/BountyContract").default
                this.loggedIn = this.getLoggedIn()
                this.address = this.getAddress()
            },
            getBounties() {
                let req = new XMLHttpRequest();
                let tempThis = this
                let magicGrid = new MagicGrid({
                    container: "#messageCenter",
                    items: 30,
                    animate: true
                })
                req.onreadystatechange = () => {
                    if (req.readyState == XMLHttpRequest.DONE) {
                        let response = JSON.parse(req.responseText)
                        if (response.length == 1) {} else {

                            for (var index = 1; index < response.length; index++) {
                                var data = response[index]
                                if (data.indispute[0] && data.poster == this.address) {
                                    this.Messages.push({
                                        Title: data.title,
                                        NewSolutions: data.solutionHashes.length,
                                        Message: "Bounty Currently in Dispute Please see to resolve it"
                                    })
                                }
                                console.log(this.Messages)
                            }
                        }
                    };
                }
                req.open("GET", "https://api.myjson.com/bins/w1l6d", true);
                req.send();
            },
            daysRemaining(time) {
                var date_future = new Date(new Date(time).getFullYear() + 1, 0, 1);
                var date_now = new Date();
                var seconds = Math.floor((date_future - (date_now)) / 1000);
                var minutes = Math.floor(seconds / 60);
                var hours = Math.floor(minutes / 60);
                var days = Math.floor(hours / 24);
                return days
            },
            exists(array1, array2) {
                array1.forEach(item => {
                    array2.forEach(value => {
                        if (item == value) {
                            return true;
                        }
                    })
                })
            },
            getLoggedIn() {
                return this.SecureLS.get("loggedIn")
            },
            getAddress() {
                return this.SecureLS.get("address")
            }
        },
        components: {
            MugenScroll,
            Multiselect,
            InfiniteLoading,
            Loading,
            MagicGrid
        }
    }
</script>
<style scoped>
    #listParent {
        min-width: 100%;
    }

    .resultContainer {
        height: 350px;
    }

    .item {
        min-height: 50px;
        min-width: 80px;
        margin: 10px;
    }

    v-card {
        color: black;
    }

    v-icon {
        color: black;
    }

    v-dialog v-dialog--active {
        max-width: 400px;
        height: 8000px;
    }
</style>
<style src="vue-multiselect/dist/vue-multiselect.min.css"></style>