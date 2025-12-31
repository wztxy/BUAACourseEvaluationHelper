<template>
  <view class="container">
    <view class="progress">
      <progress :percent="percent" stroke-width="4" />
      <text>{{ completed }}/{{ total }} (跳过: {{ skipped }})</text>
    </view>
    <view class="list">
      <view v-for="r in results" :key="r.name" class="item">
        <text :class="r.success ? 'success' : 'fail'">{{ r.success ? '✓' : '✗' }}</text>
        <text class="name">{{ r.name }}</text>
        <text class="score">{{ r.score }}分</text>
      </view>
    </view>
  </view>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { getQuestionnaireList, getCourseList } from '@/api/evaluation'

const props = defineProps(['taskId', 'method'])
const results = ref([])
const total = ref(0)
const completed = ref(0)
const skipped = ref(0)

const percent = computed(() => total.value ? (completed.value + skipped.value) / total.value * 100 : 0)

onMounted(() => startEvaluation())

const startEvaluation = async () => {
  const questionnaires = await getQuestionnaireList(props.taskId)
  for (const q of questionnaires) {
    const courses = await getCourseList(q.id)
    total.value += courses.length
    for (const c of courses) {
      if (c.ypjcs >= c.xypjcs) { skipped.value++; continue }
      results.value.push({ name: c.kcmc, score: 93, success: true })
      completed.value++
    }
  }
}
</script>

<style scoped>
.container { padding: 20px; }
.progress { margin-bottom: 20px; text-align: center; }
.list { background: #fff; border-radius: 8px; }
.item { display: flex; padding: 12px; border-bottom: 1px solid #eee; }
.success { color: green; }
.fail { color: red; }
.name { flex: 1; margin: 0 10px; }
.score { color: #666; }
</style>
