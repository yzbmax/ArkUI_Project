/**
 * 设计系统令牌（集中来源）
 * 映射 docs/DESIGN.md（Spotify 暗色沉浸式体系）。
 * 全站颜色 / 字号 / 间距 / 圆角 / 阴影统一从此处取用，
 * 禁止在任何页面或组件中硬编码十六进制色值。
 * 严格 ArkTS：导出对象字面量必须显式声明对应接口（arkts-no-untyped-obj-literals）。
 */
interface IColors {
  bg: string;
  surface: string;
  surfaceMid: string;
  surfaceMidW: string;
  surfaceHi: string;
  border: string;
  borderLight: string;
  textPrimary: string;
  textSecondary: string;
  accent: string;
  accentBorder: string;
  negative: string;
  warning: string;
  info: string;
  overlay: string;    // 半透明深灰（Tab 选中态底）
  transparent: string; // 完全透明（占位框无背景时）
}

interface IFont {
  family: string;
  title: number;
  head: number;
  body: number;
  caption: number;
  small: number;
  micro: number;
}

interface ISpace {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
  xxl: number;
  taptop:number
}

interface IRadius {
  card: number;
  cover: number; // 歌曲列表封面小圆角
  pill: number;
  circle: string;
  tab: number; // Tab 选中态圆角
}

interface IShadowOptions {
  radius: number;
  color: string;
  offsetX: number;
  offsetY: number;
}

interface IShadow {
  heavy: IShadowOptions;
  card: IShadowOptions;
}

export const Colors: IColors = {
  bg: '#000000',           // 页面最深背景（纯黑，Level 0）
  surface: '#121212',      // 卡片 / 容器表面（深灰，Level 1）
  surfaceMid: '#1f1f1f',   // 按钮 / 交互表面
  surfaceMidW: '#fff',
  surfaceHi: '#252525',    // 抬升卡片表面
  border: '#4d4d4d',       // 按钮边框（暗色）
  borderLight: '#7c7c7c',  // 描边按钮边框 / 静音链接
  textPrimary: '#ffffff',  // 主文字
  textSecondary: '#b3b3b3', // 次要文字 / 非激活导航
  accent: '#1DB954',       // 品牌绿：强调 / 选中态 / 进度 / 主操作
  accentBorder: '#1ed760',
  negative: '#f3727f',     // 负向 / 错误
  warning: '#ffa42b',      // 警示
  info: '#539df5',         // 提示
  overlay: 'rgba(100,100,100,0.4)', // 半透明深灰叠加（Tab 选中态底）
  transparent: 'rgba(0,0,0,0)', // 完全透明
};

export const Font: IFont = {
  family: 'HarmonyOS Sans',
  title: 28,  // 一级标题（白色 Bold）
  head: 20,   // 二级标题（白色 Medium）
  body: 16,   // 正文（白色 Medium）
  caption: 14, // 辅助文字（浅灰 Regular）
  small: 12,  // 标签 / 计数
  micro: 10,  // 最小文字
};

// 间距系统：8px 基准
export const Space: ISpace = {
  xs: 4,
  sm: 8,
  taptop:0.5,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
};

export const Radius: IRadius = {
  card: 12,       // 普通容器统一圆角（卡片 / 搜索框 / 按钮 / 输入框）
  cover: 8,       // 歌曲列表封面小圆角
  pill: 9999,     // 胶囊按钮（全圆角）
  circle: '50%',  // 圆形（播放键 / 头像 / 图标）
  tab: 14,        // Tab 选中态圆角
};

export const Shadow: IShadow = {
  heavy: { radius: 24, color: 'rgba(0,0,0,0.5)', offsetX: 0, offsetY: 8 }, // 弹层 / 对话框（Level 3）
  card: { radius: 8, color: 'rgba(0,0,0,0.3)', offsetX: 0, offsetY: 8 },  // 卡片抬升（Level 2）
};
