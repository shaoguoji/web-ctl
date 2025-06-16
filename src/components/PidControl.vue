<template>
  <div class="pid-panel">
    <div class="pid-block" v-for="(pid, idx) in pidList" :key="pid.label">
      <div class="pid-title">{{ pid.label }} pid</div>
      <div class="pid-row" v-for="(item, i) in pid.params" :key="item.key">
        <span class="pid-label">{{ item.key }}:</span>
        <input type="range" min="1" max="100" v-model.number="item.value" class="pid-slider" />
        <input type="number" min="1" max="100" v-model.number="item.value" class="pid-input" />
      </div>
      <button class="pid-set" @click="setPid(idx)">SET</button>
    </div>
  </div>
</template>

<script setup>
import { reactive, inject } from 'vue'

const sendWSData = inject('sendWSData')

const pidList = reactive([
  {
    label: 'speed',
    params: [
      { key: 'kp', value: 1 },
      { key: 'ki', value: 1 },
      { key: 'kd', value: 1 },
    ],
  },
  {
    label: 'Pos',
    params: [
      { key: 'kp', value: 1 },
      { key: 'ki', value: 1 },
      { key: 'kd', value: 1 },
    ],
  },
])

function setPid(idx) {
  const data = {
    type: 'pid',
    target: pidList[idx].label,
    params: pidList[idx].params.reduce((acc, param) => {
      acc[param.key] = param.value
      return acc
    }, {})
  }
  sendWSData(data)
}
</script>

<style scoped>
.pid-panel {
  display: flex;
  flex-direction: column;
  gap: 24px;
}
.pid-block {
  border: 3px solid #000;
  border-radius: 8px;
  padding: 16px 24px;
  background: #fff;
  min-width: 320px;
}
.pid-title {
  font-size: 1.4em;
  font-weight: bold;
  margin-bottom: 12px;
  text-align: left;
}
.pid-row {
  display: flex;
  align-items: center;
  margin-bottom: 10px;
}
.pid-label {
  width: 32px;
  font-size: 1.1em;
}
.pid-slider {
  flex: 1;
  margin: 0 10px;
  accent-color: #6cf;
  height: 4px;
}
.pid-input {
  width: 48px;
  text-align: center;
  border: 2px solid #000;
  border-radius: 4px;
  font-size: 1em;
  margin-left: 4px;
}
.pid-set {
  float: right;
  background: #6cf;
  border: none;
  border-radius: 6px;
  padding: 6px 18px;
  font-size: 1.1em;
  font-weight: bold;
  margin-top: 8px;
  cursor: pointer;
}
</style> 