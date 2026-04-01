<template>
  <div class="login">
    <div class="container">
      <div class="login-card">
        <h2>用户登录</h2>
        <p>欢迎回到孪生映见</p>
        <form @submit.prevent="handleLogin">
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
              {{ loading ? '登录中...' : '登录' }}
            </button>
            <router-link to="/register" class="btn secondary">注册新账号</router-link>
          </div>
        </form>
        <div v-if="error" class="error-message">
          {{ error }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { API_ENDPOINTS } from '../config/api.js'

const router = useRouter()
const form = ref({
  email: '',
  password: ''
})
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  loading.value = true
  error.value = ''

  try {
    const response = await axios.post(API_ENDPOINTS.login, form.value)
    if (response.data.status === 'success') {
      localStorage.setItem('user', JSON.stringify({
        id: response.data.user_id,
        username: response.data.username,
        email: response.data.email
      }))
      router.push('/')
    } else {
      error.value = response.data.message || '登录失败'
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
.login {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 120px 20px 60px;
}

.login-card {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 16px;
  padding: 60px;
  max-width: 450px;
  width: 100%;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
  transition: all 0.3s ease;
}

.login-card:hover {
  box-shadow: 0 16px 48px rgba(0, 0, 0, 0.15);
  background: rgba(255, 255, 255, 0.3);
}

.login-card h2 {
  text-align: center;
  font-size: 2rem;
  font-weight: 700;
  color: #1E293B;
  margin-bottom: 10px;
}

.login-card p {
  text-align: center;
  color: #475569;
  margin-bottom: 40px;
}

.form-group {
  margin-bottom: 25px;
}

.form-group label {
  display: block;
  margin-bottom: 10px;
  font-weight: 600;
  color: #1E293B;
}

.form-group input {
  width: 100%;
  padding: 16px 20px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  font-size: 1rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(5px);
  color: #1E293B;
  transition: all 0.3s ease;
}

.form-group input:focus {
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
  .login-card {
    max-width: 90%;
    padding: 30px;
  }
  
  .login-card h2 {
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
  .login-card {
    max-width: 95%;
    padding: 25px;
  }
  
  .login-card h2 {
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

@media (max-width: 768px) {
  .login-card {
    padding: 40px 30px;
    margin: 0 20px;
  }
  
  .login-card h2 {
    font-size: 1.8rem;
  }
}
</style>