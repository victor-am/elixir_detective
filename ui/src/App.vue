<template>
  <div id="app">
    <div class="toolbar">
      <el-form class="search-bar" @submit.native.prevent="entitySearchTerm = visualEntitySearchTerm">
        <h1 class="logo"><Logo/> Elixir Detective</h1>

        <el-form-item>
          <el-input v-model="visualEntitySearchTerm" placeholder="Search for modules and files..."/>
          <p class="sort-by-label">Sort by</p>
          <el-radio-group class="sort-radio" v-model="sortCriteria" size="mini">
            <el-radio-button label="dependents">Dependents</el-radio-button>
            <el-radio-button label="linesOfCode">LoC</el-radio-button>
            <el-radio-button label="dependencies">Dependencies</el-radio-button>
            <el-radio-button label="selection">Selection</el-radio-button>
          </el-radio-group>
        </el-form-item>
      </el-form>

      <ul class="entity-list" ref="classList">
        <li class="results-stats">
          {{ filteredEntities.length }} results found
        </li>
        <li class="entity-item" v-for="entity in filteredEntities" :key="entity.full_name" :ref="'entity-card-' + entity.full_name">
          <EntityCard
            :entity="entity"
            @clickToggleGraph="toggleEntityFromGraph"
            :isSelected="isSelected(entity)"/>
        </li>
      </ul>
    </div>

    <el-button size="mini" @click="clearGraph" class="clear-graph-button">Clear {{ graphSelectedEntities.length }} items selected</el-button>
    <el-button size="mini" @click="selectFullGraph" class="full-graph-button">Show full project graph</el-button>
    <DependencyGraph
      class="graph"
      @nodeSelected="scrollToEntityCard"
      @nodeDoubleClicked="addToGraphByFullName"
      :classesData="classesFilteredBySelection"
      :selectedEntities="graphSelectedEntities"/>
  </div>
</template>

<script>
import Fuse from 'fuse.js'

import DependencyGraph from './components/DependencyGraph.vue'
import EntityCard from './components/EntityCard.vue'
import Logo from './assets/logo.svg';

import uniq from 'lodash/uniq'

export default {
  name: 'app',
  components: {
    DependencyGraph,
    EntityCard,
    Logo
  },
  data() {
    return {
      allEntitiesData: window.CLASSES_DATA,
      entitySearchTerm: '',
      visualEntitySearchTerm: '',
      graphSelectedEntities: [],
      sortCriteria: ''
    }
  },

  watch: {
    entitySearchTerm() {
      this.$nextTick(() => { this.$refs.classList.scrollTop = 0 });
    }
  },

  computed: {
    fuzzySearcher() {
      const options = { threshold: 0.2, keys: ['full_name', 'file_path'] }
      return new Fuse(this.allEntitiesData, options)
    },
    filteredEntities() {
      if (this.entitySearchTerm == '') {
        return this.sortEntities(this.allEntitiesData)
      } else {
        const searchResults = this.fuzzySearcher.search(this.entitySearchTerm)
        return this.sortEntities(searchResults)
      }
    },
    classesFilteredBySelection() {
      const dependentsAndDependencies = this.dependentsAndDependenciesOf(this.graphSelectedEntities)
      const dataset = this.graphSelectedEntities.concat(dependentsAndDependencies)

      return uniq(dataset, 'full_name')
    },
    graphSelectedEntityNames() {
      return this.graphSelectedEntities.map((c) => c.full_name)
    }
  },

  methods: {
    toggleEntityFromGraph(entity) {
      if (this.isSelected(entity)) {
        this.graphSelectedEntities = this.graphSelectedEntities.filter((c) => c.full_name != entity.full_name)
      } else {
        this.graphSelectedEntities.push(entity)
      }
    },
    addToGraphByFullName({ nodeId }) {
      const entity = this.allEntitiesData.find((c) => c.full_name == nodeId)
      if (!this.isSelected(entity)) { this.graphSelectedEntities.push(entity) }
    },
    scrollToEntityCard({ nodeId }) {
      const element = this.$refs[`entity-card-${nodeId}`][0]
      this.$nextTick(() => { element.scrollIntoView() });
    },
    selectFullGraph() {
      this.graphSelectedEntities = this.allEntitiesData
    },
    clearGraph() {
      this.graphSelectedEntities = []
    },
    sortEntities(collection) {
      return collection.slice().sort(this.entitySortFunction)
    },
    entitySortFunction(a, b) {
      const criteria = this.sortCriteria

      if (criteria == 'dependents') {
        return b.dependents.length - a.dependents.length;
      } else if (criteria == 'dependencies') {
        return b.dependencies.length - a.dependencies.length;
      } else if (criteria == 'linesOfCode') {
        return b.lines_of_code - a.lines_of_code;
      } else if (criteria == 'selection') {
        return (a === b)? 0 : this.isSelected(a)? -1 : 1;
      } else {
        return 0
      }
    },
    dependentsAndDependenciesOf(entities) {
      const dependentsAndDependencies = entities.map((selectedEntity) => {
        return this.allEntitiesData.filter((anotherEntity) => {
          return anotherEntity.dependencies.includes(selectedEntity.full_name) ||
          selectedEntity.dependencies.includes(anotherEntity.full_name)
        })
      }).flat()

      return uniq(dependentsAndDependencies, 'full_name')
    },
    isSelected(entity) {
      return this.graphSelectedEntityNames.includes(entity.full_name)
    }
  }
}
</script>

<style>
/*! minireset.css v0.0.6 | MIT License | github.com/jgthms/minireset.css */html,body,p,ol,ul,li,dl,dt,dd,blockquote,figure,fieldset,legend,textarea,pre,iframe,hr,h1,h2,h3,h4,h5,h6{margin:0;padding:0}h1,h2,h3,h4,h5,h6{font-size:100%;font-weight:normal}ul{list-style:none}button,input,select,textarea{margin:0}html{box-sizing:border-box}*,*::before,*::after{box-sizing:inherit}img,video{height:auto;max-width:100%}iframe{border:0}table{border-collapse:collapse;border-spacing:0}td,th{padding:0}td:not([align]),th:not([align]){text-align:left}

h1 { font-size: 20px; }
h2 { font-size: 18px; }
h3 { font-size: 16px; }
h4 { font-size: 14px; }

#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #2c3e50;
  display: flex;
  height: 100vh;
  width: 100vw;
}

.logo {
  margin: 10px 0 10px 0;
  display: flex;
  align-items: center;
  justify-content: center;
  padding-right: 25px;
}

.logo svg {
  margin-right: 5px;
  width: 38px;
  height: 50px;
}

.toolbar {
  width: 25%;
  min-width: 380px;
  height: 100%;
  display: flex;
  flex-direction: column;
  position: absolute;
  top: 0;
  bottom: 0;
  left: 0;
  z-index: 1;
}

.toolbar .search-bar {
  width: 100%;
  border-bottom-right-radius: 11px;
  padding: 0 15px 0 15px;
  background-color: rgba(255,255,255,0.9);
  box-shadow: #00000026 2px 2px 3px;
  z-index: 2;
}

.toolbar .entity-list {
  padding-top: 10px;
  overflow-y: scroll;
  height: auto;
}

.graph {
  width: 100%;
}

.entity-item {
  margin: 0 20px 10px 15px;
}

.clear-graph-button {
  position: absolute;
  right: 15px;
  top: 10px;
  z-index: 1;
}

.full-graph-button {
  position: absolute;
  right: 15px;
  top: 45px;
  z-index: 2;
}

.results-stats {
  text-align: center;
  margin-bottom: 10px;
  font-weight: bold;
}

.sort-radio {
  width: 100%;
  display: flex !important;
  justify-content: center;
}

.sort-by-label {
  text-align: center;
  font-weight: bold;
  line-height: 23px;
}
</style>
