export const useApiFetch = (url: string, options = {}) => {
  const config = useRuntimeConfig()
  return $fetch(`${config.public.baseURL}${url}`, options)
}
