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
                                    <v-select v-model="Typesvalue" :items="Types" label="Type">
                                    </v-select>
                                </v-flex>
                                <v-flex xs12 sm6 d-flex>
                                    <v-select v-model="Sortvalue" :items="Sort" label="Sort By">
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
            </v-layout>
            <v-flex xs12>
                <v-flex v-for="bounty in filterBounties" xs12>
                    <v-card dark color="white" class="black--text">
                        <v-card-title primary-title>
                            {{ShowingType}}
                            <v-flex class="text-truncate">
                                <v-icon color="black" x-small>perm_identity</v-icon>
                                {{bounty.Address!=null?bounty.Address:bounty.Poster}}
                            </v-flex>
                            <v-card-actions>
                                <v-icon color="black" v-if="bounty.TotalEarnings!=null" x-small>monetization_on</v-icon>
                                <v-icon color="black" v-else x-small>multiline_chart</v-icon>
                                <v-card-text class="px-0 ">
                                    {{bounty.TotalEarnings!=null?bounty.TotalEarnings:bounty.TotalOfferings}}
                                </v-card-text>
                            </v-card-actions>
                        </v-card-title>
                        <v-card-actions>
                            <v-divider></v-divider>
                            <v-icon color="black" x-small>whatshot</v-icon> {{bounty.Ranking}}
                            <v-divider></v-divider>
                        </v-card-actions>
                    </v-card>
                </v-flex>
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
    /* eslint-disable */
    export default {
        name: "Rankings",
        data() {
            return {
                isLoading: false,
                fileUploadDialogue: false,
                dialog: false,
                Postedbounties: [],
                loading: false,
                Sortvalue: "Eth:Low to High",
                Sort: ["Defualt", "Eth:Low to High", "Eth:High to Low"],
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
                Types: ["Defualt", "Bounty Hunter", "Bounty Poster"],
                Typesvalue: "Bounty Poster",
                ShowingType: "Bounty Poster",
                Count: 1
            }
        },
        mounted() {
            this.init()
        },
        methods: {
            init: async function () {
                this.web3 = EmbarkJS;
                this.BountyContract = require("../../embarkArtifacts/contracts/BountyContract").default
                this.loggedIn = this.getLoggedIn()
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
                                if (!data.indispute[0]) {
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
                                    for (var i = 0; i < data.category.length; i++) {
                                        this.Category.push(data.category[i])
                                    }
                                    this.defualtPostedBounties = this.Postedbounties
                                    $state.loaded();
                                }
                            }
                            $state.complete();
                        }

                    };
                }
                req.open("GET", "https://api.myjson.com/bins/13mpql", true);
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
            },
            uniqueByKeepFirst(a, key) {
                let seen = new Set();
                return a.filter(item => {
                    let k = key(item);
                    return seen.has(k) ? false : seen.add(k);
                });
            },
            sortLowestToHighest(array, value) {
                return array.sort(function (a, b) {
                    return b[value] - a[value]
                })
            },
            sortHighestToLowest(array, value) {
                return array.sort(function (a, b) {
                    return a.value - b.value
                })
            },
            indexBounty(bounties) {
                let ranking = 1
                return bounties.map((bounty) => {
                    bounty.Ranking = ranking++
                })

            },
            setStandardPoster() {
                let occurences = []
                this.Postedbounties.forEach(bounty => {
                    occurences.push({
                        Id: bounty.Poster,
                        Bounty: bounty,
                        Ocurrences: this.Postedbounties.filter(hunter => {
                            return hunter.Poster == bounty.Poster
                        }).length
                    })
                })
                occurences = this.uniqueByKeepFirst(occurences, item => item.Id)
                let newOccurences = []
                occurences.forEach(bounty => {
                    newOccurences.push(bounty.Bounty)
                })
                newOccurences.forEach((bounty) => {
                    let total = 0
                    this.Postedbounties.forEach((innerBounty) => {
                        if (innerBounty.Poster == bounty.Poster) {
                            total += parseFloat(innerBounty.Offering)
                        }
                    })
                    bounty.TotalOfferings = total
                })
                return newOccurences
            },
            handleSort(array, by) {
                return this.Sortvalue == "Eth:Low to High" ? this.sortLowestToHighest(array, by) : this.Sortvalue ==
                    "Eth:High to Low" ? this.sortHighestToLowest(array, by) : array
            }
        },
        computed: {
            filterBounties() {
                this.ShowingType = this.Typesvalue != "Default" ? this.Typesvalue : this.ShowingType
                if ((this.Typesvalue != "Defualt" && this.Typesvalue == "Bounty Poster" && this.Sortvalue ==
                        "Default")) {
                    let newOccurences = this.setStandardPoster()
                    newOccurences = this.handleSort(newOccurences, "Offering")
                    let ranking = 1
                    newOccurences.map((bounty) => {
                        bounty.Ranking = ranking++
                    })
                    return newOccurences
                }
                if (this.Typesvalue != "Defualt" && this.Typesvalue == "Bounty Hunter") {
                    let occurences = []
                    this.ShowingType = "Bounty Hunter"
                    this.Postedbounties.forEach(bounty => {
                        bounty.HunterAddresses.forEach(address => {
                            occurences.push(address)
                        })
                    })
                    let newOccurences = []
                    occurences.forEach(address => {
                        let cashings = 0
                        this.Postedbounties.forEach((bounty) => {
                            if (bounty.Winner == address) {
                                cashings += bounty.Offering
                            }
                        })
                        newOccurences.push({
                            Occurences: this.Postedbounties.filter(bounty => {
                                return bounty.HunterAddresses.includes(address)
                            }).length,
                            Address: address,
                            TotalEarnings: cashings
                        })
                    })
                    newOccurences = this.uniqueByKeepFirst(newOccurences, item => item.Address)
                    newOccurences = this.handleSort(newOccurences, "Offering")
                    let ranking = 1
                    newOccurences.map((bounty) => {
                        bounty.Ranking = ranking++
                    })
                    return newOccurences
                } else {
                    let newOccurences = this.setStandardPoster()
                    newOccurences = this.handleSort(newOccurences, "Offering")
                    let ranking = 1
                    newOccurences.map((bounty) => {
                        bounty.Ranking = ranking++
                    })
                    return newOccurences
                }
            }
        },
        components: {
            MugenScroll,
            Multiselect,
            InfiniteLoading,
            Loading
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