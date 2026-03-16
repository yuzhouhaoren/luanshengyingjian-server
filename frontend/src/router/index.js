import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: () => import('../views/HomeView.vue')
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/LoginView.vue')
  },
  {
    path: '/register',
    name: 'Register',
    component: () => import('../views/RegisterView.vue')
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('../views/ProfileView.vue')
  },
  {
    path: '/square',
    name: 'Square',
    component: () => import('../views/SquareView.vue')
  },
  {
    path: '/intent',
    name: 'Intent',
    component: () => import('../views/IntentView.vue')
  },
  {
    path: '/settings',
    name: 'Settings',
    component: () => import('../views/SettingsView.vue')
  },
  {
    path: '/user',
    name: 'User',
    component: () => import('../views/UserView.vue')
  },
  {
    path: '/match-pool',
    name: 'MatchPool',
    component: () => import('../views/MatchPoolView.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

export default router