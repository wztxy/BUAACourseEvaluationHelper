<template>
  <view class="container">
    <view class="logo">
      <text class="title">北航评教助手</text>
    </view>
    <view class="form">
      <input v-model="username" placeholder="统一认证用户名" />
      <input v-model="password" type="password" placeholder="密码" />
      <button @click="handleLogin" :loading="loading">登录</button>
    </view>
    <text v-if="error" class="error">{{ error }}</text>
  </view>
</template>

<script setup>
import { ref } from 'vue'
import { login } from '@/api/auth'

const username = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  if (!username.value || !password.value) {
    error.value = '请输入用户名和密码'
    return
  }
  loading.value = true
  error.value = ''
  const res = await login(username.value, password.value)
  loading.value = false
  if (res.success) {
    uni.redirectTo({ url: '/pages/index/index' })
  } else {
    error.value = res.msg
  }
}
</script>

<style scoped>
.container { padding: 40px 20px; }
.logo { text-align: center; margin-bottom: 40px; }
.title { font-size: 24px; font-weight: bold; }
.form input { margin-bottom: 15px; padding: 12px; border: 1px solid #ddd; border-radius: 8px; }
.form button { width: 100%; background: #007aff; color: #fff; }
.error { color: red; text-align: center; margin-top: 10px; }
</style>
