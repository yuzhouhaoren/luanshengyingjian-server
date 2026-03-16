<template>
  <div class="profile-container">
    <div class="glass-card">
      <h1>个人画像</h1>
      <form @submit.prevent="submitProfile">
        <div class="form-group">
          <label for="name">姓名</label>
          <input type="text" id="name" v-model="profile.name" required>
        </div>
        <div class="form-group">
          <label for="age">年龄</label>
          <input type="number" id="age" v-model="profile.age" required>
        </div>
        <div class="form-group">
          <label for="gender">性别</label>
          <select id="gender" v-model="profile.gender" required>
            <option value="男">男</option>
            <option value="女">女</option>
          </select>
        </div>
        <div class="form-group">
          <label for="occupation">职业</label>
          <input type="text" id="occupation" v-model="profile.occupation" required>
        </div>
        <div class="form-group">
          <label for="sexual_orientation">性取向</label>
          <select id="sexual_orientation" v-model="profile.sexual_orientation" required>
            <option value="异性恋">异性恋</option>
            <option value="同性恋">同性恋</option>
            <option value="双性恋">双性恋</option>
            <option value="无性恋">无性恋</option>
          </select>
        </div>
        <div class="form-group">
          <label>兴趣爱好</label>
          <div class="checkbox-group">
            <label v-for="hobby in hobbies" :key="hobby">
              <input type="checkbox" :value="hobby" v-model="selectedHobbies">
              {{ hobby }}
            </label>
          </div>
        </div>
        

        
        <!-- CARRP 题库 -->
        <div class="form-section">
          <h2>CARRP 人格问卷</h2>
          <div v-for="(question, index) in carrpQuestions" :key="index" class="form-group">
            <label>{{ question.text }}</label>
            <select v-model="carrpAnswers[index]" required>
              <option value="1">非常不同意</option>
              <option value="2">不同意</option>
              <option value="3">中立</option>
              <option value="4">同意</option>
              <option value="5">非常同意</option>
            </select>
          </div>
        </div>
        
        <!-- NRI-BSV 题库 -->
        <div class="form-section">
          <h2>NRI-BSV 自恋人格问卷</h2>
          <div v-for="(question, index) in nriQuestions" :key="index" class="form-group">
            <label>{{ question.text }}</label>
            <select v-model="nriAnswers[index]" required>
              <option value="1">非常不同意</option>
              <option value="2">不同意</option>
              <option value="3">中立</option>
              <option value="4">同意</option>
              <option value="5">非常同意</option>
            </select>
          </div>
        </div>
        
        <div class="form-group">
          <label for="personality">性格特点</label>
          <textarea id="personality" v-model="profile.personality" required></textarea>
        </div>
        <div class="form-group">
          <label for="communication_style">沟通风格</label>
          <textarea id="communication_style" v-model="profile.communication_style" required></textarea>
        </div>

        <div class="form-group">
          <label>聊天习惯（请选择你喜欢的聊天方式）</label>
          <select v-model="profile.chat_habits" required>
            <option value="喜欢文字聊天，注重细节">喜欢文字聊天，注重细节</option>
            <option value="喜欢语音聊天，直接快捷">喜欢语音聊天，直接快捷</option>
            <option value="喜欢表情和emoji，活泼有趣">喜欢表情和emoji，活泼有趣</option>
            <option value="喜欢视频聊天，面对面交流">喜欢视频聊天，面对面交流</option>
          </select>
        </div>
        <button type="submit" class="btn-submit">保存个人画像</button>
      </form>
    </div>
    
    <!-- 问卷属性计算结果小窗 -->
    <div class="modal" v-if="showResult">
      <div class="modal-content">
        <h3>个人属性分析结果</h3>

        <div class="result-item">
          <span class="result-label">外向性 (E)：</span>
          <span class="result-value">{{ personalityAnalysis.extraversion }}</span>
        </div>
        <div class="result-item">
          <span class="result-label">开放性 (O)：</span>
          <span class="result-value">{{ personalityAnalysis.openness }}</span>
        </div>
        <div class="result-item">
          <span class="result-label">尽责性 (C)：</span>
          <span class="result-value">{{ personalityAnalysis.conscientiousness }}</span>
        </div>
        <div class="result-item">
          <span class="result-label">宜人性 (A)：</span>
          <span class="result-value">{{ personalityAnalysis.agreeableness }}</span>
        </div>
        <div class="result-item">
          <span class="result-label">神经质 (N)：</span>
          <span class="result-value">{{ personalityAnalysis.neuroticism }}</span>
        </div>
        <div class="result-item">
          <span class="result-label">自恋 (Narc)：</span>
          <span class="result-value">{{ personalityAnalysis.narcissism }}</span>
        </div>
        <button class="btn-close" @click="showResult = false">关闭</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';
import { useRouter } from 'vue-router';
import axios from 'axios';

const router = useRouter();

const profile = ref({
  name: '',
  age: '',
  gender: '',
  occupation: '',
  sexual_orientation: '',
  personality: '',
  communication_style: '',
  chat_habits: ''
});

const hobbies = ref(['阅读', '运动', '音乐', '旅行', '电影', '美食', '游戏', '艺术', '摄影', '健身', '瑜伽', '舞蹈', '编程', '绘画', '书法', '手工', '烹饪', '烘焙', '园艺', '钓鱼', '露营', '攀岩', '滑雪', '冲浪', '潜水', '骑行', '徒步', '冥想', '动漫', '电竞', '桌游', '手账']);
const selectedHobbies = ref([]);



// CARRP 题库（完整）
const carrpQuestions = ref([
  { text: '1. 我是一个热情的人', dimension: 'E', direction: 'positive' },
  { text: '2. 我喜欢尝试新事物', dimension: 'O', direction: 'positive' },
  { text: '3. 我是一个有条理的人', dimension: 'C', direction: 'positive' },
  { text: '4. 我容易感到焦虑', dimension: 'N', direction: 'positive' },
  { text: '5. 我喜欢与他人合作', dimension: 'A', direction: 'positive' },
  { text: '6. 我是一个乐观的人', dimension: 'E', direction: 'positive' },
  { text: '7. 我喜欢独处', dimension: 'E', direction: 'negative' },
  { text: '8. 我是一个有创造力的人', dimension: 'O', direction: 'positive' },
  { text: '9. 我容易生气', dimension: 'N', direction: 'positive' },
  { text: '10. 我是一个负责任的人', dimension: 'C', direction: 'positive' },
  { text: '11. 我善于体谅他人', dimension: 'A', direction: 'positive' }
]);

const carrpAnswers = ref([]);

// NRI-BSV 题库（完整）
const nriQuestions = ref([
  { text: '12. 我觉得自己很特别', dimension: 'Narc', direction: 'positive' },
  { text: '13. 我喜欢成为关注的焦点', dimension: 'Narc', direction: 'positive' },
  { text: '14. 我觉得自己比大多数人优秀', dimension: 'Narc', direction: 'positive' },
  { text: '15. 我需要他人的赞美和认可', dimension: 'Narc', direction: 'positive' },
  { text: '16. 我有很多天赋', dimension: 'Narc', direction: 'positive' },
  { text: '17. 我应该得到特殊对待', dimension: 'Narc', direction: 'positive' },
  { text: '18. 我是一个天生的领导者', dimension: 'Narc', direction: 'positive' },
  { text: '19. 我比其他人更值得拥有成功', dimension: 'Narc', direction: 'positive' },
  { text: '20. 我喜欢被人崇拜', dimension: 'Narc', direction: 'positive' },
  { text: '21. 我是一个非常重要的人', dimension: 'Narc', direction: 'positive' }
]);

const nriAnswers = ref([]);



// 问卷属性分析结果
const showResult = ref(false);
const personalityAnalysis = ref({
  extraversion: 0, // 外向性
  openness: 0, // 开放性
  conscientiousness: 0, // 尽责性
  agreeableness: 0, // 宜人性
  neuroticism: 0, // 神经质
  narcissism: 0 // 自恋程度
});



onMounted(() => {
  loadProfile();
});

const loadProfile = async () => {
  try {
    const user = JSON.parse(localStorage.getItem('user'));
    if (!user) {
      router.push('/login');
      return;
    }
    
    const response = await axios.get(`http://localhost:5000/api/profile/${user.id}`);
    if (response.data.status === 'success' && response.data.profile) {
      const profileData = response.data.profile;
      profile.value.name = profileData.name || '';
      profile.value.age = profileData.age || '';
      profile.value.gender = profileData.gender || '';
      profile.value.occupation = profileData.occupation || '';
      profile.value.sexual_orientation = profileData.sexual_orientation || '';
      profile.value.personality = profileData.personality || '';
      profile.value.communication_style = profileData.communication_style || '';
      profile.value.chat_habits = profileData.chat_habits || '';
      
      // 处理兴趣爱好
      if (profileData.hobbies) {
        selectedHobbies.value = profileData.hobbies.split(',');
      }
      

      
      // 处理CARRP答案
      if (profileData.carrp_answers) {
        carrpAnswers.value = profileData.carrp_answers.split(',');
      } else {
        // 初始化11个CARRP问题的答案
        carrpAnswers.value = new Array(11).fill('');
      }
      
      // 处理NRI-BSV答案
      if (profileData.nri_answers) {
        nriAnswers.value = profileData.nri_answers.split(',');
      } else {
        // 初始化10个NRI-BSV问题的答案
        nriAnswers.value = new Array(10).fill('');
      }
      

    }
  } catch (error) {
    console.error('加载个人画像失败:', error);
  }
};



const calculatePersonality = () => {
  // 计算CARRP问卷属性
  if (carrpAnswers.value.length === 11) {
    // 处理反向计分题
    const processedCarrpAnswers = carrpAnswers.value.map((answer, index) => {
      const question = carrpQuestions.value[index];
      if (question && question.direction === 'negative') {
        return 6 - parseInt(answer);
      }
      return parseInt(answer);
    });
    
    // 计算各维度得分
    const E = (processedCarrpAnswers[0] + processedCarrpAnswers[5] + processedCarrpAnswers[6]) / 3;
    const O = (processedCarrpAnswers[1] + processedCarrpAnswers[7]) / 2;
    const C = (processedCarrpAnswers[2] + processedCarrpAnswers[9]) / 2;
    const A = (processedCarrpAnswers[4] + processedCarrpAnswers[10]) / 2;
    const N = (processedCarrpAnswers[3] + processedCarrpAnswers[8]) / 2;
    
    // 计算NRI-BSV问卷属性（自恋程度）
    let narcissismScore = 0;
    if (nriAnswers.value.length === 10) {
      for (let i = 0; i < 10; i++) {
        narcissismScore += parseInt(nriAnswers.value[i]);
      }
    }
    const Narc = narcissismScore / 10;
    
    // 更新人格分析结果
    personalityAnalysis.value.extraversion = Math.round(E * 10) / 10; // 外向性
    personalityAnalysis.value.openness = Math.round(O * 10) / 10; // 开放性
    personalityAnalysis.value.conscientiousness = Math.round(C * 10) / 10; // 尽责性
    personalityAnalysis.value.agreeableness = Math.round(A * 10) / 10; // 宜人性
    personalityAnalysis.value.neuroticism = Math.round(N * 10) / 10; // 神经质
    personalityAnalysis.value.narcissism = Math.round(Narc * 10) / 10; // 自恋
  }
};

const submitProfile = async () => {
  try {
    const user = JSON.parse(localStorage.getItem('user'));
    if (!user) {
      router.push('/login');
      return;
    }
    
    // 计算量化得分
    calculatePersonality();
    
    const profileData = {
      ...profile.value,
      hobbies: selectedHobbies.value.join(','),
      carrp_answers: carrpAnswers.value.join(','),
      nri_answers: nriAnswers.value.join(','),
      user_id: user.id
    };
    
    const response = await axios.post('http://localhost:5000/api/profile', profileData);
    if (response.data.status === 'success') {
      // 显示结果小窗
      showResult.value = true;
      // 3秒后跳转到首页，让用户看到更新后的数据
      setTimeout(() => {
        router.push('/');
      }, 3000);
    } else {
      alert('保存失败：' + (response.data.message || '未知错误'));
    }
  } catch (error) {
    console.error('保存个人画像失败:', error);
    alert('保存失败，请稍后重试');
  }
};
</script>

<style scoped>
.profile-container {
  min-height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 20px;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

.glass-card {
  background: rgba(255, 255, 255, 0.15);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 40px;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.1);
  width: 100%;
  max-width: 600px;
}

h1 {
  text-align: center;
  margin-bottom: 30px;
  color: #333;
  font-size: 28px;
}

.form-group {
  margin-bottom: 20px;
}

label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
  color: #333;
}

input, select, textarea {
  width: 100%;
  padding: 12px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  background: rgba(255, 255, 255, 0.5);
  backdrop-filter: blur(5px);
  font-size: 16px;
  transition: all 0.3s ease;
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: #6a11cb;
  box-shadow: 0 0 0 3px rgba(106, 17, 203, 0.2);
}

.checkbox-group {
  display: flex;
  flex-wrap: wrap;
  gap: 15px;
}

.checkbox-group label {
  display: flex;
  align-items: center;
  font-weight: normal;
  cursor: pointer;
}

.checkbox-group input[type="checkbox"] {
  width: auto;
  margin-right: 5px;
}

textarea {
  resize: vertical;
  min-height: 100px;
}

.btn-submit {
  width: 100%;
  padding: 15px;
  background: linear-gradient(45deg, #6a11cb, #2575fc);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 20px;
}

.btn-submit:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(106, 17, 203, 0.4);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .glass-card {
    padding: 30px;
  }
  
  h1 {
    font-size: 24px;
  }
  
  h2 {
    font-size: 20px;
  }
  
  .form-group {
    margin-bottom: 15px;
  }
  
  input, select, textarea {
    padding: 12px;
    font-size: 14px;
  }
  
  .checkbox-group {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .radio-group label {
    font-size: 14px;
    padding: 8px 12px;
  }
  
  .btn-submit {
    padding: 12px;
    font-size: 14px;
  }
}

@media (max-width: 480px) {
  .glass-card {
    padding: 20px;
  }
  
  h1 {
    font-size: 20px;
  }
  
  h2 {
    font-size: 18px;
  }
  
  .form-group {
    margin-bottom: 12px;
  }
  
  input, select, textarea {
    padding: 10px;
    font-size: 13px;
  }
  
  .checkbox-group {
    grid-template-columns: 1fr;
  }
  
  .radio-group label {
    font-size: 13px;
    padding: 6px 10px;
  }
  
  .btn-submit {
    padding: 10px;
    font-size: 13px;
  }
}

.form-section {
  margin: 30px 0;
  padding: 20px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 15px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.form-section h2 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #333;
  font-size: 20px;
  text-align: center;
}

/* 模态框样式 */
.modal {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 2000;
}

.modal-content {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.2);
  border: 1px solid rgba(255, 255, 255, 0.1);
  width: 100%;
  max-width: 500px;
  max-height: 80vh;
  overflow-y: auto;
}

.modal-content h3 {
  text-align: center;
  margin-bottom: 20px;
  color: #333;
  font-size: 24px;
}

.result-item {
  display: flex;
  justify-content: space-between;
  margin-bottom: 12px;
  padding: 8px 0;
  border-bottom: 1px solid rgba(0, 0, 0, 0.1);
}

.result-label {
  font-weight: 600;
  color: #333;
}

.result-value {
  color: #6a11cb;
  font-weight: 600;
}

.btn-close {
  width: 100%;
  padding: 12px;
  background: linear-gradient(45deg, #6a11cb, #2575fc);
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  margin-top: 20px;
}

.btn-close:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(106, 17, 203, 0.4);
}

@media (max-width: 768px) {
  .glass-card {
    padding: 20px;
  }
  
  h1 {
    font-size: 24px;
  }
  
  .form-section {
    padding: 15px;
  }
  
  .form-section h2 {
    font-size: 18px;
  }
  
  .modal-content {
    padding: 20px;
    margin: 20px;
  }
  
  .modal-content h3 {
    font-size: 20px;
  }
}
</style>