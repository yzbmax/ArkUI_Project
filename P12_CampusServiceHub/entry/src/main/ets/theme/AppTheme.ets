/**
 * AppTheme —— 全局唯一视觉来源
 * 翻译自 docs/DESIGN.md（Apple 设计语言），所有页面/组件只引用此处 token，禁止硬编码色值/尺寸。
 * 注：ArkTS 不支持 `as const` 与无类型对象字面量，故每个 token 对象均声明显式接口。
 */

// 色彩 Token（PRD 第 4.1 章）
export interface ColorToken {
  black: number;
  bgLight: number;
  textDark: number;
  blue: number;
  linkBlue: number;
  brightBlue: number;
  white: number;
  textSecondary: number;
  textTertiary: number;
  darkSurface: number;
  cardShadow: number;
  whiteSecondary: number;
  whiteTertiary: number;
  navBarBg: number;
}

export const Colors: ColorToken = {
  black: 0x000000,          // 沉浸深色背景
  bgLight: 0xF5F5F7,        // 页面/浅色卡背景
  textDark: 0x1D1D1F,       // 浅底主文本 / 深色按钮
  blue: 0x0071E3,           // Apple Blue 唯一强调色
  linkBlue: 0x0066CC,       // 浅底内联链接
  brightBlue: 0x2997FF,     // 深底链接
  white: 0xFFFFFF,          // 深底文本 / 按钮文字
  textSecondary: 0xCC000000,// 次级文本 (黑 80%)
  textTertiary: 0x7A000000, // 三级/禁用 (黑 48%)
  darkSurface: 0x272729,    // 深底卡片
  cardShadow: 0x38000000,   // 唯一柔和阴影色 (黑 22%)
  whiteSecondary: 0xCCFFFFFF, // 深底次级文本 (白 80%)
  whiteTertiary: 0x7AFFFFFF,  // 深底三级文本 (白 48%)
  navBarBg: 0xCC000000,       // 玻璃导航栏背景 (黑 80%)
};

// 字体排版 Token（PRD 第 4.2 章，HarmonyOS Sans 替代 SF Pro，保留尺寸/字重/行高/字距）
export interface FontSpec {
  size: number;
  weight: number;
  lineHeight: number;
  letterSpacing: number;
}

export interface FontToken {
  hero: FontSpec;
  section: FontSpec;
  tileHeading: FontSpec;
  cardTitle: FontSpec;
  subHeading: FontSpec;
  body: FontSpec;
  bodyEmphasis: FontSpec;
  link: FontSpec;
  caption: FontSpec;
  micro: FontSpec;
  nano: FontSpec;
}

export const Font: FontToken = {
  hero:        { size: 56, weight: 600, lineHeight: 60, letterSpacing: -0.28 },
  section:     { size: 40, weight: 600, lineHeight: 44, letterSpacing: 0 },
  tileHeading: { size: 28, weight: 400, lineHeight: 32, letterSpacing: 0.196 },
  cardTitle:   { size: 21, weight: 700, lineHeight: 25, letterSpacing: 0.231 },
  subHeading:  { size: 21, weight: 400, lineHeight: 25, letterSpacing: 0.231 },
  body:        { size: 17, weight: 400, lineHeight: 25, letterSpacing: -0.374 },
  bodyEmphasis:{ size: 17, weight: 600, lineHeight: 21, letterSpacing: -0.374 },
  link:        { size: 14, weight: 400, lineHeight: 20, letterSpacing: -0.224 },
  caption:     { size: 14, weight: 400, lineHeight: 18, letterSpacing: -0.224 },
  micro:       { size: 12, weight: 400, lineHeight: 16, letterSpacing: -0.12 },
  nano:        { size: 10, weight: 400, lineHeight: 15, letterSpacing: -0.08 },
};

// 间距系统（PRD 第 4.6 章，基准 8vp）
export interface SpaceToken {
  xs: number;
  sm: number;
  md: number;
  lg: number;
  xl: number;
  xxl: number;
}

export const Space: SpaceToken = {
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
};

// 圆角（PRD 第 4.3 / 4.4 章）
export interface RadiusToken {
  card: number;
  cardSmall: number;
  cta: number;
}

export const Radius: RadiusToken = {
  card: 12,
  cardSmall: 8,
  cta: 8,
};

// 唯一柔和阴影（PRD 第 4.4 章）
export interface ShadowToken {
  radius: number;
  color: number;
  offsetX: number;
  offsetY: number;
}

export const CardShadow: ShadowToken = {
  radius: 30,
  color: Colors.cardShadow,
  offsetX: 3,
  offsetY: 5,
};

// 玻璃导航栏高度（PRD 第 4.5 章）
export const NavHeight = 48;

// 通用 UI 尺寸（避免页面硬编码）
export interface UIToken {
  avatarSize: number;
  avatarRadius: number;
}

export const UI: UIToken = {
  avatarSize: 56,
  avatarRadius: 28,
};
