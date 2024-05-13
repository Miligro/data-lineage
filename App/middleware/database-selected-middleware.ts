export default defineNuxtRouteMiddleware(() => {
  const databaseStore = useDatabaseStore()
  if (!databaseStore.id) {
    return navigateTo('/')
  }
})
