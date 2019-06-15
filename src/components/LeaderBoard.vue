<template>
    <v-layout align-center justify-center row light>
        <v-flex xs12 fluid fill-height>
            <v-list three-line>
                <v-radio-group v-model="row" row xs12 sm4 md4>
                    <v-radio label="Top Earners" value="radio-1"></v-radio>
                    <v-radio label="Top Issuers" value="radio-2"></v-radio>
                </v-radio-group>
                <template v-for="(item, index) in items">
                    <v-subheader v-if="item.header" :key="item.header">
                        {{ item.header }}
                    </v-subheader>
                    <v-divider v-else-if="item.divider" :key="index" :inset="item.inset"></v-divider>
                    <v-list-tile v-else :key="item.address" avatar @click="">
                        <v-list-tile-avatar>
                            <img src="https://png.pngtree.com/svg/20150716/2f7528fe9c.svg">
                        </v-list-tile-avatar>

                        <v-list-tile-content>
                            <v-list-tile-title v-html="item.address"> </v-list-tile-title>
                        </v-list-tile-content>
                    </v-list-tile>
                </template>
            </v-list>
        </v-flex>
    </v-layout>
</template>

<script>
    export default {
        name: "LeaderBoard",
        data() {
            return {
                items: [{
                        divider: true,
                        inset: true
                    },
                    {
                        address: "asss"
                    }
                ],
                row: "radio-1"
            }
        }
    }
</script>

<style scoped>
    #centerItems {
        text-align: center;
    }
</style>