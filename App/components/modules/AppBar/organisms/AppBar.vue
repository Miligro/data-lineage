<template>
  <v-app-bar color="blue-lighten-1">
    <v-app-bar-title>Lineage: {{ databaseStore.name }}</v-app-bar-title>
    <v-spacer></v-spacer>
    <v-btn :icon="true" @click="databaseStore.logout()">
      <v-icon>mdi-format-list-group</v-icon>
    </v-btn>
    <v-btn :icon="true" @click="databaseStore.logout()">
      <v-icon>mdi-power</v-icon>
    </v-btn>
  </v-app-bar>
</template>

<script lang="ts" setup>
const databaseStore = useDatabaseStore()
</script>

<style lang="scss" scoped></style>
