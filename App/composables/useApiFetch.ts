export const useApiFetch = <T>(url: string, options = {}): Promise<T> => {
  const config = useRuntimeConfig()
  return $fetch(`${config.public.baseURL}${url}`, options)
}
