/**
 * 应用常量定义
 */
export class Constants {
  // 粒子系统
  static readonly PARTICLE_MIN_COUNT = 80;
  static readonly PARTICLE_MAX_COUNT = 200;
  static readonly PARTICLE_DEFAULT_COUNT = 150;

  // 动画参数
  static readonly BREATHE_DURATION = 8000;      // 呼吸动画周期 8秒
  static readonly BREATHE_SCALE_MIN = 0.98;     // 最小缩放
  static readonly BREATHE_SCALE_MAX = 1.02;     // 最大缩放
  static readonly LIGHT_SWEEP_INTERVAL_MIN = 10000;  // 光掠动画最小间隔
  static readonly LIGHT_SWEEP_INTERVAL_MAX = 15000;  // 光掠动画最大间隔
  static readonly LIGHT_SWEEP_DURATION = 1500;       // 光掠动画时长
  static readonly RIPPLE_DURATION = 800;              // 波纹动画时长

  // 卡片样式
  static readonly CARD_BORDER_RADIUS = 24;
  static readonly CARD_BORDER_OPACITY = 0.15;
  static readonly CARD_BACKDROP_BLUR = 20;     // 背景模糊强度

  // 文字样式
  static readonly QUOTE_FONT_SIZE = 28;
  static readonly QUOTE_LINE_HEIGHT = 40;
  static readonly INFO_FONT_SIZE = 12;

  // 数据刷新间隔（毫秒）
  static readonly WEATHER_REFRESH_INTERVAL = 30 * 60 * 1000;  // 30分钟
  static readonly STEPS_REFRESH_INTERVAL = 10 * 60 * 1000;    // 10分钟

  // 存储键
  static readonly PREF_NAME = 'floating_light_store';
  static readonly KEY_DAILY_CARD = 'daily_card';
  static readonly KEY_FAVORITES = 'favorites_list';
}
