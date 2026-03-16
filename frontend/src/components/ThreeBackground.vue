<template>
  <div class="three-background">
    <canvas ref="canvasRef"></canvas>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue';
import * as THREE from 'three';

const canvasRef = ref(null);
let scene = null;
let camera = null;
let renderer = null;
let particles = [];
let animationId = null;

onMounted(() => {
  initThree();
  animate();
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
});

const initThree = () => {
  // 创建场景
  scene = new THREE.Scene();
  
  // 创建相机
  camera = new THREE.PerspectiveCamera(
    75,
    window.innerWidth / window.innerHeight,
    0.1,
    1000
  );
  camera.position.z = 5;
  
  // 创建渲染器
  renderer = new THREE.WebGLRenderer({
    canvas: canvasRef.value,
    alpha: true,
    antialias: true
  });
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  
  // 创建粒子
  createParticles();
  
  // 监听窗口大小变化
  window.addEventListener('resize', onWindowResize);
};

const createParticles = () => {
  const particleCount = 100;
  const geometry = new THREE.SphereGeometry(0.05, 16, 16);
  const material = new THREE.MeshBasicMaterial({
    color: 0x2563EB,
    transparent: true,
    opacity: 0.8
  });
  
  for (let i = 0; i < particleCount; i++) {
    const particle = new THREE.Mesh(geometry, material);
    particle.position.x = (Math.random() - 0.5) * 10;
    particle.position.y = (Math.random() - 0.5) * 10;
    particle.position.z = (Math.random() - 0.5) * 10;
    particle.velocity = {
      x: (Math.random() - 0.5) * 0.01,
      y: (Math.random() - 0.5) * 0.01,
      z: (Math.random() - 0.5) * 0.01
    };
    scene.add(particle);
    particles.push(particle);
  }
  
  // 创建连接线
  const lineGeometry = new THREE.BufferGeometry();
  const lineMaterial = new THREE.LineBasicMaterial({
    color: 0x60A5FA,
    transparent: true,
    opacity: 0.2
  });
  
  const linePositions = [];
  for (let i = 0; i < particleCount; i++) {
    for (let j = i + 1; j < particleCount; j++) {
      const p1 = particles[i].position;
      const p2 = particles[j].position;
      const distance = p1.distanceTo(p2);
      if (distance < 2) {
        linePositions.push(p1.x, p1.y, p1.z);
        linePositions.push(p2.x, p2.y, p2.z);
      }
    }
  }
  
  lineGeometry.setAttribute('position', new THREE.Float32BufferAttribute(linePositions, 3));
  const line = new THREE.LineSegments(lineGeometry, lineMaterial);
  scene.add(line);
};

const animate = () => {
  animationId = requestAnimationFrame(animate);
  
  // 更新粒子位置
  particles.forEach(particle => {
    particle.position.x += particle.velocity.x;
    particle.position.y += particle.velocity.y;
    particle.position.z += particle.velocity.z;
    
    // 边界检测
    if (Math.abs(particle.position.x) > 5) particle.velocity.x *= -1;
    if (Math.abs(particle.position.y) > 5) particle.velocity.y *= -1;
    if (Math.abs(particle.position.z) > 5) particle.velocity.z *= -1;
  });
  
  // 旋转场景
  scene.rotation.x += 0.0005;
  scene.rotation.y += 0.001;
  
  renderer.render(scene, camera);
};

const onWindowResize = () => {
  camera.aspect = window.innerWidth / window.innerHeight;
  camera.updateProjectionMatrix();
  renderer.setSize(window.innerWidth, window.innerHeight);
};
</script>

<style scoped>
.three-background {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: -1;
}

canvas {
  display: block;
  width: 100%;
  height: 100%;
}
</style>