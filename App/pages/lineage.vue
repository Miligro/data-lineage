<template>
  <div class="lineage-container">
    <LineageDiagram />
  </div>
</template>

<script lang="ts" setup>
import LineageDiagram from '~/components/modules/LineageDiagram/organisms/LineageDiagram.vue'
</script>

<style lang="scss" scoped>
.lineage-container {
  height: 100%;
  padding: 4rem;
}
</style>
