<script setup>
import { ref, provide } from 'vue'
import PidControl from './components/PidControl.vue'
import FaderControl from './components/FaderControl.vue'
import LogWindow from './components/LogWindow.vue'

// WebSocket 连接相关
const wsUrl = ref('ws://127.0.0.1:1234/')
const ws = ref(null)
const wsStatus = ref('disconnected')
const logWindow = ref(null)

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
  
  logWindow.value?.addLog(`正在连接到 ${wsUrl.value}`, 'info')
  ws.value = new WebSocket(wsUrl.value)
  ws.value.onopen = () => {
    wsStatus.value = 'connected'
    logWindow.value?.addLog('WebSocket连接成功', 'success')
  }
  ws.value.onclose = () => {
    wsStatus.value = 'disconnected'
    logWindow.value?.addLog('WebSocket连接已断开', 'warning')
  }
  ws.value.onerror = () => {
    wsStatus.value = 'error'
    logWindow.value?.addLog('WebSocket连接错误', 'error')
  }
  ws.value.onmessage = (event) => {
    logWindow.value?.addLog(`收到数据: ${event.data}`, 'info')
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
        <PidControl />
      </div>
      <div class="right-panel">
        <FaderControl />
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
}
.left-panel {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  min-width: 400px;
}
.right-panel {
  display: flex;
  flex-direction: column;
  align-items: center;
}
.title {
  font-size: 2em;
  font-weight: bold;
  text-align: center;
  margin-bottom: 32px;
}
</style>
