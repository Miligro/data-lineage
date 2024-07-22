import vuetify, { transformAssetUrls } from 'vite-plugin-vuetify'
import { rewriteDefault } from 'vue/compiler-sfc'

export default defineNuxtConfig({
  build: {
    transpile: ['vuetify'],
  },
  routeRules: {
    "/api/**": { proxy: 'http://lineage-api-1:8000/**' }
  },
  plugins: ['~/plugins/vuetify'],
  modules: [
    (_options, nuxt) => {
      nuxt.hooks.hook('vite:extendConfig', (config) => {
        // @ts-expect-error
        config.plugins.push(vuetify({ autoImport: true }))
      })
    },
    '@pinia/nuxt',
  ],
  vite: {
    vue: {
      template: {
        transformAssetUrls,
      },
    },
  },
  hooks: {
    'pages:extend'(pages) {
      pages.push({
        name: 'databases',
        path: '/',
        file: '~/pages/databases/index.vue',
      })
    },
  },
})
