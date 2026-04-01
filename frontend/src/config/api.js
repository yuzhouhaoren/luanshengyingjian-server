// API 配置文件
// 生产环境使用相对路径，通过Nginx反向代理到后端
const API_BASE_URL = import.meta.env.PROD ? '' : 'http://localhost:5000'

export const API_ENDPOINTS = {
  // 用户相关
  register: `${API_BASE_URL}/api/register`,
  login: `${API_BASE_URL}/api/login`,
  profile: (userId) => `${API_BASE_URL}/api/profile/${userId}`,
  profileSubmit: `${API_BASE_URL}/api/profile`,
  avatarUpload: `${API_BASE_URL}/api/avatar/upload`,
  avatar: (filename) => `${API_BASE_URL}/avatars/${filename}`,
  deleteAccount: `${API_BASE_URL}/api/account/delete`,

  // 统计数据
  stats: `${API_BASE_URL}/api/stats`,
  personalityStats: `${API_BASE_URL}/api/personality/stats`,

  // 意向相关
  intent: (userId) => `${API_BASE_URL}/api/intent/${userId}`,
  intentSubmit: `${API_BASE_URL}/api/intent`,

  // 匹配相关
  matches: (userId) => `${API_BASE_URL}/api/matches/${userId}`,
  matchAccept: `${API_BASE_URL}/api/matches/accept`,
  matchReject: `${API_BASE_URL}/api/matches/reject`,
  matchPool: `${API_BASE_URL}/api/match/pool`,

  // 用户列表
  users: `${API_BASE_URL}/api/users`,

  // 通知
  notifications: (userId) => `${API_BASE_URL}/api/notifications/${userId}`,

  // 意向请求
  intentRequests: (userId) => `${API_BASE_URL}/api/intent-requests/${userId}`,
  intentRequestSend: `${API_BASE_URL}/api/intent-request/send`,
  intentRequestAccept: `${API_BASE_URL}/api/intent-request/accept`,
  intentRequestReject: `${API_BASE_URL}/api/intent-request/reject`,

  // 聊天相关
  chat: `${API_BASE_URL}/api/chat`,
  chatHistory: (chatId) => `${API_BASE_URL}/api/chat/history/${chatId}`,
  chatSquare: `${API_BASE_URL}/api/chat/square`,

  // 机器人
  bots: `${API_BASE_URL}/api/bots`,
  bot: (botId) => `${API_BASE_URL}/api/bot/${botId}`,

  // 广场
  squarePosts: `${API_BASE_URL}/api/square/posts`,
  postsGenerate: `${API_BASE_URL}/api/posts/generate`,

  // 健康检查
  health: `${API_BASE_URL}/api/health`,
}

export default API_BASE_URL
