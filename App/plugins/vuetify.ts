import '@mdi/font/css/materialdesignicons.css'

import 'vuetify/styles'
import { createVuetify } from 'vuetify'

export default defineNuxtPlugin((app) => {
  const vuetify = createVuetify({
    ssr: true,
    theme: {
      defaultTheme: 'myCustomTheme',
      themes: {
        myCustomTheme: {
          colors: {
            primary: '#A63575',
          },
        },
      },
    },
  })
  app.vueApp.use(vuetify)
})
