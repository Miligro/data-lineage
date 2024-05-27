<template>
  <div class="lineage">
    <v-card class="sliders-card">
      <div class="slider-container">
        <span class="font-weight-bold">Przybliżenie: {{ zoomLevel }}</span>
        <v-slider
          id="zoom-slider"
          v-model="zoomLevel"
          :min="0.1"
          :max="2.0"
          :step="0.01"
          hide-details
          @update:model-value="onZoomChange"
        />
      </div>
      <div class="slider-container">
        <span class="font-weight-bold"
          >Próg graniczny prawdopodobieństwa: {{ thresholdLevel }}</span
        >
        <v-slider
          v-model="thresholdLevel"
          :min="1"
          :max="100"
          :step="0.5"
          hide-details
          @update:model-value="onThresholdChange"
        />
      </div>
    </v-card>
    <div class="container">
      <div ref="cyContainer" class="cy-container">
        <v-tooltip
          v-if="nodeTooltip.visible"
          :model-value="nodeTooltip.visible"
          activator="parent"
          class="lineage-object-tooltip"
          :target="[nodeTooltip.position.left, nodeTooltip.position.top]"
        >
          <div
            style="
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;
            "
          >
            <span>Nazwa obiektu: {{ nodeTooltip.name }}</span>
            <span>Typ obiektu: {{ nodeTooltip.type }}</span>
            <table v-if="nodeTooltip.details && nodeTooltip.details.length">
              <tr>
                <th>Kolumna</th>
                <th>Typ</th>
              </tr>
              <tr v-for="(column, index) in nodeTooltip.details" :key="index">
                <td>{{ column.column_name }}</td>
                <td>{{ column.column_type }}</td>
              </tr>
            </table>
          </div>
        </v-tooltip>
        <v-tooltip
          v-if="edgeTooltip.visible"
          :model-value="edgeTooltip.visible"
          activator="parent"
          class="lineage-object-tooltip"
          :target="[edgeTooltip.position.left, edgeTooltip.position.top]"
        >
          <div
            style="
              display: flex;
              flex-direction: column;
              align-items: center;
              justify-content: center;
            "
          >
            <template v-if="edgeTooltip.details && edgeTooltip.details.length">
              <span
                >Powiązania pomiędzy: {{ edgeTooltip.source_name }} -
                {{ edgeTooltip.target_name }}</span
              >
              <table>
                <tr>
                  <th>Nazwa kolumny</th>
                </tr>
                <tr v-for="(column, index) in edgeTooltip.details" :key="index">
                  <td>{{ column.column_name }}</td>
                </tr>
              </table>
            </template>
            <span v-else>Nie znaleziono elementów powiązania</span>
          </div>
        </v-tooltip>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import cytoscape, { type Core, type ElementDefinition } from 'cytoscape'
import nodeHtmlLabel from 'cytoscape-node-html-label'
import { VTooltip } from 'vuetify/components'
import type ObjectRelationshipsResponseInterface from '~/features/relationship/interfaces/ObjectRelationshipsResponseInterface'

nodeHtmlLabel(cytoscape)

const props = defineProps({
  databaseId: {
    type: String,
    required: true,
  },
  objectId: {
    type: String,
    required: true,
  },
})

const nodeTooltip = ref({
  visible: false,
  details: null as any,
  type: '' as string,
  name: '' as string,
  position: { top: 0, left: 0 },
})

const edgeTooltip = ref({
  visible: false,
  details: null as any,
  source_name: '' as string,
  target_name: '' as string,
  position: { top: 0, left: 0 },
})

const cyContainer = ref<HTMLElement | null>(null)
const cy = ref<Core | null>(null)
const zoomLevel = ref(1.0)
const thresholdLevel = ref(1.0)
const relationships = ref<Array<ElementDefinition>>([])

const relationshipsResponse =
  await useApiFetch<ObjectRelationshipsResponseInterface>(
    `/databases/${props.databaseId}/objects/${props.objectId}/relationships`
  )
relationships.value = relationshipsResponse.relationships

const onThresholdChange = (value: number) => {
  relationships.value = relationshipsResponse.relationships.filter(
    (relationship) => {
      return !!(
        (relationship.data.connection_probability &&
          relationship.data.connection_probability > value / 100) ||
        relationship.data.connection_probability === undefined
      )
    }
  )

  if (cy.value) {
    cy.value.json({ elements: relationships.value })
    cy.value
      .nodes()
      .filter((node) => {
        return node.connectedEdges().length === 0
      })
      .remove()
    cy.value.layout({ name: 'breadthfirst' }).run()
    cy.value.fit()
  }
}

const onZoomChange = (value: number) => {
  if (cy.value) {
    cy.value.zoom(value)
    cy.value.center()
  }
}

onMounted(() => {
  if (!cyContainer.value) return

  cy.value = cytoscape({
    container: cyContainer.value,
    elements: relationships.value,
    style: [
      {
        selector: 'node',
        style: {
          width: '250px',
          height: '75px',
          shape: 'rectangle',
          backgroundColor: 'white',
        },
      },
      {
        selector: 'edge',
        style: {
          width: 2,
          'line-color': '#929498',
          'target-arrow-color': '#929498',
          'target-arrow-shape': 'triangle',
          'curve-style': 'bezier',
          'arrow-scale': 1.5,
          label: 'data(connection_probability)', // Używamy danych etykiet
          'text-rotation': 'autorotate',
          'text-margin-y': -10,
          'font-size': 24,
          color: '#000',
        },
      },
      {
        selector: 'edge.highlighted',
        style: {
          'line-color': 'rgba(18,164,237,0.58)',
          width: 2,
          'target-arrow-color': 'rgba(18,164,237,0.58)',
        },
      },
    ],
    layout: {
      fit: false,
      name: 'breadthfirst',
      directed: false,
      padding: 10,
      spacingFactor: 1.3,
    },
    zoomingEnabled: true,
    userZoomingEnabled: true,
    wheelSensitivity: 0.2,
    minZoom: 0.1,
    maxZoom: 2,
  })

  cy.value.nodeHtmlLabel([
    {
      query: 'node',
      halign: 'center',
      valign: 'center',
      halignBox: 'center',
      valignBox: 'center',
      tpl: function (data) {
        if (cy.value) {
          const node = cy.value.getElementById(data.id)
          const isHighlighted = node.hasClass('highlighted')
          const isHidden = node.hasClass('hidden')
          return `<div class="object-node ${isHighlighted ? 'highlighted-node' : ''} ${isHidden ? 'hidden' : ''}">
                <span class="object-label">${data.label}</span>
              </div>`
        }
        return ''
      },
    },
  ])

  cy.value.zoom(zoomLevel.value)
  cy.value.center()

  cy.value.on('zoom', () => {
    if (cy.value) {
      zoomLevel.value = +cy.value.zoom().toFixed(2)
    }
  })

  cy.value.on('mouseover', 'node', function (event) {
    const node = event.target
    node.addClass('highlighted')
    node.outgoers('edge').addClass('highlighted')
    node.outgoers().addClass('highlighted')
    if (cyContainer.value) {
      nodeTooltip.value.details = node.data('details')
      nodeTooltip.value.name = node.data('label')
      nodeTooltip.value.type = node.data('type')

      const position = node.renderedPosition()
      const cyContainerRect = cyContainer.value.getBoundingClientRect()
      nodeTooltip.value.position = {
        left: position.x + cyContainerRect.left,
        top: position.y + cyContainerRect.top,
      }
      nodeTooltip.value.visible = true
    }
  })

  cy.value.on('mouseout', 'node', function (event) {
    const node = event.target
    node.removeClass('highlighted')
    node.outgoers().removeClass('highlighted')
    node.outgoers('edge').removeClass('highlighted')
    nodeTooltip.value.visible = false
  })

  cy.value.on('mouseover', 'edge', function (event) {
    const edge = event.target
    if (cyContainer.value) {
      edgeTooltip.value.details = edge.data('details')
      edgeTooltip.value.source_name = edge.source().data('label')
      edgeTooltip.value.target_name = edge.target().data('label')
      const cyContainerRect = cyContainer.value.getBoundingClientRect()
      const mouseX = event.renderedPosition.x
      const mouseY = event.renderedPosition.y
      edgeTooltip.value.position = {
        left: mouseX + cyContainerRect.left,
        top: mouseY + cyContainerRect.top,
      }
      edgeTooltip.value.visible = true
    }
  })

  cy.value.on('mouseout', 'edge', function () {
    edgeTooltip.value.visible = false
  })

  cy.value.zoom(0.7)
  cy.value.center()
})
</script>

<style lang="scss">
.container {
  position: relative;
  height: 90%;
  width: 100%;
  box-shadow: 0 0 4px 0 rgba(0, 0, 0, 0.49);
}

.cy-container {
  height: 100%;
  width: 100%;
  position: absolute;
  top: 0;
  left: 0;
  bottom: 0;
  right: 0;
}

.object-node {
  display: flex;
  align-items: center;
  background-color: white;
  box-shadow: 0 0 4px 0 rgba(0, 0, 0, 1);
  padding: 5px;
  width: 250px;
  height: 75px;
  border-radius: 5px;
}

.object-label {
  display: inline-block;
  font-weight: 600;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.highlighted-node {
  background-color: rgba(18, 171, 237, 0.31) !important;
  box-shadow: 0 0 4px 0 rgba(18, 171, 237, 0.31);
  border-color: #000 !important;
  border-width: 2px !important;
}

.lineage-object-tooltip td,
.lineage-object-tooltip th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

.lineage {
  height: 100%;
}

.sliders-card {
  height: 10%;
  display: flex;
  align-items: center;
  justify-content: center;
}

.slider-container {
  width: 50%;
  padding: 0 2rem;
}

.hidden {
  display: none;
}
</style>
