<template>
  <v-card class="login-card">
    <v-card-title>Wybierz bazę danych</v-card-title>
    <v-divider></v-divider>
    <v-list>
      <v-list-item
        v-for="database in databases"
        :key="database.id"
        class="database-list-item"
        @click="selectDatabase(database)"
        >{{ database.name }}</v-list-item
      >
    </v-list>
  </v-card>
</template>

<script setup lang="ts">
import type DatabaseInterface from '~/features/database/interfaces/DatabaseInterface'

definePageMeta({
  middleware: ['database-not-selected-middleware'],
  layout: 'login',
})
const databaseStore = useDatabaseStore()
const databases = ref<Array<DatabaseInterface>>([])
const router = useRouter()

const selectDatabase = (selectedDatabase: DatabaseInterface) => {
  databaseStore.id = selectedDatabase.id
  databaseStore.name = selectedDatabase.name
  router.push('/lineage')
}

const { data }: { data: Array<DatabaseInterface> } =
  await useApiFetch('/objects')
databases.value = [
  {
    id: 1,
    name: 'PostgreSQL',
  },
  {
    id: 2,
    name: 'SQL Server',
  },
]
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
