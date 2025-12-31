<template>
  <view class="container">
    <view v-if="task" class="task-card">
      <text class="label">当前任务</text>
      <text class="name">{{ task.rwmc }}</text>
    </view>
    <view v-else class="empty">
      <text>暂无评教任务</text>
    </view>

    <view class="method-select">
      <text class="label">评教方式</text>
      <radio-group @change="onMethodChange">
        <label><radio value="good" :checked="method==='good'" />好评 (~93分)</label>
        <label><radio value="bad" :checked="method==='bad'" />及格 (60分)</label>
        <label><radio value="random" :checked="method==='random'" />随机 (60-100)</label>
      </radio-group>
    </view>

    <button @click="startEval" :disabled="!task">开始评教</button>
  </view>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { getLatestTask } from '@/api/evaluation'

const task = ref(null)
const method = ref('good')

onMounted(async () => {
  task.value = await getLatestTask()
})

const onMethodChange = (e) => {
  method.value = e.detail.value
}

const startEval = () => {
  uni.navigateTo({
    url: `/pages/result/result?taskId=${task.value.id}&method=${method.value}`
  })
}
</script>

<style scoped>
.container { padding: 20px; }
.task-card { background: #fff; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
.label { color: #666; font-size: 14px; }
.name { font-size: 16px; margin-top: 5px; }
.method-select { background: #fff; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
.method-select label { display: block; padding: 10px 0; }
button { background: #007aff; color: #fff; }
.empty { text-align: center; padding: 40px; color: #999; }
</style>
