<template>
  <v-app>
    <AppBar />
    <div style="margin-top: 4rem; height: 100%">
      <slot />
    </div>
  </v-app>
</template>

<script setup lang="ts">
import AppBar from '~/components/modules/AppBar/organisms/AppBar.vue'
</script>
