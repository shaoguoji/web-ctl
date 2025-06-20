<template>
  <div class="pid-panel">
    <div class="pid-block" v-for="(pid, idx) in pidList" :key="pid.label">
      <div class="pid-title">{{ pid.label }} pid</div>
      <div class="pid-row" v-for="(item, i) in pid.params" :key="item.key">
        <span class="pid-label">{{ item.key }}:</span>
        <div class="slider-container">
          <input 
            type="range" 
            min="0" 
            max="200" 
            v-model.number="item.sliderValue" 
            class="pid-slider" 
            @input="updatePidValue(idx, i)"
          />
          <div class="slider-labels">
            <span class="slider-min">0.001</span>
            <span class="slider-center">1</span>
            <span class="slider-max">100</span>
          </div>
        </div>
        <input 
          type="number" 
          step="0.001" 
          min="0.001" 
          max="100" 
          v-model.number="item.value" 
          class="pid-input" 
          @input="updateSliderValue(idx, i)"
        />
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
      { key: 'kp', value: 1, sliderValue: 100 },
      { key: 'ki', value: 1, sliderValue: 100 },
      { key: 'kd', value: 1, sliderValue: 100 },
    ],
  },
  {
    label: 'Pos',
    params: [
      { key: 'kp', value: 1, sliderValue: 100 },
      { key: 'ki', value: 1, sliderValue: 100 },
      { key: 'kd', value: 1, sliderValue: 100 },
    ],
  },
])

let lastManualUpdate = Date.now()
let autoSyncTimer = null

// 将实际值转换为滑块值 (0-200)
function valueToSlider(value) {
  if (value <= 1) {
    // 1到0.001映射到100-0 (递减)
    return Math.round(value / 0.999 * 100)
  } else {
    // 1到100映射到100-200 (递增)
    return Math.round(100 + (value - 1) / 99 * 100)
  }
}

// 将滑块值转换为实际值
function sliderToValue(sliderValue) {
  if (sliderValue <= 100) {
    // 100-0映射到1-0.001 (递减)
    return parseFloat((sliderValue / 100 * 0.999).toFixed(3))
  } else {
    // 100-200映射到1-100 (递增)
    return parseFloat((1 + (sliderValue - 100) / 100 * 99).toFixed(3))
  }
}

// 滑块值变化时更新实际值
function updatePidValue(pidIdx, paramIdx) {
  const param = pidList[pidIdx].params[paramIdx]
  param.value = sliderToValue(param.sliderValue)
  lastManualUpdate = Date.now()
}

// 输入框值变化时更新滑块值
function updateSliderValue(pidIdx, paramIdx) {
  const param = pidList[pidIdx].params[paramIdx]
  param.sliderValue = valueToSlider(param.value)
  lastManualUpdate = Date.now()
}

function setPid(idx) {
  lastManualUpdate = Date.now()
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

function updatePid(data) {
  const now = Date.now()
  // 如果距离上次手动更新不到1秒，则不自动同步
  if (now - lastManualUpdate < 1000) {
    return
  }
  
  const pidBlock = pidList.find(p => p.label === data.target)
  if (pidBlock) {
    Object.entries(data.params).forEach(([key, value]) => {
      const param = pidBlock.params.find(p => p.key === key)
      if (param) {
        param.value = parseFloat(value.toFixed(3))
        param.sliderValue = valueToSlider(param.value)
      }
    })
  }
}

// 暴露方法给父组件
defineExpose({
  updatePid
})
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
.slider-container {
  flex: 1;
  margin: 0 10px;
  display: flex;
  flex-direction: column;
}
.pid-slider {
  accent-color: #6cf;
  height: 4px;
  margin-bottom: 4px;
}
.slider-labels {
  display: flex;
  justify-content: space-between;
  font-size: 0.8em;
  color: #666;
}
.slider-min, .slider-center, .slider-max {
  flex: 1;
  text-align: center;
}
.pid-input {
  width: 60px;
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