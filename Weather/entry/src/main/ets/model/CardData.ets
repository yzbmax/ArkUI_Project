/**
 * 卡片核心数据模型
 * 包含天气、步数、时间、颜色、粒子状态、哲言等完整卡片信息
 */
export interface WeatherData {
  weatherCode: number;        // 天气码：0=晴, 1=多云, 2=阴, 3=雨, 4=雪
  temperature: number;        // 当前温度（摄氏度）
  description: string;        // 天气描述文案
}

export enum DayPeriod {
  MORNING = 'morning',        // 早晨 06:00-11:00
  NOON = 'noon',              // 午间 11:00-14:00
  AFTERNOON = 'afternoon',    // 黄昏 14:00-19:00
  NIGHT = 'night'             // 深夜 19:00-06:00
}

export interface CardData {
  // 原始数据
  weather: WeatherData;
  steps: number;
  timestamp: number;
  dayPeriod: DayPeriod;

  // 视觉映射结果
  primaryColor: string;       // 主色调 hex
  secondaryColor: string;     // 辅助色调 hex
  cardBgColor: string;        // 卡片背景色 rgba
  particleColor: string;      // 粒子主色
  textColor: string;          // 文字颜色
  glowColor: string;          // 光晕颜色

  // 粒子系统参数
  particleCount: number;      // 粒子总数 80-200
  particleSpeed: number;      // 粒子基础速度 0.3-2.0
  gravityDirection: number;   // 重力方向 -1上浮, 0无, 1下坠
  particleOpacity: number;    // 粒子透明度 0.3-1.0
  particleType: ParticleType; // 粒子形态

  // 内容
  quote: string;              // 今日哲言
  quoteAuthor: string;        // 哲言出处/作者
  dateStr: string;            // 格式化日期 e.g. "7月27日"
  temperatureStr: string;     // 格式化温度 e.g. "28°C"

  // 标识
  cardId: string;             // 唯一标识（日期+时间戳）
  isFavorite: boolean;        // 是否已收藏
}

export enum ParticleType {
  CIRCLE = 'circle',          // 圆点（晴天/多云）
  LINE = 'line',              // 短线条（阴天）
  DROP = 'drop',              // 雨滴（雨天）
  HEXAGON = 'hexagon'         // 六角形（雪天）
}

/**
 * 粒子实例运行时数据
 */
export interface Particle {
  x: number;
  y: number;
  vx: number;                 // x方向速度
  vy: number;                 // y方向速度
  radius: number;             // 大小
  opacity: number;            // 当前透明度
  life: number;               // 生命周期 0-1
  phase: number;              // 相位（用于摇摆等周期性运动）
  baseX: number;              // 避让归位后的目标x
  baseY: number;              // 避让归位后的目标y
  type: ParticleType;
  color: string;
}
