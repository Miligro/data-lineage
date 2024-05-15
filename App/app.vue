<template>
  <div id="app">
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script lang="ts" setup>
onMounted(() => {
  const databaseStore = useDatabaseStore()
  databaseStore.loadDatabase()
})
</script>

<style lang="scss">
#app {
  min-height: 100vh;
  margin: 0;
}

html,
body {
  height: 100%;
  margin: 0;
}
</style>
