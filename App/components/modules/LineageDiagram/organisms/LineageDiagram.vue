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
    <div ref="cyContainer" class="cy-container"></div>
  </div>
</template>

<script lang="ts" setup>
import { onMounted, ref } from 'vue'
import cytoscape from 'cytoscape'
import nodeHtmlLabel from 'cytoscape-node-html-label'

nodeHtmlLabel(cytoscape)

const cyContainer = ref<HTMLElement | null>(null)
const zoomLevel = ref(1.0)

const databaseStore = useDatabaseStore()

const response = await useApiFetch(`/get_lineage_info/${databaseStore.id}`)

onMounted(() => {
  if (!cyContainer.value) return

  const cy = cytoscape({
    container: cyContainer.value,
    elements: [...response.nodes, ...response.edges],
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
  })

  cy.on('mouseout', 'node', function (event) {
    const node = event.target
    node.removeClass('highlighted')
    node.outgoers().removeClass('highlighted')
    node.outgoers('edge').removeClass('highlighted')
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
  box-shadow: 0 0 10px 0 rgba(0, 0, 0, 1);
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
</style>
