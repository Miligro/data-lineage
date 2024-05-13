import { defineStore } from 'pinia'
import type DatabaseStoreInterface from '~/features/database/interfaces/DatabaseStoreInterface'

export const useDatabaseStore = defineStore('database', {
  state: () =>
    ({
      id: null,
      name: null,
    }) as DatabaseStoreInterface,
  actions: {},
})
