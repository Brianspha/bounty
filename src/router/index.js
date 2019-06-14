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
            path: "/",
            name: "Bounties",
            component: Bounties
        },
        {
            path: "/",
            name: "HelloWorld",
            component: HelloWorld
        },
        {
            path: "/",
            name: "Profile",
            component: Profile
        },
        {
            path: "/",
            name: "AddBounty",
            component: AddBounty
        },
        {
            path: "/",
            name: "LeaderBoard",
            component: LeaderBoard
        },

    ],
    mode: "history"
});