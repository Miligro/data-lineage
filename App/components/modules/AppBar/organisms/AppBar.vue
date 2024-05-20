<template>
  <v-app-bar color="blue-lighten-1">
    <v-app-bar-title class="toolbar-title">Lineage</v-app-bar-title>
    <v-divider vertical class="divider"></v-divider>
    <v-btn :icon="true" @click="redirectToDatabasesList">
      <v-tooltip activator="parent">Lista baz danych</v-tooltip>
      <v-icon>mdi-format-list-group</v-icon>
    </v-btn>
  </v-app-bar>
</template>

<script lang="ts" setup>
const router = useRouter()

const redirectToDatabasesList = () => {
  router.push(`/`)
}
</script>

<style lang="scss" scoped>
.toolbar-title {
  flex: unset;
}

.divider {
  margin: 0 1rem;
}
</style>
