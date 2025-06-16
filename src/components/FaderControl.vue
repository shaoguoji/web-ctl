<template>
  <div class="fader-panel">
    <div class="slider-area">
      <input type="range" min="0" max="4095" v-model.number="pos" class="fader-slider" />
    </div>
    <div class="fader-pos">
      <span>pos:</span>
      <input 
        type="number" 
        min="0" 
        max="4095" 
        v-model.number="pos" 
        class="fader-input"
        @input="e => {
          const val = parseInt(e.target.value)
          if (val > 4095) e.target.value = 4095
          if (val < 0) e.target.value = 0
        }"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, inject, watch, nextTick } from 'vue'

const sendWSData = inject('sendWSData')
const pos = ref(2048)
let debounceTimer = null
let lastManualUpdate = Date.now()
let isUpdatingFromServer = false

// 监听位置变化并发送数据
watch(pos, (newPos) => {
  // 如果是服务器更新触发的，不发送数据
  if (isUpdatingFromServer) {
    return
  }

  // 确保值在有效范围内
  if (newPos > 4095) {
    pos.value = 4095
    return
  }
  if (newPos < 0) {
    pos.value = 0
    return
  }

  lastManualUpdate = Date.now()
  
  // 清除之前的定时器
  if (debounceTimer) {
    clearTimeout(debounceTimer)
  }
  
  // 设置新的定时器
  debounceTimer = setTimeout(() => {
    const data = {
      type: 'fader',
      position: pos.value
    }
    sendWSData(data)
  }, 100) // 100ms 防抖
})

function updatePosition(newPos) {
  const now = Date.now()
  // 如果距离上次手动更新不到1秒，则不自动同步
  if (now - lastManualUpdate < 1000) {
    return
  }
  
  // 确保值在有效范围内
  if (newPos > 4095) {
    newPos = 4095
  }
  if (newPos < 0) {
    newPos = 0
  }
  
  isUpdatingFromServer = true
  pos.value = newPos
  // 使用 nextTick 确保在下一个事件循环中重置标志
  nextTick(() => {
    isUpdatingFromServer = false
  })
}

// 暴露方法给父组件
defineExpose({
  updatePosition
})
</script>

<style scoped>
.fader-panel {
  display: flex;
  flex-direction: column;
  align-items: center;
  border: 3px solid #000;
  border-radius: 8px;
  padding: 24px 16px 16px 16px;
  background: #fff;
  min-width: 120px;
  max-width: 180px;
  height: 447px;
  justify-content: center;
}
.fader-pos {
  display: flex;
  flex-direction: row;
  align-items: center;
  margin-bottom: 16px;
}
.fader-input {
  width: 60px;
  text-align: center;
  border: 2px solid #000;
  border-radius: 4px;
  font-size: 1.1em;
  margin-left: 8px;
}
.slider-area {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 100%;
  height: 450px;
}
.fader-slider {
  /* 兼容性更好的垂直slider实现 */
  transform: rotate(-90deg);
  width: 380px;
  height: 40px;
  accent-color: #6cf;
}
</style> 