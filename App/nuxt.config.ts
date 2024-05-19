import vuetify, { transformAssetUrls } from 'vite-plugin-vuetify'

export default defineNuxtConfig({
  build: {
    transpile: ['vuetify'],
  },
  runtimeConfig: {
    public: {
      baseURL: 'http://localhost:8080',
    },
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
