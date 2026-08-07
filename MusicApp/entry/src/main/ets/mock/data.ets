/**
 * 本地模拟数据（Mock）
 * 封面以 color 占位，零网络依赖、离线可渲染。
 * 后端就绪后由 HttpMusicRepository 替换，页面与组件零改动。
 */
import {
  SwiperType,
  DailyRecommendType,
  RecommendListType,
  SongItemType,
  MomentListType,
  UserType,
} from '../models/index';

// 轮播 banner
export const swiperData: SwiperType[] = [
  { id: 's1', img: '', color: '#1ed760', title: '每日推荐 · 为你而歌' },
  { id: 's2', img: '', color: '#539df5', title: '热门新歌 · 抢先听' },
  { id: 's3', img: '', color: '#f3727f', title: '经典回放 · 时光机' },
];

// 每日推荐（横向卡片行）
export const dailyRecommendData: DailyRecommendType[] = [
  { id: 'd1', img: '', color: '#1ed760', title: '私人雷达', type: '根据你的口味', top: '每日', bottom: '为你生成' },
  { id: 'd2', img: '', color: '#ffa42b', title: '怀旧专场', type: '80/90 金曲', top: '每日', bottom: '回忆杀' },
  { id: 'd3', img: '', color: '#539df5', title: '通勤能量', type: '节奏感十足', top: '每日', bottom: '打工人' },
  { id: 'd4', img: '', color: '#f3727f', title: '深夜电台', type: '安静治愈', top: '每日', bottom: '伴你入眠' },
];

// 推荐歌单（横向卡片行）
export const recommendListData: RecommendListType[] = [
  { id: 'r1', img: '', color: '#1ed760', title: '华语流行精选', count: '128万' },
  { id: 'r2', img: '', color: '#539df5', title: '轻音乐图书馆', count: '86万' },
  { id: 'r3', img: '', color: '#ffa42b', title: '运动燃脂歌单', count: '54万' },
  { id: 'r4', img: '', color: '#f3727f', title: '民谣故事集', count: '37万' },
];

// 歌曲列表（发现页 / 播放）
export const songListData: SongItemType[] = [
  { id: 'g1', img: '', color: '#1ed760', title: '晴天', artist: '周杰伦', url: '' },
  { id: 'g2', img: '', color: '#539df5', title: '起风了', artist: '买辣椒也用券', url: '' },
  { id: 'g3', img: '', color: '#ffa42b', title: '夜空中最亮的星', artist: '逃跑计划', url: '' },
  { id: 'g4', img: '', color: '#f3727f', title: '平凡之路', artist: '朴树', url: '' },
  { id: 'g5', img: '', color: '#1db954', title: '成都', artist: '赵雷', url: '' },
  { id: 'g6', img: '', color: '#7c7c7c', title: '理想三旬', artist: '陈鸿宇', url: '' },
];

// 动态（互动广场）
export const momentListData: MomentListType[] = [
  {
    id: 'm1',
    author: '音乐旅人',
    avatar: '',
    avatarColor: '#1ed760',
    content: '今天循环了一整天的这首歌，太治愈了。',
    comment: 32,
    like: 128,
    share: 12,
    song: songListData[0],
  },
  {
    id: 'm2',
    author: '耳机里的世界',
    avatar: '',
    avatarColor: '#539df5',
    content: '分享一份适合深夜写代码的无歌词歌单。',
    comment: 8,
    like: 56,
    share: 3,
    song: songListData[2],
  },
  {
    id: 'm3',
    author: '现场控',
    avatar: '',
    avatarColor: '#ffa42b',
    content: 'live 版真的比录音室更有张力！',
    comment: 15,
    like: 240,
    share: 20,
    song: songListData[3],
  },
];

// 用户信息（我的页）
export const userData: UserType = {
  name: '黑马音乐人',
  vip: true,
  age: 24,
  star: '天秤座',
  city: '杭州',
  follow: 123,
  fans: 456,
  avatar: '',
  avatarColor: '#1ed760',
  collects: [songListData[0], songListData[1], songListData[2], songListData[3], songListData[4], songListData[5]],
};
