<script setup>
import { ref, provide } from 'vue'
import PidControl from './components/PidControl.vue'
import FaderControl from './components/FaderControl.vue'
import LogWindow from './components/LogWindow.vue'

// WebSocket 连接相关
const wsUrl = ref('ws://192.168.2.79:1234/')
const ws = ref(null)
const wsStatus = ref('disconnected')
const logWindow = ref(null)
const pidControl = ref(null)
const faderControl = ref(null)

function sendWSData(data) {
  if (ws.value && wsStatus.value === 'connected') {
    ws.value.send(JSON.stringify(data))
    logWindow.value?.addLog(`发送数据: ${JSON.stringify(data)}`, 'info')
  } else {
    logWindow.value?.addLog('WebSocket未连接，无法发送数据', 'error')
  }
}

// 提供给子组件使用
provide('sendWSData', sendWSData)

function connectWS() {
  if (ws.value) {
    ws.value.close()
  }
  wsStatus.value = 'connecting'
  
  // 确保URL格式正确
  let url = wsUrl.value.trim()
  if (!url.startsWith('ws://') && !url.startsWith('wss://')) {
    url = 'ws://' + url
  }
  
  logWindow.value?.addLog(`正在连接到 ${url}`, 'info')
  ws.value = new WebSocket(url)
  ws.value.onopen = () => {
    wsStatus.value = 'connected'
    logWindow.value?.addLog('WebSocket连接成功', 'success')
  }
  ws.value.onclose = () => {
    wsStatus.value = 'disconnected'
    logWindow.value?.addLog('WebSocket连接已断开', 'warning')
  }
  ws.value.onerror = (error) => {
    wsStatus.value = 'error'
    logWindow.value?.addLog(`WebSocket连接错误: ${error.message || '未知错误'}`, 'error')
  }
  ws.value.onmessage = (event) => {
    logWindow.value?.addLog(`收到数据: ${event.data}`, 'info')
    try {
      const data = JSON.parse(event.data)
      if (data.type === 'pid') {
        pidControl.value?.updatePid(data)
      } else if (data.type === 'fader') {
        faderControl.value?.updatePosition(data.position)
      }
    } catch (e) {
      logWindow.value?.addLog(`解析消息失败: ${e.message}`, 'error')
    }
  }
}

function disconnectWS() {
  if (ws.value) {
    ws.value.close()
    ws.value = null
  }
  wsStatus.value = 'disconnected'
  logWindow.value?.addLog('WebSocket已断开连接', 'warning')
}
</script>

<template>
  <div class="main-layout">
    <h1 class="title">Smart Fader Control Panel</h1>
    <!-- WebSocket 连接参数配置区 -->
    <div class="ws-config">
      <label>WebSocket URL: 
        <input 
          v-model="wsUrl" 
          class="ws-input" 
          placeholder="ws://127.0.0.1:1234/"
          style="width: 200px;"
        />
      </label>
      <button @click="connectWS" :disabled="wsStatus==='connected' || wsStatus==='connecting'">连接</button>
      <button @click="disconnectWS" :disabled="wsStatus!=='connected'">断开</button>
      <span class="ws-status" :data-status="wsStatus">{{ wsStatus }}</span>
    </div>
    <div class="control-panels">
      <div class="left-panel">
        <PidControl ref="pidControl" />
      </div>
      <div class="right-panel">
        <FaderControl ref="faderControl" />
      </div>
    </div>
    <LogWindow ref="logWindow" />
  </div>
</template>

<style scoped>
.main-layout {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-height: 100vh;
  background: #fafcff;
  padding: 32px;
  padding-bottom: 232px; /* 为日志窗口留出空间 */
}

.ws-config {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 18px;
  flex-wrap: wrap;
  justify-content: center;
}

.ws-input {
  width: 200px;
  margin-left: 4px;
  margin-right: 8px;
  padding: 2px 6px;
  border: 1px solid #aaa;
  border-radius: 4px;
}

.ws-status[data-status='connected'] { color: green; }
.ws-status[data-status='disconnected'] { color: #888; }
.ws-status[data-status='connecting'] { color: orange; }
.ws-status[data-status='error'] { color: red; }

.control-panels {
  display: flex;
  flex-direction: row;
  justify-content: center;
  gap: 48px;
  margin-top: 32px;
  width: 100%;
  max-width: 1200px;
}

.left-panel {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  min-width: 400px;
  flex: 1;
}

.right-panel {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
}

.title {
  font-size: 2em;
  font-weight: bold;
  text-align: center;
  margin-bottom: 32px;
}

/* 响应式布局 - 平板设备 */
@media (max-width: 1024px) {
  .main-layout {
    padding: 24px;
    padding-bottom: 200px;
  }
  
  .control-panels {
    gap: 32px;
    margin-top: 24px;
  }
  
  .left-panel {
    min-width: 320px;
  }
  
  .title {
    font-size: 1.8em;
    margin-bottom: 24px;
  }
}

/* 响应式布局 - 手机设备 */
@media (max-width: 768px) {
  .main-layout {
    padding: 16px;
    padding-bottom: 180px;
  }
  
  .ws-config {
    flex-direction: column;
    gap: 8px;
    margin-bottom: 16px;
  }
  
  .ws-input {
    width: 100%;
    max-width: 300px;
    margin: 0;
  }
  
  .control-panels {
    flex-direction: column;
    gap: 24px;
    margin-top: 16px;
  }
  
  .left-panel {
    min-width: auto;
    width: 100%;
    align-items: center;
  }
  
  .right-panel {
    width: 100%;
  }
  
  .title {
    font-size: 1.5em;
    margin-bottom: 16px;
  }
}

/* 响应式布局 - 小屏手机 */
@media (max-width: 480px) {
  .main-layout {
    padding: 12px;
    padding-bottom: 160px;
  }
  
  .ws-config {
    gap: 6px;
    margin-bottom: 12px;
  }
  
  .ws-input {
    max-width: 250px;
    font-size: 14px;
  }
  
  .control-panels {
    gap: 16px;
    margin-top: 12px;
  }
  
  .title {
    font-size: 1.3em;
    margin-bottom: 12px;
  }
}

/* 响应式布局 - 超小屏手机 */
@media (max-width: 360px) {
  .main-layout {
    padding: 8px;
    padding-bottom: 140px;
  }
  
  .ws-config {
    gap: 4px;
    margin-bottom: 8px;
  }
  
  .ws-input {
    max-width: 200px;
    font-size: 12px;
  }
  
  .control-panels {
    gap: 12px;
    margin-top: 8px;
  }
  
  .title {
    font-size: 1.1em;
    margin-bottom: 8px;
  }
}
</style>
