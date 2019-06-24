import Bounties from "../components/Bounties.vue";
import Router from 'vue-router';
import Pending from "../components/PendingBounties.vue";
import AddBounty from "../components/AddBounty.vue";
import Disputes from "../components/Disputes.vue";
import Created from "../components/AddedBounties.vue";
import Solutions from "../components/CreatedBountySolutions.vue";
import Hunted from "../components/HuntedBounties.vue";
import Rankings from "../components/Rankings.vue";

import Vue from "vue"
Vue.use(Router)
export default new Router({
    routes: [{
            path: "/",
            redirect: "bounties"
        }, {
            path: "/bounties",
            name: "Bounties",
            component: Bounties
        },
        {
            path: "/disputes",
            name: "Disputes",
            component: Disputes
        },
        {
            path: "/addbounty",
            name: "AddBounty",
            component: AddBounty
        },
        {
            path: "/createdBounties",
            name: "CreatedBounties",
            component: Created
        },
        {
            path: "/createdbountysolutions",
            name: "Solutions",
            component: Solutions
        },
        {
            path: "/pendingBounties",
            name: "PendingBounties",
            component: Pending
        },
        {
            path: "/huntedBounties",
            name: "HuntedBounties",
            component: Hunted
        },
        {
            path: "/rankings",
            name: "Rankings",
            component: Rankings
        }

    ],
    mode: "history"
});