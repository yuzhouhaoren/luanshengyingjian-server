<template>
  <div class="register">
    <div class="container">
      <div class="register-card">
        <h2>用户注册</h2>
        <p>创建新账号，开始您的交友之旅</p>
        <form @submit.prevent="handleRegister">
          <div class="form-group">
            <label for="username">用户名</label>
            <input 
              type="text" 
              id="username" 
              v-model="form.username" 
              required
              placeholder="请输入用户名"
            >
          </div>
          <div class="form-group">
            <label for="email">邮箱</label>
            <input 
              type="email" 
              id="email" 
              v-model="form.email" 
              required
              placeholder="请输入邮箱"
            >
          </div>
          <div class="form-group">
            <label for="password">密码</label>
            <input 
              type="password" 
              id="password" 
              v-model="form.password" 
              required
              placeholder="请输入密码"
            >
          </div>
          <div class="form-actions">
            <button type="submit" class="btn primary" :disabled="loading">
              {{ loading ? '注册中...' : '注册' }}
            </button>
            <router-link to="/login" class="btn secondary">已有账号？登录</router-link>
          </div>
        </form>
        <div v-if="error" class="error-message">
          {{ error }}
        </div>
        <div v-if="success" class="success-message">
          {{ success }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'

const router = useRouter()
const form = ref({
  username: '',
  email: '',
  password: ''
})
const loading = ref(false)
const error = ref('')
const success = ref('')

const handleRegister = async () => {
  loading.value = true
  error.value = ''
  success.value = ''
  
  try {
    const response = await axios.post('http://localhost:5000/api/register', form.value)
    if (response.data.status === 'success') {
      success.value = '注册成功！正在跳转到登录页面...'
      localStorage.setItem('user', JSON.stringify({
        id: response.data.user_id,
        username: response.data.username,
        email: response.data.email
      }))
      setTimeout(() => {
        router.push('/profile')
      }, 1500)
    } else {
      error.value = response.data.message || '注册失败'
    }
  } catch (err) {
    error.value = '网络错误，请稍后重试'
    console.error(err)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 120px 20px 60px;
}

.register-card {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 60px;
  max-width: 500px;
  width: 100%;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.register-card:hover {
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.15);
  background: rgba(255, 255, 255, 0.3);
}

.register-card h2 {
  text-align: center;
  font-size: 2rem;
  font-weight: 700;
  color: #1E293B;
  margin-bottom: 10px;
}

.register-card p {
  text-align: center;
  color: #475569;
  margin-bottom: 40px;
}

.form-group {
  margin-bottom: 20px;
}

.form-group label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #1E293B;
}

.form-group input,
.form-group select {
  width: 100%;
  padding: 14px 18px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  font-size: 1rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(5px);
  color: #1E293B;
  transition: all 0.3s ease;
}

.form-group input:focus,
.form-group select:focus {
  outline: none;
  border-color: #2563EB;
  background: rgba(255, 255, 255, 0.3);
  box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
  transform: translateY(-2px);
}

.form-group input::placeholder {
  color: #94A3B8;
}

.form-actions {
  display: flex;
  flex-direction: column;
  gap: 15px;
  margin-top: 40px;
}

.btn {
  padding: 16px;
  border-radius: 50px;
  font-weight: 600;
  font-size: 1rem;
  transition: all 0.3s ease;
  border: none;
  cursor: pointer;
  text-decoration: none;
  text-align: center;
  position: relative;
  overflow: hidden;
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

.btn.primary:hover:not(:disabled) {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(37, 99, 235, 0.4);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .register-card {
    max-width: 90%;
    padding: 30px;
  }
  
  .register-card h2 {
    font-size: 1.8rem;
  }
  
  .form-group input {
    padding: 14px 18px;
    font-size: 0.9rem;
  }
  
  .btn {
    padding: 14px;
    font-size: 0.9rem;
  }
}

@media (max-width: 480px) {
  .register-card {
    max-width: 95%;
    padding: 25px;
  }
  
  .register-card h2 {
    font-size: 1.5rem;
  }
  
  .form-group {
    margin-bottom: 20px;
  }
  
  .form-group input {
    padding: 12px 16px;
    font-size: 0.85rem;
  }
  
  .form-actions {
    margin-top: 30px;
  }
  
  .btn {
    padding: 12px;
    font-size: 0.85rem;
  }
}

.btn.primary:disabled {
  opacity: 0.6;
  cursor: not-allowed;
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

.error-message {
  margin-top: 20px;
  padding: 15px;
  background: rgba(239, 68, 68, 0.1);
  border: 1px solid rgba(239, 68, 68, 0.3);
  border-radius: 8px;
  color: #DC2626;
  text-align: center;
}

.success-message {
  margin-top: 20px;
  padding: 15px;
  background: rgba(16, 185, 129, 0.1);
  border: 1px solid rgba(16, 185, 129, 0.3);
  border-radius: 8px;
  color: #059669;
  text-align: center;
}

@media (max-width: 768px) {
  .register-card {
    padding: 40px 30px;
    margin: 0 20px;
  }
  
  .register-card h2 {
    font-size: 1.8rem;
  }
}
</style>