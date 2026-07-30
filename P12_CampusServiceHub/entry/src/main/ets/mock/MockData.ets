/**
 * Mock 数据（PRD 第 7 章）
 * 全部为本地常量数组；id 唯一，供详情页查找。不涉及任何后端。
 */
import {
  UserProfile,
  CourseInfo,
  ActivityInfo,
  ServiceItem,
  Post,
  HealthProfile,
  ToggleItem,
  FunctionEntry,
} from '../model/Models';

// 当前登录用户
export const mockUser: UserProfile = {
  id: 'u1',
  name: '罗欣童',
  studentNo: '20260730',
  college: '信息工程学院',
  courseCount: 5,
  activityCount: 3,
  orderCount: 2,
};

// 课程
export const courses: CourseInfo[] = [
  { id: 'c1', name: '高等数学', teacher: '王建国', time: '周一 1-2 节', location: '理科楼 A201', credit: 4,
    desc: '函数、极限、连续与微积分基础，培养严密的数学思维。', outline: ['函数与极限', '导数与微分', '积分学', '级数'] },
  { id: 'c2', name: '大学英语', teacher: '李雯', time: '周二 3-4 节', location: '外语楼 B105', credit: 2,
    desc: '提升听说读写综合能力，侧重学术英语表达。', outline: ['听说训练', '阅读精读', '学术写作', '词汇拓展'] },
  { id: 'c3', name: '数据结构', teacher: '张伟', time: '周三 5-6 节', location: '计算机楼 C301', credit: 3,
    desc: '线性表、树、图及其算法，程序设计核心基础。', outline: ['线性表', '栈与队列', '树与二叉树', '图'] },
  { id: 'c4', name: '线性代数', teacher: '陈静', time: '周四 1-2 节', location: '理科楼 A102', credit: 3,
    desc: '矩阵、行列式、向量空间与线性变换。', outline: ['行列式', '矩阵', '向量空间', '特征值'] },
  { id: 'c5', name: '计算机网络', teacher: '刘强', time: '周五 7-8 节', location: '计算机楼 C205', credit: 3,
    desc: 'TCP/IP 协议栈、网络层与传输层原理。', outline: ['物理层', '网络层', '传输层', '应用层'] },
];

// 活动
export const activities: ActivityInfo[] = [
  { id: 'a1', title: '迎新篮球赛', time: '2026-09-10 14:00', location: '东区体育馆', status: 'open',
    desc: '各学院新生联队对抗，欢迎围观助威！' },
  { id: 'a2', title: '校园歌手大赛', time: '2026-09-20 19:00', location: '大学生活动中心礼堂', status: 'open',
    desc: '用歌声点亮夜空，年度音乐盛宴。' },
  { id: 'a3', title: '读书分享会', time: '2026-08-30 15:00', location: '图书馆三楼报告厅', status: 'closed',
    desc: '共读经典，分享你的阅读体悟。' },
];

// 校园服务
export const services: ServiceItem[] = [
  { id: 's1', name: '打印复印', desc: '黑白/彩印，自助下单', price: 0.2, qty: 1, checked: true },
  { id: 's2', name: '洗衣服务', desc: '宿舍楼自助洗衣', price: 5, qty: 0, checked: true },
  { id: 's3', name: '宿舍维修', desc: '水电家具报修', price: 20, qty: 0, checked: true },
  { id: 's4', name: '校园快递', desc: '代取代寄包裹', price: 3, qty: 0, checked: true },
];

// 讨论帖
export const posts: Post[] = [
  { id: 'p1', author: '同学A', content: '请问这学期什么时候开始选课呀？', likes: 12, liked: false, time: '2 小时前' },
  { id: 'p2', author: '同学B', content: '图书馆这周新到了一批专业书，速去！', likes: 8, liked: false, time: '5 小时前' },
  { id: 'p3', author: '同学C', content: '周末有人拼车去火车站吗？差一个位置。', likes: 5, liked: false, time: '昨天' },
];

// 健康档案
export const health: HealthProfile = {
  height: 170,
  weight: 60,
};

// 设置开关
export const settings: ToggleItem[] = [
  { id: 't1', title: '消息通知', desc: '接收校园与课程通知', enabled: true },
  { id: 't2', title: '深色模式跟随系统', desc: '随系统切换深浅色', enabled: false },
  { id: 't3', title: 'WiFi 自动下载', desc: '仅 WiFi 下下载资源', enabled: false },
  { id: 't4', title: '隐私保护', desc: '隐藏我的在线状态', enabled: true },
];

// 首页功能入口（图标用 emoji 占位，route 为页面名）
export const functionEntries: FunctionEntry[] = [
  { id: 'e1', title: '课程', icon: '📚', route: 'CoursePage' },
  { id: 'e2', title: '活动', icon: '🎉', route: 'ActivityPage' },
  { id: 'e3', title: '服务', icon: '🛎️', route: 'ServicePage' },
  { id: 'e4', title: '讨论', icon: '💬', route: 'DiscussionPage' },
  { id: 'e5', title: '健康', icon: '❤️', route: 'HealthPage' },
  { id: 'e6', title: '我的', icon: '👤', route: 'ProfilePage' },
];
