import type DatabaseInterface from '~/features/database/interfaces/DatabaseInterface'
import type { ObjectInterface } from '~/features/object/interfaces/ObjectInterface'

export interface ObjectsListResponse {
  database: DatabaseInterface
  objects: Array<ObjectInterface>
}
