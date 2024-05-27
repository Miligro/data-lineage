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
          title: 'Typ',
          key: 'type',
        },
        {
          title: '',
          key: 'actions',
          width: '40',
          sortable: false,
        },
      ]"
      :items="objects"
      items-per-page-text="Na stronie:"
      no-data-text="Brak danych"
      loading-text="Pobieranie danych"
    >
      <template #[`item.actions`]="{ item }">
        <v-btn variant="text" :icon="true" @click="redirectToLineage(item.id)">
          <v-tooltip activator="parent">Lineage obiektu</v-tooltip>
          <v-icon>mdi-transit-connection-horizontal</v-icon>
        </v-btn>
      </template>
    </v-data-table>
  </v-card>
</template>

<script lang="ts" setup>
import type { ObjectInterface } from '~/features/object/interfaces/ObjectInterface'
import type { ObjectsListResponse } from '~/features/object/interfaces/ObjectsListResponse'

const router = useRouter()
const route = useRoute()
const objects = ref<Array<ObjectInterface>>([])
const loading = ref<boolean>(true)
const search = ref<string>('')
const databaseId = route.params.database_id

const fetchObjects = async () => {
  loading.value = true
  try {
    const response = await useApiFetch<ObjectsListResponse>(
      `/databases/${databaseId}/objects`
    )
    objects.value = response.objects
  } catch {
    objects.value = []
  } finally {
    loading.value = false
  }
}

const redirectToLineage = (id: number | string) => {
  router.push(`/databases/${databaseId}/objects/${id}/lineage`)
}

fetchObjects()
</script>

<style lang="scss" scoped>
.table-card {
  padding: 2rem;
  height: 100%;
}
</style>
