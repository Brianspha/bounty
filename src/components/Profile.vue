<template>
   <v-layout row>
      <v-flex xs12 fluid fill-height>
         <v-card>
            <v-toolbar color="white" light>
               <v-toolbar-title>Profile</v-toolbar-title>
               <v-spacer></v-spacer>
            </v-toolbar>
            <v-list>
               <v-list-group v-for="item in items" :key="item.title" v-model="item.active" :prepend-icon="item.action"
                  no-action>
                  <template v-slot:activator>
                     <v-list-tile>
                        <v-list-tile-content>
                           <v-list-tile-title>{{ item.title }}</v-list-tile-title>
                        </v-list-tile-content>
                     </v-list-tile>
                  </template>

                  <v-list-tile v-for="subItem in item.items" :key="subItem.title" @click="">
                     <v-list-tile-content>
                        <v-list-tile-title>{{ subItem.title }}</v-list-tile-title>
                     </v-list-tile-content>

                     <v-list-tile-action>
                        <v-icon>{{ subItem.action }}</v-icon>
                     </v-list-tile-action>
                  </v-list-tile>
               </v-list-group>
            </v-list>
         </v-card>
      </v-flex>
   </v-layout>
</template>
<script>
   export default {
      data() {
         return {
            name: "Profile",
            items: [{
                  action: 'check_circle_outline',
                  title: 'Completed Bounties',
                  items: [{
                     title: 'List Item'
                  }]
               },
               {
                  action: 'loop',
                  title: 'Pending Bounties',
                  active: true,
                  items: [{
                        title: 'Breakfast & brunch'
                     },
                     {
                        title: 'New American'
                     },
                     {
                        title: 'Sushi'
                     }
                  ]
               },
               {
                  action: 'error',
                  title: 'Disputes',
                  items: [{
                     title: 'List Item'
                  }]
               },
               {
                  action: 'local_offer',
                  title: 'Created Bounties',
                  items: [{
                     title: 'List Item'
                  }]
               },
               {
                  action: 'attach_money',
                  title: 'Total Earnings',
                  items: [{
                     title: 'List Item'
                  }]
               },
               {
                  action: 'plus_one',
                  title: 'Ranking',
                  items: [{
                     title: 'List Item'
                  }]
               }
            ]
         }
      },
      methods:{

      },
      computed:{

      },
      components:{
         
      }
   }
</script>