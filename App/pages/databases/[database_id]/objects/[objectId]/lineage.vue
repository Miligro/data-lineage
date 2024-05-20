<template>
  <div class="lineage-container">
    <LineageDiagram :database-id="databaseId" :object-id="objectId" />
  </div>
</template>

<script lang="ts" setup>
import LineageDiagram from '~/components/modules/LineageDiagram/organisms/LineageDiagram.vue'

const route = useRoute()
const databaseId = Array.isArray(route.params.database_id)
  ? route.params.database_id[0]
  : route.params.database_id
const objectId = Array.isArray(route.params.objectId)
  ? route.params.objectId[0]
  : route.params.objectId
</script>

<style lang="scss" scoped>
.lineage-container {
  height: 100%;
}
</style>
