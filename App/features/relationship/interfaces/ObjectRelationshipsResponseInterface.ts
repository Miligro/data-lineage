import type { ElementDefinition } from 'cytoscape'
import type DatabaseInterface from '~/features/database/interfaces/DatabaseInterface'
import type { ObjectInterface } from '~/features/object/interfaces/ObjectInterface'

export default interface ObjectRelationshipsResponseInterface {
  database: DatabaseInterface
  object: ObjectInterface
  relationships: Array<ElementDefinition>
}
