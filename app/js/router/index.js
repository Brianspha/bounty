import Bounties from "../components/Bounties.vue";
import Router from 'vue-router';
import Profile from '../components/Profile.vue'
import HelloWorld from "../components/HelloWorld.vue";
import AddBounty from "../components/AddBounty.vue";
import LeaderBoard from "../components/LeaderBoard.vue";

import Vue from "vue"
Vue.use(Router)
export default new Router({
    routes: [
        {
            path: "/bounties",
            name: "Bounties",
            component: Bounties
        },
        {
            path: "/helloworld",
            name: "HelloWorld",
            component: HelloWorld
        },
        {
            path: "/profile",
            name: "Profile",
            component: Profile
        },
        {
            path: "/addbounty",
            name: "AddBounty",
            component: AddBounty
        },
        {
            path: "/leaderboard",
            name: "LeaderBoard",
            component: LeaderBoard
        },

    ],
    mode: "history"
});