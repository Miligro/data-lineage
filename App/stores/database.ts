import { defineStore } from 'pinia'
import type DatabaseStoreInterface from '~/features/database/interfaces/DatabaseStoreInterface'
import type DatabaseInterface from '~/features/database/interfaces/DatabaseInterface'

export const useDatabaseStore = defineStore('database', {
  state: () =>
    ({
      id: null,
      name: null,
    }) as DatabaseStoreInterface,
  actions: {
    selectDatabase(database: DatabaseInterface) {
      const router = useRouter()
      this.id = database.id
      this.name = database.name
      localStorage.setItem('database', JSON.stringify(database))
      router.push('/lineage')
    },
    loadDatabase() {
      const router = useRouter()
      const route = useRoute()
      const database = localStorage.getItem('database')
      if (database) {
        const parsedDatabase = JSON.parse(database)
        this.id = parsedDatabase.id
        this.name = parsedDatabase.name
        if (route.path === '/') {
          router.replace(`/databases/${this.id}/objects`)
        }
      } else {
        router.push('/')
      }
    },
    logout() {
      const router = useRouter()
      localStorage.removeItem('database')
      this.id = null
      this.name = null
      router.push('/')
    },
  },
})
