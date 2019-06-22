<template>
    <v-container grid-list-md text-xs-center>
        <v-layout align-space-between justify-start column fill-height>
            <v-btn color="white" light @click.stop="dialog = true"> Filter</v-btn>
            <v-layout align-center justify-center row fill-height>
                <v-dialog v-model="dialog">
                    <v-card v-if="dialog" app-data="true" id="increaseHeight">
                        <v-card-title class="headline">Refine By</v-card-title>
                        <v-container fluid grid-list-xl>
                            <v-layout wrap align-center>
                                <v-flex xs12 sm6 d-flex>
                                    <v-select v-model="Sortvalue" :items="Sort" label="Sort">
                                    </v-select>
                                </v-flex>
                                <v-flex xs12 sm6 d-flex>
                                    <v-select v-model="Difficultyvalue" :items="Difficulties" label="Difficulty">
                                    </v-select>
                                </v-flex>
                            </v-layout>
                        </v-container>
                        <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn color="white" light @click="dialog = false">
                                Close
                            </v-btn>
                        </v-card-actions>
                    </v-card>

                </v-dialog>
                <v-dialog v-model="descriptionDialogue">
                    <v-card>
                        <v-container fluid>
                            <v-layout wrap>
                                <v-flex xs12>
                                    <v-card-title class="headline">Description</v-card-title>
                                    <v-card-text>
                                        {{description}}
                                    </v-card-text>
                                    <v-card-actions>
                                        <v-spacer></v-spacer>
                                        <v-btn color="primary" flat @click="descriptionDialogue = false">
                                            Close </v-btn>
                                    </v-card-actions>
                                </v-flex>
                            </v-layout>
                        </v-container>
                    </v-card>
                </v-dialog>
            </v-layout>
            <v-flex v-for="bounty in filterBounties" xs12>
                <v-card dark color="white" class="black--text">
                    <v-card-title primary-title>
                        <div>
                            <h3 class="headline mb-0">
                                {{bounty.Heading}}
                            </h3>
                            <v-card-actions class="pa-3">
                                <v-icon color="black" x-small>multiline_chart</v-icon>
                                &nbsp; {{bounty.Offering}} Eth
                            </v-card-actions>
                            <v-card-actions class="pa-3">
                                <v-icon v-if="bounty.Stage=='Completed'" color="black" x-small>
                                    check_circle</v-icon>
                                <v-icon v-if="bounty.Stage=='Dead'" color="black" x-small>offline_pin
                                </v-icon>
                                <v-icon v-else color="black" x-small>spellcheck</v-icon>
                                &nbsp; {{bounty.Stage}}

                            </v-card-actions>

                            <div class="text-xs-center">
                                <v-chip small v-for="tag in bounty.Tags">&nbsp; {{tag}}</v-chip>
                            </div>
                            <v-card-actions class="pa-3">
                                <v-icon color="black" x-small>perm_identity</v-icon>
                                <v-card-text class="px-0">{{bounty.Poster}}</v-card-text>
                            </v-card-actions>
                        </div>
                        <v-layout align-center justify-end column reverse fill-height>
                            <span class="group pa-2">
                                <v-card-actions class="pa-3">
                                    <v-icon color="black" x-small>star</v-icon> Difficulty
                                    &nbsp; {{bounty.Difficulty}}
                                </v-card-actions>
                                <v-card-actions class="pa-3">
                                    <v-icon color="black" x-small>calendar_today</v-icon>
                                    &nbsp; {{bounty.Remaining}} Days Remaining
                                </v-card-actions>
                                <v-card-actions class="pa-3">
                                    <v-icon color="black" x-small>gavel</v-icon>
                                    &nbsp; {{bounty.Submissions}} Submissions
                                </v-card-actions>
                                <v-card-actions class="pa-3">
                                    <v-icon color="black" x-small>monetization_on</v-icon>
                                    &nbsp; R {{bounty.Fiat}}
                                </v-card-actions>
                            </span>
                        </v-layout>
                    </v-card-title>
                    <v-card-actions>
                        <v-btn flat color="black" @click="descriptionDialogue=true;  description=bounty.Description">
                            Details
                        </v-btn>

                        <v-spacer></v-spacer>
                    </v-card-actions>
                </v-card>
            </v-flex>
        </v-layout>
        <InfiniteLoading @infinite="getBounties" spinner="waveDots">
        </InfiniteLoading>
    </v-container>

</template>

<script>
    import MugenScroll from 'vue-mugen-scroll'
    import Multiselect from 'vue-multiselect'
    import InfiniteLoading from 'vue-infinite-loading';
    import Vue from 'vue';
    import EmbarkJS from "../../embarkArtifacts/embarkjs";
    import Loading from 'vue-loading-overlay';
    // Import stylesheet
    import 'vue-loading-overlay/dist/vue-loading.css';
    import Swal from 'sweetalert2'
    import SecureLS from 'secure-ls'

    export default {
        name: "Disputes",
        data() {
            return {
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
                BountyContract: null,
                selectedBounty: {},
                address: null,
                SecureLS: new SecureLS()

            }
        },
        mounted() {
            this.init()
        },
        components: {
            MugenScroll,
            Multiselect,
            InfiniteLoading
        },
        computed: {
            filterBounties() {
                if (this.Difficultyvalue != null && this.Difficultyvalue != "Defualt") {
                    return this.Postedbounties.filter(bounty => {
                        return bounty.Difficulty == this.Difficultyvalue
                    })

                }
                if (this.Sortvalue && this.Sortvalue != "Defualt") {
                    if (this.Sortvalue == "Expiry") {
                        return this.Postedbounties.sort(function (a, b) {
                            return b.Remaining - a.Remaining
                        })
                    }
                    if (this.Sortvalue == "Value:Low to High") {
                        return this.Postedbounties.sort(function (a, b) {
                            return a.Fiat - b.Fiat
                        })
                    } else if (this.Sortvalue == "Value:High to Low") {
                        return this.Postedbounties.sort(function (a, b) {
                            return b.Fiat - a.Fiat
                        })
                    }

                } else {
                    return this.defualtPostedBounties
                }
            }
        },
        methods: {
            init: async function () {

                this.web3 = EmbarkJS;
                this.BountyContract = require("../../embarkArtifacts/contracts/BountyContract").default
                this.loggedIn = this.$loggedIn
                this.address = this.getAddress()
            },
            getBounties($state) {
                let req = new XMLHttpRequest();
                req.onreadystatechange = () => {
                    if (req.readyState == XMLHttpRequest.DONE) {
                        let response = JSON.parse(req.responseText)
                        if (response.length == 1) {
                            $state.complete();
                        } else {
                            for (var index = 1; index < response.length; index++) {
                                var data = response[index]
                                if (data.indispute[0] && data.poster == this.getAddress()) {
                                    this.Postedbounties.push({
                                        Heading: data.title,
                                        Description: data.description,
                                        Difficulty: data.difficulty == 1 ? "Begginner" : data.difficulty ==
                                            2 ?
                                            "Intermediate" : data.difficulty == 3 ? "Hard" : "Extreme",
                                        Remaining: this.daysRemaining(data.endDate),
                                        Submissions: data.submissions,
                                        Offering: data.offering,
                                        Fiat: data.fiat,
                                        Tags: data.category,
                                        Poster: data.poster,
                                        Stage: data.stage,
                                        SolutionHashes: data.solutionHashes,
                                        HunterAddresses: data.hunterAddresses,
                                        Paused: data.paused,
                                        ID: data.id,
                                        InDispute: data.indispute,
                                        Winner: data.winner,
                                    })
                                    this.defualtPostedBounties.push({
                                        Heading: data.title,
                                        Description: data.description,
                                        Difficulty: data.difficulty == 1 ? "Begginner" : data.difficulty ==
                                            2 ?
                                            "Intermediate" : data.difficulty == 3 ? "Hard" : "Extreme",
                                        Remaining: this.daysRemaining(data.endDate),
                                        Submissions: data.submissions,
                                        Offering: data.offering,
                                        Fiat: data.fiat,
                                        Tags: data.category,
                                        Poster: data.poster,
                                        Stage: data.stage,
                                        SolutionHashes: data.solutionHashes,
                                        HunterAddresses: data.hunterAddresses,
                                        Paused: data.paused,
                                        ID: data.id,
                                        InDispute: data.indispute,
                                        Winner: data.winner,
                                    })
                                    for (var i = 0; i < data.category.length; i++) {
                                        this.Category.push(data.category[i])
                                    }
                                }
                                $state.loaded();

                            }
                            $state.complete();
                        }
                    };

                }
                req.open("GET", "https://api.myjson.com/bins/i2v3t", true);
                req.send();
            },
            getSolution: async function () {
                EmbarkJS.Storage.get(this.description).then(content => {
                    this.description = content

                }).catch((err => {
                    console.log(err)
                }))
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
            updateBounties() {
                let req = new XMLHttpRequest()
                req.onreadystatechange = () => {
                    if (req.readyState == XMLHttpRequest.DONE) {
                        this.$log.debug(JSON.parse(req.responseText))
                        let data = JSON.parse(req.responseText)
                        for (var i = 0; i < data.length; i++) {
                            let bounty = data[i]
                            this.$log.debug(this.BountyContract)
                            if (bounty.id == selectedBounty.id) {
                                data[i].stage = "Completed"
                                break
                            }
                        }
                        let post = new XMLHttpRequest()
                        post.onreadystatechange = () => {
                            if (post.readyState == XMLHttpRequest.DONE) {
                                this.$log.debug(post.responseText)
                            }
                        };
                        post.open("PUT", "https://api.myjson.com/bins/i2v3t", true)
                        post.setRequestHeader("Content-type", "application/json")
                        post.send(JSON.stringify(data));
                    }
                }
                req.open("GET", "https://api.myjson.com/bins/i2v3t", true)
                req.send()
            },
            acceptSolution() {
                this.BountyContract.methods.acceptSolution(
                    (this.selectedBounty.id)).send({
                    gas: 5000000
                }).then((val, err) => {
                    if (err) {
                        this.$log.debug(err)
                        this.error("OH no something went wrong wont you try again :D")
                    } else {

                        this.success(
                            "Successfully accepted Bounty please see if it appears under the bounties section of the platform"
                        )

                    }
                    this.isLoading = false;

                });
            },
            getLoggedIn() {
                return this.SecureLS.get("loggedIn")
            },
            getAddress() {
                return this.SecureLS.get("address")
            },

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