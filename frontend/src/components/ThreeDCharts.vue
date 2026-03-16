<template>
  <div class="three-d-charts">
    <div class="charts-container">
      <!-- 隐藏的图表容器，用于生成纹理 -->
      <div class="hidden-charts">
        <canvas ref="lineChartCanvas" width="500" height="300"></canvas>
        <canvas ref="barChartCanvas" width="500" height="300"></canvas>
        <canvas ref="pieChartCanvas" width="500" height="300"></canvas>
      </div>
      <!-- 3D场景容器 -->
      <div class="scene-container">
        <canvas ref="sceneCanvas"></canvas>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import * as THREE from 'three';
import Chart from 'chart.js/auto';

const lineChartCanvas = ref(null);
const barChartCanvas = ref(null);
const pieChartCanvas = ref(null);
const sceneCanvas = ref(null);

let scene = null;
let camera = null;
let renderer = null;
let prism = null;
let animationId = null;
let rotationSpeed = 0.005;
let mouseX = 0;

// 图表实例
let lineChart = null;
let barChart = null;
let pieChart = null;

// 图表数据
const chartData = {
  line: {
    labels: Array(12).fill(''),
    datasets: [{
      label: '每日匹配成功对数',
      data: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      borderColor: '#2563EB',
      backgroundColor: 'rgba(37, 99, 235, 0.1)',
      tension: 0.4,
      fill: true
    }]
  },
  bar: {
    labels: ['外向', '内向', '理性', '感性', '乐观', '悲观', '冒险', '保守'],
    datasets: [{
      label: '用户属性分布',
      data: [35, 25, 40, 30, 45, 15, 20, 30],
      backgroundColor: [
        'rgba(37, 99, 235, 0.7)',
        'rgba(59, 130, 246, 0.7)',
        'rgba(16, 185, 129, 0.7)',
        'rgba(249, 115, 22, 0.7)',
        'rgba(139, 92, 246, 0.7)',
        'rgba(239, 68, 68, 0.7)',
        'rgba(245, 158, 11, 0.7)',
        'rgba(107, 114, 128, 0.7)'
      ],
      borderColor: [
        'rgba(37, 99, 235, 1)',
        'rgba(59, 130, 246, 1)',
        'rgba(16, 185, 129, 1)',
        'rgba(249, 115, 22, 1)',
        'rgba(139, 92, 246, 1)',
        'rgba(239, 68, 68, 1)',
        'rgba(245, 158, 11, 1)',
        'rgba(107, 114, 128, 1)'
      ],
      borderWidth: 1
    }]
  },
  pie: {
    labels: ['外向型', '内向型', '混合型', '理性型', '感性型'],
    datasets: [{
      data: [25, 20, 30, 15, 10],
      backgroundColor: [
        'rgba(37, 99, 235, 0.8)',
        'rgba(16, 185, 129, 0.8)',
        'rgba(139, 92, 246, 0.8)',
        'rgba(249, 115, 22, 0.8)',
        'rgba(239, 68, 68, 0.8)'
      ],
      borderColor: [
        'rgba(37, 99, 235, 1)',
        'rgba(16, 185, 129, 1)',
        'rgba(139, 92, 246, 1)',
        'rgba(249, 115, 22, 1)',
        'rgba(239, 68, 68, 1)'
      ],
      borderWidth: 1
    }]
  }
};

onMounted(() => {
  // 初始化图表
  initCharts();
  
  // 延迟初始化3D场景，确保图表已完全渲染
  setTimeout(() => {
    // 确保所有图表都已渲染
    if (lineChart) lineChart.update();
    if (barChart) barChart.update();
    if (pieChart) pieChart.update();
    
    // 延迟创建三棱柱，确保图表纹理已准备就绪
    setTimeout(() => {
      initThree();
      window.addEventListener('mousemove', handleMouseMove);
      animate();
    }, 500);
  }, 1000);
});

onUnmounted(() => {
  if (animationId) {
    cancelAnimationFrame(animationId);
  }
  if (renderer) {
    renderer.dispose();
  }
  if (scene) {
    scene.dispose();
  }
  window.removeEventListener('mousemove', handleMouseMove);
});

// 初始化图表
const initCharts = () => {
  // 确保所有画布元素存在
  if (!lineChartCanvas.value || !barChartCanvas.value || !pieChartCanvas.value) {
    console.error('Canvas elements not found');
    return;
  }

  // 设置画布背景为白色
  const lineCtx = lineChartCanvas.value.getContext('2d');
  lineCtx.fillStyle = '#ffffff';
  lineCtx.fillRect(0, 0, 500, 300);

  const barCtx = barChartCanvas.value.getContext('2d');
  barCtx.fillStyle = '#ffffff';
  barCtx.fillRect(0, 0, 500, 300);

  const pieCtx = pieChartCanvas.value.getContext('2d');
  pieCtx.fillStyle = '#ffffff';
  pieCtx.fillRect(0, 0, 500, 300);

  // 折线图
  lineChart = new Chart(lineChartCanvas.value, {
    type: 'line',
    data: chartData.line,
    options: {
      responsive: false,
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
  });

  // 条形图
  barChart = new Chart(barChartCanvas.value, {
    type: 'bar',
    data: chartData.bar,
    options: {
      responsive: false,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
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
  });

  // 饼图
  pieChart = new Chart(pieChartCanvas.value, {
    type: 'pie',
    data: chartData.pie,
    options: {
      responsive: false,
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
  });
};

// 初始化3D场景
const initThree = () => {
  // 创建场景
  scene = new THREE.Scene();
  scene.background = new THREE.Color(0xf5f7fa);

  // 创建相机
  camera = new THREE.PerspectiveCamera(
    75,
    800 / 600,
    0.1,
    1000
  );
  camera.position.z = 5;

  // 创建渲染器
  renderer = new THREE.WebGLRenderer({
    canvas: sceneCanvas.value,
    antialias: true
  });
  renderer.setSize(800, 600);

  // 创建三棱柱
  createPrism();

  // 添加光源
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
  scene.add(ambientLight);

  const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
  directionalLight.position.set(1, 1, 1);
  scene.add(directionalLight);
};

// 创建三棱柱
const createPrism = () => {
  // 创建三棱柱几何体
  const geometry = new THREE.CylinderGeometry(2, 2, 3, 3, 1, false);

  // 创建材质
  const materials = [];

  // 折线图纹理
  if (lineChartCanvas.value) {
    const lineTexture = new THREE.CanvasTexture(lineChartCanvas.value);
    lineTexture.needsUpdate = true;
    materials.push(new THREE.MeshBasicMaterial({ map: lineTexture }));
  } else {
    materials.push(new THREE.MeshBasicMaterial({ color: 0xff0000 }));
  }

  // 条形图纹理
  if (barChartCanvas.value) {
    const barTexture = new THREE.CanvasTexture(barChartCanvas.value);
    barTexture.needsUpdate = true;
    materials.push(new THREE.MeshBasicMaterial({ map: barTexture }));
  } else {
    materials.push(new THREE.MeshBasicMaterial({ color: 0x00ff00 }));
  }

  // 饼图纹理
  if (pieChartCanvas.value) {
    const pieTexture = new THREE.CanvasTexture(pieChartCanvas.value);
    pieTexture.needsUpdate = true;
    materials.push(new THREE.MeshBasicMaterial({ map: pieTexture }));
  } else {
    materials.push(new THREE.MeshBasicMaterial({ color: 0x0000ff }));
  }

  // 底面和顶面材质
  const bottomMaterial = new THREE.MeshBasicMaterial({ color: 0x60A5FA });
  const topMaterial = new THREE.MeshBasicMaterial({ color: 0x3B82F6 });

  // 将底面和顶面材质添加到材质数组
  materials.push(bottomMaterial);
  materials.push(topMaterial);

  // 创建三棱柱
  prism = new THREE.Mesh(geometry, materials);
  scene.add(prism);

  // 旋转三棱柱，使一个面朝向正面
  prism.rotation.y = 0;
};

// 处理鼠标移动
const handleMouseMove = (event) => {
  // 根据鼠标横坐标计算旋转速度
  mouseX = (event.clientX - window.innerWidth / 2) / window.innerWidth;
  rotationSpeed = 0.005 + Math.abs(mouseX) * 0.01;
};

// 动画函数
const animate = () => {
  animationId = requestAnimationFrame(animate);

  // 旋转三棱柱
  prism.rotation.y += rotationSpeed;

  renderer.render(scene, camera);
};

// 更新图表数据
const updateChartData = (newData) => {
  if (newData.daily_matches) {
    chartData.line.datasets[0].data = newData.daily_matches;
    if (lineChart) {
      lineChart.update();
      // 更新纹理
      if (prism && prism.material[0] && prism.material[0].map) {
        prism.material[0].map.needsUpdate = true;
      }
    }
  }
};
</script>

<style scoped>
.three-d-charts {
  width: 100%;
  height: 600px;
  display: flex;
  justify-content: center;
  align-items: center;
}

.charts-container {
  position: relative;
  width: 800px;
  height: 600px;
}

.hidden-charts {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: -1;
  opacity: 0;
  pointer-events: none;
}

.scene-container {
  width: 100%;
  height: 100%;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
}

canvas {
  display: block;
}

@media (max-width: 768px) {
  .charts-container {
    width: 100%;
    max-width: 600px;
    height: 450px;
  }
  
  .three-d-charts {
    height: 450px;
  }
}

@media (max-width: 480px) {
  .charts-container {
    width: 100%;
    max-width: 400px;
    height: 300px;
  }
  
  .three-d-charts {
    height: 300px;
  }
}
</style>