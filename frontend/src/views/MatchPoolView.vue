<template>
  <div class="match-pool-container">
    <div class="glass-card">
      <h1>匹配池</h1>
      
      <div class="pool-content">
        <div class="geometry-animation">
          <div class="polygon-ring ring-1"></div>
          <div class="polygon-ring ring-2"></div>
          <div class="polygon-ring ring-3"></div>
          <div 
            class="ripple" 
            v-for="i in 3" 
            :key="'ripple-'+i"
            :style="getRippleStyle(i)"
          ></div>
          <div class="center-core"></div>
        </div>
        
        <div class="countdown-text">
          <p class="countdown-label">距离下一次分配</p>
          <div class="countdown-time">
            <span class="time-unit">
              <span class="time-value">{{ countdown.days }}</span>
              <span class="time-label">天</span>
            </span>
            <span class="time-separator">:</span>
            <span class="time-unit">
              <span class="time-value">{{ countdown.hours }}</span>
              <span class="time-label">时</span>
            </span>
            <span class="time-separator">:</span>
            <span class="time-unit">
              <span class="time-value">{{ countdown.minutes }}</span>
              <span class="time-label">分</span>
            </span>
          </div>
          <p class="match-schedule">匹配时间：每周二、周五 0:00</p>
        </div>
      </div>
      
      <div class="match-results" v-if="matchResults.length > 0">
        <h2>我的匹配结果</h2>
        <div class="results-list">
          <div class="result-card" v-for="result in matchResults" :key="result.id">
            <div class="result-avatar">{{ result.matched_user_name.charAt(0) }}</div>
            <div class="result-info">
              <h3>{{ result.matched_user_name }}</h3>
              <p>匹配度：{{ result.match_score }}%</p>
              <p>交友目的：{{ result.intent_type || '朋友' }}</p>
              <p>邮箱：{{ result.email }}</p>
              <p class="match-time">{{ formatTime(result.created_at) }}</p>
            </div>
          </div>
        </div>
      </div>
      
      <div class="no-results" v-else>
        <p>暂无匹配结果，请等待下一次分配</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import axios from 'axios'
import { API_ENDPOINTS } from '../config/api.js'

const countdown = ref({
  days: 0,
  hours: 0,
  minutes: 0
})

const matchResults = ref([])
let timer = null
const rippleParams = ref([])

// 初始化波纹参数
const initRippleParams = () => {
  rippleParams.value = []
  for (let i = 0; i < 3; i++) {
    rippleParams.value.push({
      scaleX: 0.7 + Math.random() * 0.6, // 0.7-1.3
      scaleY: 0.7 + Math.random() * 0.6, // 0.7-1.3
      rotation: Math.random() * 360, // 0-360度
      animationDelay: i * 1 // 每个波纹延迟1秒
    })
  }
}

// 获取波纹样式
const getRippleStyle = (index) => {
  if (!rippleParams.value[index - 1]) return {}
  const params = rippleParams.value[index - 1]
  return {
    '--scale-x': params.scaleX,
    '--scale-y': params.scaleY,
    '--rotation': `${params.rotation}deg`,
    'animation-delay': `${params.animationDelay}s`
  }
}

const calculateNextMatch = () => {
  const now = new Date()
  const dayOfWeek = now.getDay()
  const hours = now.getHours()
  const minutes = now.getMinutes()
  
  let daysUntilNextMatch = 0
  let targetDay = 0
  
  if (dayOfWeek === 2) {
    if (hours < 0 || (hours === 0 && minutes === 0)) {
      targetDay = 2
    } else {
      targetDay = 5
    }
  } else if (dayOfWeek === 5) {
    if (hours < 0 || (hours === 0 && minutes === 0)) {
      targetDay = 5
    } else {
      targetDay = 2
      daysUntilNextMatch = 4
    }
  } else if (dayOfWeek < 2) {
    targetDay = 2
    daysUntilNextMatch = 2 - dayOfWeek
  } else if (dayOfWeek < 5) {
    targetDay = 5
    daysUntilNextMatch = 5 - dayOfWeek
  } else {
    targetDay = 2
    daysUntilNextMatch = 2 + (7 - dayOfWeek)
  }
  
  const nextMatch = new Date(now)
  nextMatch.setDate(now.getDate() + daysUntilNextMatch)
  nextMatch.setHours(0, 0, 0, 0)
  
  const diff = nextMatch - now
  const days = Math.floor(diff / (1000 * 60 * 60 * 24))
  const hoursLeft = Math.floor((diff % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60))
  const minutesLeft = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))
  
  countdown.value = {
    days: days,
    hours: hoursLeft,
    minutes: minutesLeft
  }
}

const fetchMatchResults = async () => {
  try {
    const userId = localStorage.getItem('userId')
    if (!userId) return

    const response = await axios.get(API_ENDPOINTS.matches(userId))
    if (response.data.status === 'success') {
      matchResults.value = response.data.matches
    }
  } catch (error) {
    console.error('获取匹配结果失败:', error)
  }
}

const formatTime = (timestamp) => {
  const date = new Date(timestamp)
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
}



onMounted(() => {
  initRippleParams()
  calculateNextMatch()
  timer = setInterval(calculateNextMatch, 60000)
  fetchMatchResults()
})

onUnmounted(() => {
  if (timer) {
    clearInterval(timer)
  }
})
</script>

<style scoped>
.match-pool-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 20px;
}

.glass-card {
  background: rgba(255, 255, 255, 0.25);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 40px;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
  border: 1px solid rgba(255, 255, 255, 0.18);
}

h1 {
  text-align: center;
  font-size: 32px;
  color: #1E293B;
  margin-bottom: 40px;
}

.pool-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 40px;
}

.geometric-animation {
  width: 200px;
  height: 200px;
  position: relative;
  margin-bottom: 30px;
  overflow: visible;
}

.polygon-ring {
  position: absolute;
  border-radius: 50%;
  border: 2px solid transparent;
  animation: ringRotate 8s linear infinite, ringWobble 3s ease-in-out infinite;
}

.ring-1 {
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  border-top-color: #2563EB;
  border-right-color: #3B82F6;
  animation-duration: 8s, 3s;
}

.ring-2 {
  width: 75%;
  height: 75%;
  top: 12.5%;
  left: 12.5%;
  border-bottom-color: #60A5FA;
  border-left-color: #93C5FD;
  animation-duration: 6s, 4s;
  animation-direction: reverse, normal;
}

.ring-3 {
  width: 50%;
  height: 50%;
  top: 25%;
  left: 25%;
  border-top-color: #BFDBFE;
  border-right-color: #2563EB;
  animation-duration: 4s, 5s;
}

.ripple {
  position: absolute;
  border-radius: 50%;
  border: 2px solid #2563EB;
  top: 50%;
  left: 50%;
  opacity: 0;
  animation: rippleExpand 3s ease-out infinite;
  transform: translate(-50%, -50%) rotate(var(--rotation, 0deg)) scaleX(var(--scale-x, 1)) scaleY(var(--scale-y, 1));
}

@keyframes rippleExpand {
  0% {
    width: 0;
    height: 0;
    opacity: 0.8;
    border-width: 2px;
  }
  100% {
    width: 200px;
    height: 200px;
    opacity: 0;
    border-width: 0.5px;
  }
}

.center-core {
  position: absolute;
  width: 20px;
  height: 20px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  background: radial-gradient(circle, #2563EB 0%, transparent 70%);
  border-radius: 50%;
  animation: corePulse 2s ease-in-out infinite;
}

@keyframes ringRotate {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

@keyframes ringWobble {
  0%, 100% {
    transform: rotate(0deg) translate(0, 0);
  }
  25% {
    transform: rotate(90deg) translate(3px, -3px);
  }
  50% {
    transform: rotate(180deg) translate(-2px, 2px);
  }
  75% {
    transform: rotate(270deg) translate(2px, 3px);
  }
}

@keyframes corePulse {
  0%, 100% {
    transform: translate(-50%, -50%) scale(1);
    opacity: 0.8;
  }
  50% {
    transform: translate(-50%, -50%) scale(1.5);
    opacity: 1;
  }
}

.countdown-text {
  text-align: center;
}

.countdown-label {
  font-size: 18px;
  color: #64748B;
  margin-bottom: 15px;
}

.countdown-time {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  margin-bottom: 15px;
}

.time-unit {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.time-value {
  font-size: 48px;
  font-weight: bold;
  color: #2563EB;
  background: rgba(37, 99, 235, 0.1);
  padding: 10px 20px;
  border-radius: 10px;
  min-width: 80px;
  text-align: center;
}

.time-label {
  font-size: 14px;
  color: #64748B;
  margin-top: 5px;
}

.time-separator {
  font-size: 36px;
  color: #2563EB;
  font-weight: bold;
}

.match-schedule {
  font-size: 14px;
  color: #94A3B8;
  margin-top: 10px;
}

.match-results {
  margin-top: 40px;
}

.match-results h2 {
  font-size: 24px;
  color: #1E293B;
  margin-bottom: 20px;
  text-align: center;
}

.results-list {
  display: flex;
  flex-direction: column;
  gap: 15px;
}

.result-card {
  display: flex;
  align-items: center;
  background: rgba(255, 255, 255, 0.3);
  padding: 20px;
  border-radius: 15px;
  gap: 20px;
}

.result-avatar {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: bold;
  flex-shrink: 0;
}

.result-info {
  flex: 1;
}

.result-info h3 {
  font-size: 18px;
  color: #1E293B;
  margin-bottom: 5px;
}

.result-info p {
  font-size: 14px;
  color: #64748B;
  margin: 3px 0;
}

.match-time {
  font-size: 12px !important;
  color: #94A3B8 !important;
}

.result-actions {
  display: flex;
  gap: 10px;
}

.btn-accept,
.btn-reject {
  padding: 10px 20px;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 14px;
  transition: all 0.3s ease;
}

.btn-accept {
  background: #10B981;
  color: white;
}

.btn-accept:hover {
  background: #059669;
  transform: translateY(-2px);
}

.btn-reject {
  background: #EF4444;
  color: white;
}

.btn-reject:hover {
  background: #DC2626;
  transform: translateY(-2px);
}

.no-results {
  text-align: center;
  padding: 40px;
  color: #64748B;
}

.no-results p {
  font-size: 16px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .glass-card {
    padding: 30px;
  }
  
  h1 {
    font-size: 24px;
  }
  
  .geometric-animation {
    width: 150px;
    height: 150px;
  }
  
  .time-value {
    font-size: 36px;
    padding: 8px 15px;
    min-width: 60px;
  }
  
  .time-separator {
    font-size: 28px;
  }
  
  .result-card {
    flex-direction: column;
    text-align: center;
  }
  
  .result-actions {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .glass-card {
    padding: 20px;
  }
  
  h1 {
    font-size: 20px;
  }
  
  .geometric-animation {
    width: 120px;
    height: 120px;
  }
  
  .time-value {
    font-size: 28px;
    padding: 6px 12px;
    min-width: 50px;
  }
  
  .time-separator {
    font-size: 22px;
  }
  
  .countdown-time {
    gap: 5px;
  }
  
  .countdown-label {
    font-size: 16px;
  }
  
  .match-schedule {
    font-size: 12px;
  }
  
  .result-card {
    padding: 15px;
  }
  
  .result-avatar {
    width: 50px;
    height: 50px;
    font-size: 20px;
  }
  
  .result-info h3 {
    font-size: 16px;
  }
  
  .result-info p {
    font-size: 13px;
  }
}
</style>
