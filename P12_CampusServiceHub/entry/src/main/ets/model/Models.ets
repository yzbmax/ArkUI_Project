/**
 * 数据模型接口（PRD 第 7 章）
 * 仅作类型定义，Mock 数据见 ../mock/MockData.ets。
 * Resource 为 ArkUI 全局类型，无需 import。
 */

// 用户
export interface UserProfile {
  id: string;
  name: string;
  studentNo: string;
  college: string;
  avatar?: Resource;
  courseCount: number;
  activityCount: number;
  orderCount: number;
}

// 课程
export interface CourseInfo {
  id: string;
  name: string;
  teacher: string;
  time: string;
  location: string;
  credit: number;
  desc: string;
  outline: string[];
}

// 活动
export interface ActivityInfo {
  id: string;
  title: string;
  time: string;
  location: string;
  poster?: Resource;
  status: 'open' | 'closed';
  desc: string;
}

// 服务项
export interface ServiceItem {
  id: string;
  name: string;
  desc: string;
  price: number;
  qty: number;
  checked: boolean; // 是否勾选参与结算
}

// 讨论帖
export interface Post {
  id: string;
  author: string;
  avatar?: Resource;
  content: string;
  likes: number;
  liked: boolean;
  time: string;
}

// 健康档案
export interface HealthProfile {
  height: number; // cm
  weight: number; // kg
}

// 设置开关
export interface ToggleItem {
  id: string;
  title: string;
  desc: string;
  enabled: boolean;
}

// 首页功能入口（PRD 6.2 entries: FunctionEntry[]）
export interface FunctionEntry {
  id: string;
  title: string;
  icon: string;
  route: string;
}
