<template>
  <div class="home">
    <!-- Hero区域 -->
    <section class="hero">
      <div class="container">
        <div class="hero-content">
          <h1>孪生映见</h1>
          <p>基于AI的精准匹配与聊天体验，找到与你最契合的朋友</p>
          
          <!-- 匹配成功统计 -->
          <div class="match-stats">
            <div class="stats-item">
              <div class="stats-label">已有{{ matchStats.total_users }}位用户注册</div>
            </div>
            <div class="stats-item">
              <div class="stats-label">已有{{ matchStats.matched_pairs }}对用户匹配成功</div>
            </div>
          </div>
          
          <!-- 引导按钮（仅未登录时显示） -->
          <div class="hero-buttons" v-if="!user">
            <router-link to="/register" class="btn primary">开始注册</router-link>
            <router-link to="/login" class="btn secondary">已有账号？登录</router-link>
          </div>
        </div>
        <div class="hero-bg"></div>
      </div>
    </section>

    <!-- 数据可视化区域 -->
    <section class="data-visualization">
      <div class="container">
        <h2>用户数据可视化</h2>
        <div class="charts-container">
          <div class="chart-left">
            <div class="chart-card tall">
              <h3>每日匹配成功对数</h3>
              <div class="chart-container">
                <canvas ref="lineChart"></canvas>
              </div>
            </div>
          </div>
          <div class="chart-right">
            <div class="chart-card small">
              <h3>我的属性分布</h3>
              <div class="chart-container">
                <canvas ref="barChart"></canvas>
              </div>
            </div>
            <div class="chart-card small">
              <h3>用户性格分布</h3>
              <div class="chart-container">
                <canvas ref="pieChart"></canvas>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 特性介绍 -->
    <section class="features">
      <div class="container">
        <h2>核心特性</h2>
        <div class="features-grid">
          <div class="feature-card">
            <div class="feature-icon">🎯</div>
            <h3>AI精准匹配</h3>
            <p>基于个人画像和聊天习惯，通过AI算法为你匹配最适合的朋友</p>
          </div>
          <div class="feature-card">
            <div class="feature-icon">💬</div>
            <h3>智能聊天机器人</h3>
            <p>在聊天广场与AI机器人交流，提前体验匹配效果</p>
          </div>
          <div class="feature-card">
            <div class="feature-icon">🔒</div>
            <h3>安全隐私</h3>
            <p>严格保护用户隐私，所有数据安全存储</p>
          </div>
        </div>
      </div>
    </section>

    <!-- CTA区域（仅未登录时显示） -->
    <section class="cta" v-if="!user">
      <div class="container">
        <div class="cta-content">
          <h2>开始你的交友之旅</h2>
          <p>加入我们，找到与你志同道合的朋友</p>
          <router-link to="/register" class="btn primary">立即注册</router-link>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import axios from 'axios'
import Chart from 'chart.js/auto'
import { API_ENDPOINTS } from '../config/api.js'

const router = useRouter()
const route = useRoute()
const user = ref(null)
const matchStats = ref({
  total_users: 0,
  matched_pairs: 0,
  daily_matches: []
})

const lineChart = ref(null)
const barChart = ref(null)
const pieChart = ref(null)

let lineChartInstance = null
let barChartInstance = null
let pieChartInstance = null

onMounted(async () => {
  // 获取用户状态
  const savedUser = localStorage.getItem('user')
  if (savedUser) {
    user.value = JSON.parse(savedUser)
  }
  
  // 获取统计数据
  await fetchStats()
  
  // 初始化图表
  initCharts()
})

// 监听路由变化，确保页面内容更新
watch(() => route.path, (newPath) => {
  if (newPath === '/') {
    // 获取用户状态
    const savedUser = localStorage.getItem('user')
    if (savedUser) {
      user.value = JSON.parse(savedUser)
    } else {
      user.value = null
    }
    
    // 获取统计数据
    fetchStats()
  }
})

const userPersonality = ref({
  extraversion: 0,
  openness: 0,
  conscientiousness: 0,
  agreeableness: 0,
  neuroticism: 0,
  narcissism: 0
})

const platformPersonality = ref({
  extraversion: 0,
  openness: 0,
  conscientiousness: 0,
  agreeableness: 0,
  neuroticism: 0,
  narcissism: 0
})

const fetchStats = async () => {
  try {
    console.log('开始获取统计数据...');
    const response = await axios.get(API_ENDPOINTS.stats)
    console.log('获取统计数据成功:', response.data);
    if (response.data.status === 'success') {
      matchStats.value.total_users = response.data.data.total_users
      matchStats.value.matched_pairs = response.data.data.matched_pairs
      matchStats.value.daily_matches = response.data.data.daily_matches
      console.log('更新统计数据:', matchStats.value);
    } else {
      // 失败时使用默认数据
      matchStats.value.total_users = 0
      matchStats.value.matched_pairs = 0
      matchStats.value.daily_matches = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    }
  } catch (error) {
    console.error('获取统计数据失败:', error)
    // 失败时使用默认数据
    matchStats.value.total_users = 0
    matchStats.value.matched_pairs = 0
    matchStats.value.daily_matches = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
  }
  
  // 获取用户个人画像数据
  if (user.value) {
    try {
      const profileResponse = await axios.get(API_ENDPOINTS.profile(user.value.id))
      if (profileResponse.data.status === 'success' && profileResponse.data.profile) {
        const profile = profileResponse.data.profile
        if (profile.profile_scores) {
          const scores = profile.profile_scores
          userPersonality.value = {
            extraversion: scores.extraversion || 0,
            openness: scores.openness || 0,
            conscientiousness: scores.conscientiousness || 0,
            agreeableness: scores.agreeableness || 0,
            neuroticism: scores.neuroticism || 0,
            narcissism: scores.narcissism || 0
          }
          console.log('获取用户个人画像数据成功:', userPersonality.value);
        }
      }
    } catch (error) {
      console.error('获取用户个人画像数据失败:', error)
    }
  }
  
  // 获取平台用户性格分布数据
  try {
    const platformResponse = await axios.get(API_ENDPOINTS.personalityStats)
    if (platformResponse.data.status === 'success') {
      platformPersonality.value = platformResponse.data.data
      console.log('获取平台性格分布数据成功:', platformPersonality.value);
    }
  } catch (error) {
    console.error('获取平台性格分布数据失败:', error)
  }
  
  // 所有数据获取完成后更新图表
  updateCharts()
  console.log('图表数据已更新');
}

const initCharts = () => {
  // 折线图
  if (lineChart.value) {
    lineChartInstance = new Chart(lineChart.value, {
      type: 'line',
      data: {
        labels: Array(12).fill(''),
        datasets: [{
          label: '每日匹配成功对数',
          data: matchStats.value.daily_matches,
          borderColor: '#2563EB',
          backgroundColor: 'rgba(37, 99, 235, 0.1)',
          tension: 0.4,
          fill: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: true,
            position: 'top',
            labels: {
              color: '#333'
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: {
              color: 'rgba(0, 0, 0, 0.05)'
            },
            ticks: {
              color: '#333'
            }
          },
          x: {
            grid: {
              display: false
            },
            ticks: {
              color: '#333'
            }
          }
        }
      }
    })
  }

  // 条形图 - 个人属性分布
  if (barChart.value) {
    barChartInstance = new Chart(barChart.value, {
      type: 'bar',
      data: {
        labels: ['外向性 (E)', '开放性 (O)', '尽责性 (C)', '宜人性 (A)', '神经质 (N)', '自恋 (Narc)'],
        datasets: [{
          label: '个人属性得分',
          data: [
            userPersonality.value.extraversion,
            userPersonality.value.openness,
            userPersonality.value.conscientiousness,
            userPersonality.value.agreeableness,
            userPersonality.value.neuroticism,
            userPersonality.value.narcissism
          ],
          backgroundColor: [
            'rgba(37, 99, 235, 0.7)',
            'rgba(16, 185, 129, 0.7)',
            'rgba(249, 115, 22, 0.7)',
            'rgba(139, 92, 246, 0.7)',
            'rgba(239, 68, 68, 0.7)',
            'rgba(245, 158, 11, 0.7)'
          ],
          borderColor: [
            'rgba(37, 99, 235, 1)',
            'rgba(16, 185, 129, 1)',
            'rgba(249, 115, 22, 1)',
            'rgba(139, 92, 246, 1)',
            'rgba(239, 68, 68, 1)',
            'rgba(245, 158, 11, 1)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            max: 5,
            grid: {
              color: 'rgba(0, 0, 0, 0.05)'
            },
            ticks: {
              color: '#333'
            }
          },
          x: {
            grid: {
              display: false
            },
            ticks: {
              color: '#333'
            }
          }
        }
      }
    })
  }

  // 饼图 - 平台性格分布
  if (pieChart.value) {
    // 计算平台性格分布数据
    const platformData = [
      platformPersonality.value.extraversion || 0,
      platformPersonality.value.openness || 0,
      platformPersonality.value.conscientiousness || 0,
      platformPersonality.value.agreeableness || 0,
      platformPersonality.value.neuroticism || 0
    ]
    
    pieChartInstance = new Chart(pieChart.value, {
      type: 'pie',
      data: {
        labels: ['外向性', '开放性', '尽责性', '宜人性', '神经质'],
        datasets: [{
          data: platformData,
          backgroundColor: [
            'rgba(37, 99, 235, 0.8)',
            'rgba(16, 185, 129, 0.8)',
            'rgba(249, 115, 22, 0.8)',
            'rgba(139, 92, 246, 0.8)',
            'rgba(239, 68, 68, 0.8)'
          ],
          borderColor: [
            'rgba(37, 99, 235, 1)',
            'rgba(16, 185, 129, 1)',
            'rgba(249, 115, 22, 1)',
            'rgba(139, 92, 246, 1)',
            'rgba(239, 68, 68, 1)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'right',
            labels: {
              color: '#333'
            }
          }
        }
      }
    })
  }
}

const updateCharts = () => {
  if (lineChartInstance) {
    lineChartInstance.data.datasets[0].data = matchStats.value.daily_matches
    lineChartInstance.update()
  }
  
  if (barChartInstance) {
    barChartInstance.data.datasets[0].data = [
      userPersonality.value.extraversion,
      userPersonality.value.openness,
      userPersonality.value.conscientiousness,
      userPersonality.value.agreeableness,
      userPersonality.value.neuroticism,
      userPersonality.value.narcissism
    ]
    barChartInstance.update()
  }
  
  if (pieChartInstance) {
    const platformData = [
      platformPersonality.value.extraversion || 0,
      platformPersonality.value.openness || 0,
      platformPersonality.value.conscientiousness || 0,
      platformPersonality.value.agreeableness || 0,
      platformPersonality.value.neuroticism || 0
    ]
    pieChartInstance.data.datasets[0].data = platformData
    pieChartInstance.update()
  }
}
</script>

<style scoped>
.home {
  min-height: 100vh;
  position: relative;
}

.hero {
  position: relative;
  padding: 120px 0;
  text-align: center;
  overflow: hidden;
  background: linear-gradient(135deg, rgba(37, 99, 235, 0.1), rgba(59, 130, 246, 0.1));
}

.hero-content {
  position: relative;
  z-index: 1;
  max-width: 800px;
  margin: 0 auto;
}

.hero h1 {
  font-size: 3.5rem;
  font-weight: 800;
  color: #1E293B;
  margin-bottom: 20px;
  text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.hero p {
  font-size: 1.2rem;
  color: #475569;
  margin-bottom: 40px;
  max-width: 600px;
  margin-left: auto;
  margin-right: auto;
}

/* 匹配成功统计 */
.match-stats {
  display: flex;
  justify-content: center;
  gap: 60px;
  margin: 40px 0;
  flex-wrap: wrap;
}

.stats-item {
  text-align: center;
}

.stats-label {
  font-size: 1.2rem;
  font-weight: 700;
  color: #2563EB;
  margin-bottom: 10px;
}

/* 图表容器 */
.chart-container {
  width: 100%;
  max-width: 600px;
  height: 300px;
  margin: 40px auto;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.hero-buttons {
  display: flex;
  justify-content: center;
  gap: 20px;
  flex-wrap: wrap;
  margin-top: 40px;
}

.btn {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 16px 32px;
  border-radius: 50px;
  text-decoration: none;
  font-weight: 600;
  font-size: 1rem;
  transition: all 0.3s ease;
  position: relative;
  overflow: hidden;
  border: none;
  cursor: pointer;
}

.btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.3), transparent);
  transition: left 0.5s;
}

.btn:hover::before {
  left: 100%;
}

.btn.primary {
  background: linear-gradient(135deg, #2563EB, #3B82F6);
  color: white;
  box-shadow: 0 4px 16px rgba(37, 99, 235, 0.3);
}

.btn.primary:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(37, 99, 235, 0.4);
}

.btn.secondary {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  color: #1E293B;
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.btn.secondary:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

/* 数据可视化区域 */
.data-visualization {
  padding: 100px 0;
  background: linear-gradient(135deg, rgba(139, 92, 246, 0.05), rgba(16, 185, 129, 0.05));
}

.data-visualization h2 {
  text-align: center;
  font-size: 2.5rem;
  font-weight: 700;
  color: #1E293B;
  margin-bottom: 60px;
}

.charts-container {
  display: flex;
  gap: 20px;
  max-width: 1400px;
  margin: 0 auto;
  align-items: stretch;
}

.chart-left {
  flex: 1;
  min-width: 300px;
}

.chart-right {
  flex: 1;
  min-width: 300px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.chart-card {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 20px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.chart-card.tall {
  display: flex;
  flex-direction: column;
}

.chart-card.tall .chart-container {
  flex: 1;
  min-height: 540px;
}

.chart-card.small {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.chart-card.small .chart-container {
  flex: 1;
  min-height: 250px;
}

.chart-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.15);
  background: rgba(255, 255, 255, 0.3);
}

.chart-card h3 {
  text-align: center;
  font-size: 1.2rem;
  font-weight: 600;
  color: #1E293B;
  margin-bottom: 15px;
}

.chart-card .chart-container {
  margin: 0;
  height: 100%;
}

.features {
  padding: 100px 0;
}

.features h2 {
  text-align: center;
  font-size: 2.5rem;
  font-weight: 700;
  color: #1E293B;
  margin-bottom: 60px;
}

.features-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 30px;
}

.feature-card {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 40px;
  text-align: center;
  transition: all 0.3s ease;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

.feature-card:hover {
  transform: translateY(-10px);
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.15);
  background: rgba(255, 255, 255, 0.3);
}

.feature-icon {
  font-size: 3rem;
  margin-bottom: 20px;
}

.feature-card h3 {
  font-size: 1.5rem;
  font-weight: 600;
  color: #1E293B;
  margin-bottom: 15px;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .hero h1 {
    font-size: 2.5rem;
  }
  
  .hero p {
    font-size: 1rem;
  }
  
  .match-stats {
    gap: 30px;
  }
  
  .stats-label {
    font-size: 1rem;
  }
  
  .hero-buttons {
    flex-direction: column;
    align-items: center;
  }
  
  .btn {
    padding: 14px 28px;
    font-size: 0.9rem;
  }
  
  .data-visualization h2 {
    font-size: 2rem;
  }
  
  .charts-container {
    flex-direction: column;
  }
  
  .chart-left,
  .chart-right {
    min-width: 100%;
  }
  
  .chart-card.tall .chart-container {
    min-height: 300px;
  }
  
  .chart-card.small .chart-container {
    min-height: 200px;
  }
  
  .features h2 {
    font-size: 2rem;
  }
  
  .feature-card {
    padding: 30px;
  }
  
  .feature-card h3 {
    font-size: 1.2rem;
  }
}

@media (max-width: 480px) {
  .hero h1 {
    font-size: 2rem;
  }
  
  .hero p {
    font-size: 0.9rem;
  }
  
  .match-stats {
    flex-direction: column;
    gap: 20px;
  }
  
  .btn {
    padding: 12px 24px;
    font-size: 0.85rem;
  }
  
  .data-visualization {
    padding: 60px 0;
  }
  
  .data-visualization h2 {
    font-size: 1.8rem;
  }
  
  .features {
    padding: 60px 0;
  }
  
  .features h2 {
    font-size: 1.8rem;
  }
  
  .feature-card {
    padding: 20px;
  }
  
  .feature-card h3 {
    font-size: 1.1rem;
  }
}

.feature-card p {
  color: #475569;
  line-height: 1.6;
}

.cta {
  padding: 100px 0;
  text-align: center;
  background: linear-gradient(135deg, rgba(37, 99, 235, 0.1), rgba(59, 130, 246, 0.1));
  margin-top: 60px;
}

.cta-content {
  max-width: 600px;
  margin: 0 auto;
}

.cta h2 {
  font-size: 2.5rem;
  font-weight: 700;
  color: #1E293B;
  margin-bottom: 20px;
}

.cta p {
  font-size: 1.1rem;
  color: #475569;
  margin-bottom: 40px;
}

@media (max-width: 768px) {
  .hero h1 {
    font-size: 2.5rem;
  }
  
  .hero-buttons {
    flex-direction: column;
    align-items: center;
  }
  
  .btn {
    width: 200px;
    justify-content: center;
  }
  
  .charts-container {
    flex-direction: column;
  }
  
  .chart-left,
  .chart-right {
    min-width: 100%;
  }
  
  .chart-card {
    padding: 15px;
  }
  
  .chart-card.tall .chart-container {
    min-height: 300px;
  }
  
  .chart-card.small .chart-container {
    min-height: 250px;
  }
  
  .chart-card h3 {
    font-size: 1rem;
  }
  
  .features h2 {
    font-size: 2rem;
  }
  
  .data-visualization h2 {
    font-size: 1.8rem;
  }
  
  .cta h2 {
    font-size: 2rem;
  }
}

@media (max-width: 480px) {
  .data-visualization h2 {
    font-size: 1.5rem;
  }
  
  .chart-card {
    padding: 10px;
  }
  
  .chart-card.tall .chart-container {
    min-height: 250px;
  }
  
  .chart-card.small .chart-container {
    min-height: 200px;
  }
  
  .chart-card h3 {
    font-size: 0.9rem;
  }
}
</style>