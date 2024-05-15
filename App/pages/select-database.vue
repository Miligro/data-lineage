<template>
  <v-card class="login-card">
    <v-card-title>Wybierz bazę danych</v-card-title>
    <v-divider></v-divider>
    <v-list v-if="!fetchingDatabases">
      <v-list-item
        v-for="database in databases"
        :key="database.id"
        class="database-list-item"
        @click="selectDatabase(database)"
        >{{ database.name }}</v-list-item
      >
    </v-list>
    <v-skeleton-loader v-else type="list-item@3" />
  </v-card>
</template>

<script setup lang="ts">
import type DatabaseInterface from '~/features/database/interfaces/DatabaseInterface'
import type DatabasesInterface from '~/features/database/interfaces/DatabasesInterface'

definePageMeta({
  middleware: ['database-not-selected-middleware'],
  layout: 'login',
})
const databaseStore = useDatabaseStore()
const databases = ref<Array<DatabaseInterface>>([])
const fetchingDatabases = ref<boolean>(true)

const selectDatabase = (selectedDatabase: DatabaseInterface) => {
  databaseStore.selectDatabase(selectedDatabase)
}

const fetchDatabases = async () => {
  fetchingDatabases.value = true
  try {
    const data = await useApiFetch<DatabasesInterface>('/list_database_ids')
    databases.value = data.databases
  } catch {
    databases.value = []
  } finally {
    fetchingDatabases.value = false
  }
}

fetchDatabases()
</script>

<style lang="scss" scoped>
.login-card {
  width: 400px;
  padding: 1rem;
  box-shadow: 0 0 10px 0 #434343;
  border-radius: 8px;
}

.database-list-item:hover {
  background-color: rgba(18, 171, 237, 0.31);
  border-radius: 4px;
}
</style>
