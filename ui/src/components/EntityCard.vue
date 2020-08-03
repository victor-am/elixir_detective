<template>
  <el-card>
    <div slot="header" class="header clearfix">
      <el-tag type="success" size="mini" v-show="isSelected">Selected</el-tag>

      <h3 class="title" :title="entity.full_name">{{ entity.full_name }}</h3>
      <h4 class="sub-title">{{ entity.file_path }}</h4>
    </div>
    <div class="extra-info">
      <p>
        Dependents
        <span class="value">{{ entity.dependents.length }}</span>
      </p>
      <p>
        LoC
        <span class="value">{{ entity.lines_of_code }}</span>
      </p>
      <p>
        Dependencies
        <span class="value">{{ entity.dependencies.length }}</span>
      </p>
    </div>

    <div class="action-bar">
      <el-button class="graph-button" type="text" @click="$emit('clickToggleGraph', entity)">
        <GraphIcon/> {{ toggleGraphLabel }}
      </el-button>
    </div>
  </el-card>
</template>

<script>
import GraphIcon from '@/assets/graph.svg';

export default {
  name: 'EntityCard',
  components: { GraphIcon },
  props: {
    entity: Object,
    isSelected: Boolean
  },
  computed: {
    toggleGraphLabel() {
      return this.isSelected ? "Remove from graph" : "Add to graph"
    }
  }
}
</script>

<style scoped>
.entity-item .extra-info {
  font-size: 14px;
  color: #555;
  display: flex;
  justify-content: space-around;
  margin-bottom: 15px;
}

.extra-info p {
  margin: 5px;
  text-align: center;
}

.extra-info .value {
  font-weight: bold;
  font-size: 18px;
  display: block;
}

.graph-button {
  padding: 3px 0;
}

.header {
  position: relative;
}

.title {
  overflow: hidden;
  text-overflow: ellipsis;
  width: calc(100% - 60px);
}

.header .el-tag {
  position: absolute;
  top: -5px;
  right: -7px;
}

.sub-title {
  font-size: 12px;
  color: #666;
}

.action-bar {
  display: flex;
  justify-content: space-between;
  border-top: 1px solid #eceef6;
  padding-top: 15px;
}
</style>
