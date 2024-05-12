import type { Pinia } from 'pinia'
import { useDatabaseStore } from '~/stores/database'

export default defineNuxtPlugin(({ $pinia }) => {
  return {
    provide: {
      database: useDatabaseStore($pinia as Pinia),
    },
  }
})
