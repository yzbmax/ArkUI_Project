/**
 * DesignTokens.ets
 * Claude 暖色调设计系统 Token 定义（对应 docs/DESIGN.md）
 * 所有颜色 / 字体 / 间距 / 圆角 / 阴影统一在此维护
 */

export class DesignColors {
  // Primary
  static readonly NEAR_BLACK: string = '#141413';      // 主文字 / 深色背景
  static readonly TERRACOTTA: string = '#c96442';      // 品牌主色 CTA
  static readonly CORAL: string = '#d97757';           // 浅珊瑚强调

  // Accent
  static readonly ERROR_CRIMSON: string = '#b53333';   // 错误 / 涨价
  static readonly FOCUS_BLUE: string = '#3898ec';      // 输入聚焦环（唯一冷色）

  // Surface
  static readonly PARCHMENT: string = '#f5f4ed';       // 页面背景
  static readonly IVORY: string = '#faf9f5';           // 卡片表面
  static readonly WARM_SAND: string = '#e8e6dc';       // 次级按钮
  static readonly DARK_SURFACE: string = '#30302e';    // 深色表面
  static readonly DEEP_DARK: string = '#141413';       // 深色背景

  // Neutrals & Text
  static readonly CHARCOAL_WARM: string = '#4d4c48';   // 按钮文字
  static readonly OLIVE_GRAY: string = '#5e5d59';      // 次级正文
  static readonly STONE_GRAY: string = '#87867f';      // 三级文字
  static readonly DARK_WARM: string = '#3d3d3a';       // 深暖文字
  static readonly WARM_SILVER: string = '#b0aea5';     // 深色背景文字

  // Border & Ring
  static readonly BORDER_CREAM: string = '#f0eee6';    // 浅边框
  static readonly BORDER_WARM: string = '#e8e6dc';     // 强调边框
  static readonly BORDER_DARK: string = '#30302e';     // 深色边框
  static readonly RING_WARM: string = '#d1cfc5';       // 按钮环
  static readonly RING_DEEP: string = '#c2c0b6';       // 按压环

  // Semantic
  static readonly DROP_DOWN: string = '#c96442';       // 降价（与品牌同色）
  static readonly RISE_UP: string = '#b53333';         // 涨价
  static readonly STATUS_OK: string = '#7a9e6b';       // 监控正常（暖绿）
  static readonly STATUS_WARN: string = '#d9a441';     // 监控预警（暖黄）
  static readonly STATUS_STOP: string = '#87867f';     // 监控暂停（石灰）
}

export class DesignTypography {
  static readonly FONT_SERIF: string = 'serif';        // 标题衬线
  static readonly FONT_SANS: string = 'sans-serif';    // UI 无衬线
  static readonly FONT_MONO: string = 'monospace';     // 价格等宽

  // 标题（Serif 500）
  static readonly SIZE_H1: number = 32;
  static readonly SIZE_H2: number = 25;
  static readonly SIZE_H3: number = 21;
  static readonly SIZE_TITLE: number = 20;
  // 正文（Sans）
  static readonly SIZE_BODY_LG: number = 20;
  static readonly SIZE_BODY: number = 16;
  static readonly SIZE_BODY_SM: number = 15;
  static readonly SIZE_CAPTION: number = 14;
  static readonly SIZE_LABEL: number = 12;
  static readonly SIZE_OVERLINE: number = 10;
  // 价格（Mono）
  static readonly SIZE_PRICE_LG: number = 36;
  static readonly SIZE_PRICE: number = 25;
  static readonly SIZE_PRICE_SM: number = 18;
}

export class DesignSpacing {
  static readonly XS: number = 4;
  static readonly SM: number = 8;
  static readonly MD: number = 12;
  static readonly LG: number = 16;
  static readonly XL: number = 24;
  static readonly XXL: number = 32;
  static readonly SECTION: number = 40;
}

export class DesignRadius {
  static readonly SM: number = 8;      // 舒适圆角
  static readonly MD: number = 12;     // 慷慨圆角
  static readonly LG: number = 16;     // 大圆角
  static readonly XL: number = 32;     // 最大圆角
}

/** 深色模式色板映射 */
export class DarkColors {
  static readonly BG: string = '#141413';
  static readonly CARD: string = '#30302e';
  static readonly CARD_ELEVATED: string = '#3d3d3a';
  static readonly TEXT_PRIMARY: string = '#faf9f5';
  static readonly TEXT_SECONDARY: string = '#b0aea5';
  static readonly TEXT_TERTIARY: string = '#87867f';
  static readonly BORDER: string = '#30302e';
  static readonly BORDER_SUBTLE: string = '#3d3d3a';
}
