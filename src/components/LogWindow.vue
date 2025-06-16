<template>
  <div class="log-window" :class="{ 'log-window-collapsed': isCollapsed }">
    <div class="log-header" @click="toggleCollapse">
      <span class="log-title">Log Window</span>
      <span class="collapse-icon">{{ isCollapsed ? '▼' : '▲' }}</span>
    </div>
    <div class="log-content" v-show="!isCollapsed">
      <div v-for="(log, index) in logs" :key="index" class="log-item" :class="log.type">
        <span class="log-time">{{ log.time }}</span>
        <span class="log-message">{{ log.message }}</span>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const isCollapsed = ref(false)
const logs = ref([])

function toggleCollapse() {
  isCollapsed.value = !isCollapsed.value
}

function addLog(message, type = 'info') {
  const now = new Date()
  const time = now.toLocaleTimeString()
  logs.value.unshift({ time, message, type })
  // 限制日志数量，最多显示100条
  if (logs.value.length > 100) {
    logs.value.pop()
  }
}

// 暴露方法给父组件
defineExpose({
  addLog
})
</script>

<style scoped>
.log-window {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background: #1e1e1e;
  color: #fff;
  border-top: 2px solid #333;
  transition: height 0.3s ease;
  height: 200px;
  z-index: 1000;
}

.log-window-collapsed {
  height: 32px;
}

.log-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 8px 16px;
  background: #2d2d2d;
  cursor: pointer;
  user-select: none;
}

.log-title {
  font-weight: bold;
}

.collapse-icon {
  font-size: 12px;
}

.log-content {
  height: calc(100% - 32px);
  overflow-y: auto;
  padding: 8px;
  font-family: monospace;
}

.log-item {
  margin: 4px 0;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 14px;
}

.log-time {
  color: #888;
  margin-right: 8px;
}

.log-message {
  color: #fff;
}

.log-item.info {
  background: rgba(0, 120, 255, 0.1);
}

.log-item.success {
  background: rgba(0, 200, 0, 0.1);
}

.log-item.error {
  background: rgba(255, 0, 0, 0.1);
}

.log-item.warning {
  background: rgba(255, 165, 0, 0.1);
}
</style> 