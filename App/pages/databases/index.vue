<template>
  <v-card class="table-card">
    <v-card-title class="d-flex justify-end pa-2">
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
    </v-card-title>
    <v-data-table
      v-model:search="search"
      :loading="loading"
      :headers="[
        {
          title: 'Nazwa',
          key: 'name',
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
      <template #[`item.actions`]="{ item }">
        <v-btn
          variant="text"
          :icon="true"
          @click="redirectToObjectsList(item.id)"
        >
          <v-tooltip activator="parent">Lista obiektów</v-tooltip>
          <v-icon>mdi-format-list-group</v-icon>
        </v-btn>
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

fetchDatabases()
</script>

<style lang="scss" scoped>
.table-card {
  padding: 2rem;
}
</style>
