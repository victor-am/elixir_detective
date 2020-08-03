<template>
  <div>
    <div class="graph-toolbar">
      <el-checkbox v-model="showSecundaryDependencyNodes">Show second-level dependency nodes</el-checkbox>
      <el-checkbox v-model="showSecundaryDependencyEdges">Show second-level dependency edges</el-checkbox>
    </div>

    <div id="dependency-graph"></div>
  </div>
</template>

<script>
import vis from 'vis-network'
import differenceWith from 'lodash/differenceWith'

let graph

const GRAPH_OPTIONS = {
  physics: {
    solver: "barnesHut",
    stabilization: false,
    barnesHut: { gravitationalConstant: -80000, springConstant: 0.001, springLength: 200 }
  },
  nodes: {
    shape: "dot",
    scaling: {
      min: 10,
      max: 60,
      label: {
        min: 30,
        max: 30,
        drawThreshold: 0,
        maxVisible: 0
      }
    },
    font: {
      size: 12,
      face: "Tahoma"
    }
  },
  edges: {
    width: 0.15,
    color: { inherit: "from" },
    smooth: false,
    arrows: 'to'
  },
  interaction: {
    hideEdgesOnDrag: true,
    hideEdgesOnZoom: true
  }
}

export default {
  name: 'DependencyGraph',
  props: {
    classesData: Array,
    selectedEntities: Array
  },
  data() {
    return {
      graph: null,
      showSecundaryDependencyNodes: true,
      showSecundaryDependencyEdges: true,
      nodesDataset: null,
      edgesDataset: null
    }
  },

  mounted() {
    this.buildGraph()
  },

  watch: {
    dependencyGraphData() {
      graph ? this.updateGraph() : this.buildGraph()
    }
  },

  computed: {
    dependencyGraphData() {
      const skipSecundaryNodesIfOptionDemandsIt = (entity) => this.showSecundaryDependencyNodes || this.isPrimaryDependencyNode(entity)

      const nodes = this.classesData
        .filter(skipSecundaryNodesIfOptionDemandsIt)
        .map((entity) => {
          return {
            id: entity.full_name,
            label: entity.full_name,
            title: entity.full_name,
            value: entity.lines_of_code,
            group: entity.namespace
          }
        })

      const edges = this.classesData
        .map((dependent) => {
          return dependent.dependencies
            .filter((dependency) => this.showSecundaryDependencyEdges || this.isPrimaryDependencyEdge(dependent.full_name, dependency))
            .map((dependency_name) => { return { from: dependent.full_name, to: dependency_name } })
        })
        .flat()

      return { nodes, edges }
    }
  },

  methods: {
    buildGraph() {
      const container = document.getElementById("dependency-graph");
      this.nodesDataset = new vis.DataSet(this.dependencyGraphData.nodes);
      this.edgesDataset = new vis.DataSet(this.dependencyGraphData.edges);
      const data = { nodes: this.nodesDataset, edges: this.edgesDataset }

      graph = new vis.Network(container, data, GRAPH_OPTIONS);

      graph.on("doubleClick", ({ nodes }) => {
        if (nodes[0]) { this.$emit("nodeDoubleClicked", { nodeId: nodes[0] }) }
      })
      graph.on("selectNode", ({ nodes }) => {
        if (nodes[0]) { this.$emit("nodeSelected", { nodeId: nodes[0] }) }
      })

      graph.moveTo({ scale: 0.5, offset: { x: 200, y: 0 }})
    },

    updateGraph() {
      const hasSameId = (a, b) => a.id === b.id

      const currentlyDrawnNodes = this.nodesDataset.get()
      const nodes = this.dependencyGraphData.nodes
      const extraNodes = differenceWith(currentlyDrawnNodes, nodes, hasSameId)
      const missingNodes = differenceWith(nodes, currentlyDrawnNodes, hasSameId)
      this.nodesDataset.add(missingNodes)
      this.nodesDataset.remove(extraNodes)

      const currentlyDrawnEdges = this.edgesDataset.get()
      const edges = this.dependencyGraphData.edges
      const extraEdges = differenceWith(currentlyDrawnEdges, edges, hasSameId)
      const missingEdges = differenceWith(edges, currentlyDrawnEdges, hasSameId)
      this.edgesDataset.add(missingEdges)
      this.edgesDataset.remove(extraEdges)
    },

    isPrimaryDependencyNode(entity) {
      const selectedEntities = this.selectedEntities.map((c) => c.full_name)
      return selectedEntities.includes(entity.full_name)
    },

    isPrimaryDependencyEdge(dependent_name, dependency_name) {
      const selectedEntities = this.selectedEntities.map((c) => c.full_name)
      return selectedEntities.includes(dependency_name) || selectedEntities.includes(dependent_name)
    }
  }
}
</script>

<style scoped>
#dependency-graph {
  width: 100%;
  height: 100%;
  z-index: -1;
}

.graph-toolbar {
  position: absolute;
  top: 80px;
  width: 270px;
  right: 15px;
  z-index: 1;
}

.graph-toolbar .el-checkbox {

}
</style>
