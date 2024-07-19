<template>
  <v-card class="table-card">
    <v-card-title class="d-flex justify-end pa-2 ga-4">
      <v-text-field
        v-model="search"
        density="compact"
        label="Szukaj"
        prepend-inner-icon="mdi-magnify"
        variant="outlined"
        flat
        hide-details
        single-line
      ></v-text-field>
      <v-btn @click="loadDatabases"> Zaczytaj bazy danych </v-btn>
    </v-card-title>
    <v-data-table
      v-model:search="search"
      class="databases-table"
      :loading="loading"
      :headers="[
        {
          title: 'Nazwa',
          key: 'name',
        },
        {
          title: 'Status przepływu',
          key: 'ingest_status',
        },
        {
          title: '',
          key: 'actions',
          width: '40',
          sortable: false,
        },
      ]"
      :items="databases"
      items-per-page-text="Na stronie:"
      no-data-text="Brak danych"
      loading-text="Pobieranie danych"
    >
      <template #[`item.ingest_status`]="{ item }">
        {{ item.ingest_status ? item.ingest_status.name : '' }}
      </template>
      <template #[`item.actions`]="{ item }">
        <div class="d-flex">
          <v-btn
            variant="text"
            :icon="true"
            @click="redirectToObjectsList(item.id)"
          >
            <v-tooltip activator="parent">Lista obiektów</v-tooltip>
            <v-icon>mdi-format-list-group</v-icon>
          </v-btn>
          <v-btn variant="text" :icon="true" @click="ingestData(item.id)">
            <v-tooltip activator="parent">Zaciągnij dane</v-tooltip>
            <v-icon>mdi-source-pull</v-icon>
          </v-btn>
        </div>
      </template>
    </v-data-table>
  </v-card>
</template>

<script lang="ts" setup>
import type DatabasesInterface from '~/features/database/interfaces/DatabasesInterface'
import type DatabaseInterface from '~/features/database/interfaces/DatabaseInterface'

const router = useRouter()
const databases = ref<Array<DatabaseInterface>>([])
const loading = ref<boolean>(true)
const search = ref<string>('')
const fetchDatabaseInterval = ref<NodeJS.Timeout | null>(null)

const fetchDatabases = async () => {
  loading.value = true
  try {
    const data = await useApiFetch<DatabasesInterface>('/databases')
    databases.value = data.databases
  } catch {
    databases.value = []
  } finally {
    loading.value = false
  }
}

const redirectToObjectsList = (id: number | string) => {
  router.push(`/databases/${id}/objects`)
}

const ingestData = async (id: number | string) => {
  try {
    await useApiFetch(`/databases/${id}/ingest/`, { method: 'POST' })
  } catch {}
}

const loadDatabases = async () => {
  try {
    await useApiFetch(`/databases/load/`, { method: 'POST' })
    await fetchDatabases()
  } catch {}
}

fetchDatabases()
onBeforeMount(() => {
  fetchDatabaseInterval.value = setInterval(() => fetchDatabases(), 10000)
})
onBeforeUnmount(() => {
  if (fetchDatabaseInterval.value) {
    clearInterval(fetchDatabaseInterval.value)
  }
})
</script>

<style lang="scss" scoped>
.table-card {
  display: flex;
  flex-direction: column;
  padding: 2rem 2rem 0 2rem;
  height: 100%;
}

.databases-table {
  height: 100%;
}
</style>
