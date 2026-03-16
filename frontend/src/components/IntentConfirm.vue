<template>
  <div class="intent-confirm-container" v-if="show">
    <div class="intent-confirm-content">
      <h3>选择匹配意向</h3>
      <p>您有多个匹配意向，请选择一个进入聊天广场：</p>
      <div class="intent-options">
        <div class="intent-option" v-for="(intent, index) in intents" :key="intent.intent_type" @click="selectIntent(index + 1)">
          <div class="intent-icon">{{ index === 0 ? '❤️' : '🤝' }}</div>
          <span>{{ intent.intent_type }}</span>
        </div>
      </div>
      <div class="confirm-actions">
        <button class="btn-cancel" @click="cancel">取消</button>
      </div>
    </div>
  </div>
</template>

<script setup>
const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  intents: {
    type: Array,
    default: () => []
  }
});

const emit = defineEmits(['select', 'cancel']);

const selectIntent = (index) => {
  emit('select', index);
};

const cancel = () => {
  emit('cancel');
};
</script>

<style scoped>
.intent-confirm-container {
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 40px 20px;
  min-height: 50vh;
}

.intent-confirm-content {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 40px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.2);
  width: 90%;
  max-width: 500px;
  text-align: center;
  animation: fadeIn 0.5s ease-in-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(20px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.intent-confirm-content h3 {
  margin-bottom: 20px;
  color: #333;
  font-size: 24px;
}

.intent-confirm-content p {
  margin-bottom: 30px;
  color: #666;
  font-size: 16px;
}

.intent-options {
  display: flex;
  gap: 20px;
  justify-content: center;
  margin-bottom: 30px;
  flex-wrap: wrap;
}

.intent-option {
  background: rgba(255, 255, 255, 0.2);
  border-radius: 15px;
  padding: 20px;
  cursor: pointer;
  transition: all 0.3s ease;
  min-width: 150px;
  border: 1px solid rgba(255, 255, 255, 0.3);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
}

.intent-option:hover {
  background: rgba(255, 255, 255, 0.4);
  transform: translateY(-5px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.intent-icon {
  font-size: 2rem;
}

.intent-option span {
  font-weight: 600;
  color: #333;
}

.confirm-actions {
  display: flex;
  justify-content: center;
}

.btn-cancel {
  padding: 12px 24px;
  background: rgba(255, 255, 255, 0.2);
  color: #333;
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.btn-cancel:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

@media (max-width: 768px) {
  .intent-confirm-content {
    padding: 30px;
  }
  
  .intent-confirm-content h3 {
    font-size: 20px;
  }
  
  .intent-confirm-content p {
    font-size: 14px;
  }
  
  .intent-option {
    min-width: 120px;
    padding: 15px;
  }
  
  .intent-icon {
    font-size: 1.5rem;
  }
}
</style>