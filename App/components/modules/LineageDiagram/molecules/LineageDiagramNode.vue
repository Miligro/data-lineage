<template>
  <div class="node">
    <h3>{{ nodeData.label }}</h3>
  </div>
</template>

<script setup>
defineProps({
  nodeData: Object,
})
</script>

<style scoped>
.node {
  padding: 10px;
  background-color: #f0f0f0;
  border: 1px solid #ccc;
  border-radius: 8px;
}
</style>
