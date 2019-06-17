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
                                    <v-select v-model="Categoryvalue" :items="Category" label="Category" chips multiple
                                        persistent-hint></v-select>
                                </v-flex>
                                <v-flex xs12 sm6 d-flex>
                                    <v-select v-model="Difficultyvalue" :items="Difficulties" box label="Difficulty">
                                    </v-select>
                                </v-flex>
                                <v-flex xs12 sm6 d-flex>
                                    <v-select v-model="Sortvalue" :items="Sort" label="Sort" outline></v-select>
                                </v-flex>
                                <v-flex xs12 sm6 d-flex>
                                    <v-select v-model="Stagevalue" :items="Stage" label="Stage" solo></v-select>
                                </v-flex>
                            </v-layout>
                        </v-container>
                        <v-card-actions>
                            <v-spacer></v-spacer>
                            <v-btn color="white" light @click="dialog = false">
                                Filter
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
                                            I accept
                                        </v-btn>
                                    </v-card-actions>
                                </v-flex>
                            </v-layout>
                        </v-container>
                    </v-card>
                </v-dialog>
            </v-layout>
            <v-flex v-for="bounty in Postedbounties" xs12>
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
                            <div class="text-xs-center">
                                <v-chip small v-for="tag in bounty.Tags">&nbsp; {{tag}}</v-chip>
                            </div>
                            <v-card-text class="px-0"></v-card-text>
                        </div>
                        <v-layout align-center justify-end column reverse fill-height>
                            <span class="group pa-2">
                                <v-card-actions class="pa-3">
                                    <v-icon color="black" x-small>star</v-icon> Difficulty
                                    &nbsp; {{bounty.Difficulty}}
                                </v-card-actions>
                                <v-card-actions class="pa-3">
                                    <v-icon color="black" x-small>calendar_today</v-icon>
                                    &nbsp; {{bounty.Remaining}} Remaining
                                </v-card-actions>
                                <v-card-actions class="pa-3">
                                    <v-icon color="black" x-small>gavel</v-icon>
                                    &nbsp; {{bounty.Submissions}} Submissions
                                </v-card-actions>
                                <v-card-actions class="pa-3">
                                    <v-icon color="black" x-small>monetization_on</v-icon>
                                    &nbsp; {{bounty.Fiat}}
                                </v-card-actions>
                            </span>
                        </v-layout>
                    </v-card-title>
                    <v-card-actions>
                        <v-btn flat color="black" @click="descriptionDialogue=true; description=bounty.Description">view
                        </v-btn>

                        <v-spacer></v-spacer>
                        <v-btn v-if="loggedIn" flat color="black">Submit</v-btn>
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

    export default {
        name: "Bounties",
        data() {
            return {
                dialog: false,
                Postedbounties: [],
                loading: false,
                Categoryvalue: [],
                Stagevalue: [],
                Sortvalue: [],
                Difficultyvalue: [],
                Difficulties: ['Begginner', 'Intermediate', 'Hard', 'Extreme'],
                Stage: ["Active", "Completed", "Dead"],
                Sort: ["Recent", "Expiry", "Value:Low to High"],
                Category: ["Html", "CSS", "JS", "MS", "A", "S", "D", "G", "GG"],
                loggedIn: false,
                descriptionDialogue: false,
                description: "No desription"

            }
        },
        methods: {
            getBounties($state) {
                Vue.axios.get("https://api.myjson.com/bins/135rv1").then((response) => {
                    console.log(response.data)
                    for (var index = 0; index < response.data.length; index++) {
                        var data = response.data[index]
                        console.log(data)
                        this.Postedbounties.push({
                            Heading: data.title,
                            Description: data.description,
                            Difficulty: data.difficulty == 1 ? "Begginner" : data.difficulty == 2 ?
                                "Intermediate" : data.difficulty == 3 ? "Experienced" : "Extreme",
                            Remaining: data.endDate,
                            Submissions: data.submissions,
                            Offering: data.offering,
                            Fiat: "R " + data.fiat,
                            Tags: data.category
                        })
                        $state.loaded();
                    }
                })
                $state.complete();

            }
        },
        components: {
            MugenScroll,
            Multiselect,
            InfiniteLoading
        }
    }

    function getBountyData() {

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