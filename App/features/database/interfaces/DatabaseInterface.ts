import type IngestStatusInterface from '~/features/ingest/interfaces/IngestStatusInterface'

export default interface DatabaseInterface {
  id: number
  name: string
  ingest_status: IngestStatusInterface
}
