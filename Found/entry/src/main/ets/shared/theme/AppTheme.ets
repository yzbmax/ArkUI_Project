/**
 * 全局主题管理（A003）
 * 浅色 / 深色两套映射，全部引用 DESIGN.md 8.1/8.2 token。
 * 通过 AppStorage 全局共享，深浅模式即时切换。
 */
export class ThemeColors {
  bgPage: Resource = $r('app.color.bg_parchment');
  bgCard: Resource = $r('app.color.bg_ivory');
  bgSand: Resource = $r('app.color.bg_sand');
  textPrimary: Resource = $r('app.color.text_near_black');
  textSecondary: Resource = $r('app.color.text_charcoal');
  textAux: Resource = $r('app.color.text_olive');
  textWeak: Resource = $r('app.color.text_stone');
  border: Resource = $r('app.color.border_cream');
  borderWarm: Resource = $r('app.color.border_warm');
  brand: Resource = $r('app.color.brand_terracotta');
  white: Resource = $r('app.color.bg_ivory');
}

const LIGHT: ThemeColors = new ThemeColors();

const DARK: ThemeColors = (() => {
  const t = new ThemeColors();
  t.bgPage = $r('app.color.bg_deep_dark');
  t.bgCard = $r('app.color.bg_dark_surface');
  t.bgSand = $r('app.color.bg_dark_surface');
  t.textPrimary = $r('app.color.text_warm_silver');
  t.textSecondary = $r('app.color.text_warm_silver');
  t.textAux = $r('app.color.text_stone');
  t.textWeak = $r('app.color.text_stone');
  t.border = $r('app.color.bg_dark_surface');
  t.borderWarm = $r('app.color.bg_dark_surface');
  return t;
})();

export class AppTheme {
  static isDark: boolean = false;

  static current(): ThemeColors {
    return AppTheme.isDark ? DARK : LIGHT;
  }

  static setDark(dark: boolean): void {
    AppTheme.isDark = dark;
    AppStorage.setOrCreate('isDark', dark);
  }

  static toggle(): void {
    AppTheme.setDark(!AppTheme.isDark);
  }
}
