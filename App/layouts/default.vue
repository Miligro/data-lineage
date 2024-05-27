<template>
  <v-app>
    <AppBar />
    <div class="o-page">
      <slot />
    </div>
  </v-app>
</template>

<script setup lang="ts">
import AppBar from '~/components/modules/AppBar/organisms/AppBar.vue'
</script>

<style lang="scss" scoped>
.o-page {
  height: 100%;
  margin-top: 4rem;
}
</style>
