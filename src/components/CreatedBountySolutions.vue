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
                <v-dialog v-model="descriptionDialogue" wrap>
                    <v-card>
                        <v-container fluid>
                            <v-layout wrap>
                                <v-flex xs12 wrap>
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
                <v-card dark v-for="hash in bounty.SolutionHashes" color="white" class="black--text">
                    <v-card-title primary-title>
                        <v-flex>
                            <v-flex class="headline mb-0 text-truncate">
                                {{bounty.Heading}}
                            </v-flex>
                            <div class="text-xs-center">
                                <v-chip small v-for="tag in bounty.Tags">&nbsp; {{tag}}</v-chip>
                            </div>
                        </v-flex>

                    </v-card-title>
                    <v-card-text>
                        Proposed By: {{bounty.HunterAddresses[bounty.SolutionHashes.indexOf(hash)]}}
                    </v-card-text>

                    <v-card-actions>
                        <v-flex>
                            <v-btn flat color="black" @click="descriptionDialogue=true; description=bounty.Description">
                                Details
                            </v-btn>
                            <v-spacer></v-spacer>
                            <v-btn flat color="black"
                                @click="selectedBounty=bounty; solutionHash=hash ;rejectSolution()">
                                Reject Solution
                            </v-btn>
                            <v-spacer></v-spacer>

                            <v-btn flat color="black"
                                @click="selectedBounty=bounty; solutionHash=hash ;acceptSolution()">
                                Accept Solution
                            </v-btn>
                            <v-spacer></v-spacer>
                            <v-btn flat color="black"
                                @click="descriptionDialogue=true;  solutionHash=hash; getSolution()">
                                View Solution
                            </v-btn>
                        </v-flex>
                    </v-card-actions>

                </v-card>
            </v-flex>
        </v-layout>
        <InfiniteLoading @infinite="getBounties" spinner="waveDots">
        </InfiniteLoading>
        <loading :active.sync="isLoading" :can-cancel="false" :is-full-page="fullPage">
        </loading>
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
    /* eslint-disable */
    export default {
        name: "Solutions",
        data() {
            return {
                dialog: false,
                Postedbounties: [],
                loading: false,
                Categoryvalue: null,
                Stagevalue: "Defualt",
                Sortvalue: "Defualt",
                Difficultyvalue: 'Defualt',
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
                SecureLS: new SecureLS(),
                fullPage: true,
                isLoading: false,
                solutionHash: '',
                solution: '',
                bountyWinner: '',
                hunterAddresses: []
            }
        },
        mounted() {
            this.init()
        },
        components: {
            MugenScroll,
            Multiselect,
            InfiniteLoading,
            Loading
        },
        computed: {
            filterBounties() {
                if ((this.Difficultyvalue != "Defualt" && this.Sortvalue != null && this.Sortvalue != "Defualt")) {
                    this.Postedbounties = this.Postedbounties.filter(bounty => {
                        return bounty.Difficulty == this.Difficultyvalue
                    })
                    return this.handleSort(this.Postedbounties, "Offering")
                }
                if (this.Difficultyvalue != "Defualt") {
                    return this.Postedbounties.filter(bounty => {
                        return bounty.Difficulty == this.Difficultyvalue
                    })
                } else if (this.Sortvalue != "Defualt") {
                    return this.handleSort(this.Postedbounties, "Offering")
                } else {
                    return this.defualtPostedBounties
                }
            }
        },
        methods: {
            handleSort(array, by) {
                return this.Sortvalue == "Value:Low to High" ? this.sortLowestToHighest(array, by) : this.Sortvalue ==
                    "Value:High to Low" ? this.sortHighestToLowest(array, by) : this.sortHighestToLowest(array, by)
            },
            sortLowestToHighest(array, value) {
                return array.sort(function (a, b) {
                    return a[value] - b[value]
                })
            },
            sortHighestToLowest(array, value) {
                return array.sort(function (a, b) {
                    return b[value] - a[value]
                })
            },
            init: async function () {

                this.web3 = EmbarkJS;
                this.BountyContract = require("../../embarkArtifacts/contracts/BountyContract").default
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
                                if (data.poster == this.getAddress() && data.stage == "Active") {
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
                                }
                                $state.loaded();
                                this.defualtPostedBounties = this.Postedbounties
                            }
                            $state.complete();
                        }
                    };
                }
                req.open("GET", "https://api.myjson.com/bins/13mpql", true);
                req.send();
            },
            getSolution: async function () {
                EmbarkJS.Storage.get(this.solutionHash).then(content => {
                    this.description = content
                }).catch((err => {
                    console.log(err)
                }))
            },
            daysRemaining(time) {
                var date_future = new Date(new Date(time).getFullYear() + 1, 0, 1);
                var date_now = new Date();
                const diffTime = Math.abs(date_now.getTime() - date_future.getTime());
                const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
                return diffDays
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
            updateBountiesAccepted() {
                let req = new XMLHttpRequest()
                req.onreadystatechange = () => {
                    if (req.readyState == XMLHttpRequest.DONE) {
                        let data = JSON.parse(req.responseText)
                        for (var i = 1; i < data.length; i++) {
                            let bounty = data[i]
                            if (bounty.id == this.selectedBounty.ID) {
                                data[i].stage = "Completed"
                                data[i].winner = this.getAddress()
                                break
                            }
                        }
                        let post = new XMLHttpRequest()
                        post.onreadystatechange = () => {
                            if (post.readyState == XMLHttpRequest.DONE) {}
                        };
                        post.open("PUT", "https://api.myjson.com/bins/13mpql", true)
                        post.setRequestHeader("Content-type", "application/json")
                        post.send(JSON.stringify(data));
                    }
                }
                req.open("GET", "https://api.myjson.com/bins/13mpql", true)
                req.send()
            },
            updateBounties(hunterAddress, bountyID) {
                let req = new XMLHttpRequest()
                req.onreadystatechange = () => {
                    if (req.readyState == XMLHttpRequest.DONE) {
                        let data = JSON.parse(req.responseText)
                        for (var i = 1; i < data.length; i++) {
                            let bounty = data[i]
                            if (bounty.id == bountyID && bounty.hunterAddresses.includes(hunterAddress)) {
                                data[i].solutionHashes.splice(bounty.hunterAddresses.indexOf(hunterAddress), 1)
                                data[i].hunterAddresses.splice(bounty.hunterAddresses.indexOf(hunterAddress), 1)
                                break
                            }
                        }
                        let post = new XMLHttpRequest()
                        post.onreadystatechange = () => {
                            if (post.readyState == XMLHttpRequest.DONE) {}
                        };
                        post.open("PUT", "https://api.myjson.com/bins/13mpql", true)
                        post.setRequestHeader("Content-type", "application/json")
                        post.send(JSON.stringify(data));
                    }
                }
                req.open("GET", "https://api.myjson.com/bins/13mpql", true)
                req.send()
            },
            acceptSolution() {
                this.isLoading = true
                let hunterAddress = this.selectedBounty.HunterAddresses[this.selectedBounty.SolutionHashes.indexOf(this
                    .solutionHash)]
                this.BountyContract.methods.acceptSolution(
                    this.selectedBounty.ID, hunterAddress).send({
                    gas: 8000000
                }).then((val, err) => {
                    if (err) {
                        this.error("OH no something went wrong wont you try again :D")
                    } else {
                        this.updateBountiesAccepted()
                        this.success(
                            "Successfully accepted Bounty solution solution has expired"
                        )
                    }
                    this.isLoading = false;
                }).catch((err) => {
                    this.error(
                        "Something went wrong for the following reasons \n You have accepted a solution for the bounty or the Address of the given bounty hunter is invalid or You currently suspended for bad behaviour on the platform"
                    )
                    this.isLoading = false
                });
            },
            rejectSolution() {
                this.isLoading = true
                let index = this.selectedBounty.SolutionHashes.indexOf(this
                    .solutionHash)
                let hunterAddress = this.selectedBounty.HunterAddresses[index]
                this.BountyContract.methods.rejectSolution(
                    this.selectedBounty.ID, this.solutionHash, hunterAddress).send({
                    gas: 8000000
                }).then((val, err) => {
                    if (err) {
                        this.error("OH no something went wrong wont you try again :D")
                    } else {
                        this.updateBounties(hunterAddress, this.selectedBounty.ID)
                        this.success(
                            "Successfully accepted Bounty solution solution has expired"
                        )
                    }
                    this.isLoading = false;
                }).catch((err) => {
                    this.error("Something went wrong ")
                    this.isLoading = false
                });
            },
            getLoggedIn() {
                return this.SecureLS.get("loggedIn")
            },
            getAddress() {
                return this.SecureLS.get("address")
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
            }
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