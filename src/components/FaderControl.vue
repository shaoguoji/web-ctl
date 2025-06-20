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
const pos = ref(0)
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
  }, 50) // 50ms 防抖
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
  width: 100%;
}

.fader-pos {
  display: flex;
  flex-direction: row;
  align-items: center;
  margin-bottom: 16px;
  width: 100%;
  justify-content: center;
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

/* 响应式布局 - 平板设备 */
@media (max-width: 1024px) {
  .fader-panel {
    height: 400px;
    padding: 20px 14px 14px 14px;
  }
  
  .fader-slider {
    width: 340px;
    height: 36px;
  }
  
  .slider-area {
    height: 400px;
  }
  
  .fader-input {
    width: 55px;
    font-size: 1em;
  }
}

/* 响应式布局 - 手机设备 */
@media (max-width: 768px) {
  .fader-panel {
    height: 350px;
    padding: 16px 12px 12px 12px;
    min-width: auto;
    max-width: 150px;
  }
  
  .fader-slider {
    width: 300px;
    height: 32px;
  }
  
  .slider-area {
    height: 350px;
  }
  
  .fader-pos {
    margin-bottom: 12px;
  }
  
  .fader-input {
    width: 50px;
    font-size: 0.9em;
  }
}

/* 响应式布局 - 小屏手机 */
@media (max-width: 480px) {
  .fader-panel {
    height: 300px;
    padding: 12px 10px 10px 10px;
    max-width: 120px;
  }
  
  .fader-slider {
    width: 260px;
    height: 28px;
  }
  
  .slider-area {
    height: 300px;
  }
  
  .fader-pos {
    margin-bottom: 10px;
  }
  
  .fader-input {
    width: 45px;
    font-size: 0.8em;
  }
}

/* 响应式布局 - 超小屏手机 */
@media (max-width: 360px) {
  .fader-panel {
    height: 250px;
    padding: 10px 8px 8px 8px;
    max-width: 100px;
  }
  
  .fader-slider {
    width: 220px;
    height: 24px;
  }
  
  .slider-area {
    height: 250px;
  }
  
  .fader-pos {
    margin-bottom: 8px;
  }
  
  .fader-input {
    width: 40px;
    font-size: 0.7em;
  }
}

/* 横屏模式优化 */
@media (max-height: 500px) and (orientation: landscape) {
  .fader-panel {
    height: 200px;
    padding: 8px 6px 6px 6px;
  }
  
  .fader-slider {
    width: 180px;
    height: 20px;
  }
  
  .slider-area {
    height: 200px;
  }
  
  .fader-pos {
    margin-bottom: 6px;
  }
  
  .fader-input {
    width: 35px;
    font-size: 0.6em;
  }
}
</style> 