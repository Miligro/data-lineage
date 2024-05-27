<template>
  <div class="container">
    <input
      id="zoom-slider"
      type="range"
      min="0.1"
      max="2.0"
      step="0.01"
      value="1.0"
      style="position: absolute; bottom: 20px; right: 20px; z-index: 2"
    />
    <div ref="cyContainer" class="cy-container">
      <v-tooltip
        v-if="nodeTooltip.visible"
        :model-value="nodeTooltip.visible"
        activator="parent"
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
          <table>
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
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import cytoscape from 'cytoscape'
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
const zoomLevel = ref(1.0)

const response = await useApiFetch<ObjectRelationshipsResponseInterface>(
  `/databases/${props.databaseId}/objects/${props.objectId}/relationships`
)

onMounted(() => {
  if (!cyContainer.value) return

  const cy = cytoscape({
    container: cyContainer.value,
    elements: response.relationships,
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

  cy.nodeHtmlLabel([
    {
      query: 'node',
      halign: 'center',
      valign: 'center',
      halignBox: 'center',
      valignBox: 'center',
      tpl: function (data) {
        const node = cy.getElementById(data.id)
        const isHighlighted = node.hasClass('highlighted')
        return `<div class="object-node ${isHighlighted ? 'highlighted-node' : ''}">
                <span class="object-label">${data.label}</span>
              </div>`
      },
    },
  ])

  cy.zoom(zoomLevel.value)
  cy.center()

  const slider = document.getElementById('zoom-slider') as HTMLInputElement
  slider.addEventListener('input', () => {
    zoomLevel.value = parseFloat(slider.value)
    cy.zoom(zoomLevel.value)
    cy.center()
  })

  cy.on('zoom', () => {
    const slider = document.getElementById('zoom-slider') as HTMLInputElement
    slider.value = cy.zoom().toString()
  })

  cy.on('mouseover', 'node', function (event) {
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

  cy.on('mouseout', 'node', function (event) {
    const node = event.target
    node.removeClass('highlighted')
    node.outgoers().removeClass('highlighted')
    node.outgoers('edge').removeClass('highlighted')
    nodeTooltip.value.visible = false
  })

  cy.on('mouseover', 'edge', function (event) {
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

  cy.on('mouseout', 'edge', function () {
    edgeTooltip.value.visible = false
  })

  cy.zoom(0.7)
  cy.center()
})
</script>

<style>
.container {
  position: relative;
  height: 100%;
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

td,
th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}
</style>
