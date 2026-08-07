import { ThemeMode, StorageKey } from '../constants/AppConstants';
import { DarkColors } from '../constants/DesignTokens';

/**
 * ThemeManager.ets
 * 主题管理：浅色 / 深色 / 跟随系统
 * - 通过 AppStorage 广播 isDark 状态，组件内可用 @StorageProp('theme.isDark') 订阅
 * - 主题偏好持久化到 PersistentStorage
 */
export class ThemeManager {
  static readonly IS_DARK_KEY: string = 'theme.isDark';
  static readonly SYSTEM_DARK_KEY: string = 'theme.systemDark';

  /** 应用启动时初始化：注册持久化 + 计算初始主题 */
  static init(): void {
    PersistentStorage.persistProp(StorageKey.THEME_MODE, ThemeMode.SYSTEM);
    PersistentStorage.persistProp(ThemeManager.IS_DARK_KEY, false);
    // 系统深色跟随持久化
    if (AppStorage.get<boolean>(ThemeManager.SYSTEM_DARK_KEY) === undefined) {
      AppStorage.setOrCreate(ThemeManager.SYSTEM_DARK_KEY, false);
    }
    ThemeManager.refresh();
  }

  /** 切换主题模式（0 浅色 / 1 深色 / 2 跟随系统） */
  static setMode(mode: number): void {
    AppStorage.setOrCreate(StorageKey.THEME_MODE, mode);
    ThemeManager.refresh();
  }

  /** 由系统配置更新（如跟随系统时系统主题变化） */
  static setSystemDark(dark: boolean): void {
    AppStorage.setOrCreate(ThemeManager.SYSTEM_DARK_KEY, dark);
    ThemeManager.refresh();
  }

  /** 重新计算并广播 isDark */
  static refresh(): void {
    const mode: number = AppStorage.get<number>(StorageKey.THEME_MODE) ?? ThemeMode.SYSTEM;
    const sysDark: boolean = AppStorage.get<boolean>(ThemeManager.SYSTEM_DARK_KEY) ?? false;
    const isDark: boolean = mode === ThemeMode.DARK || (mode === ThemeMode.SYSTEM && sysDark);
    AppStorage.setOrCreate(ThemeManager.IS_DARK_KEY, isDark);
  }

  /** 当前是否深色 */
  static isDark(): boolean {
    const v = AppStorage.get<boolean>(ThemeManager.IS_DARK_KEY);
    return v === undefined ? false : v;
  }

  /** 当前主题模式 */
  static currentMode(): number {
    const v = AppStorage.get<number>(StorageKey.THEME_MODE);
    return v === undefined ? ThemeMode.SYSTEM : v;
  }

  /** 根据主题返回颜色 */
  static color(light: string, dark: string): string {
    return ThemeManager.isDark() ? dark : light;
  }

  // ---- 语义色便捷方法（页面直接使用，无需手动分支） ----

  /** 页面背景 */
  static bg(): string {
    return ThemeManager.color('#f5f4ed', DarkColors.BG);
  }

  /** 卡片表面 */
  static card(): string {
    return ThemeManager.color('#faf9f5', DarkColors.CARD);
  }

  /** 次级表面 / 输入框底 */
  static surface(): string {
    return ThemeManager.color('#e8e6dc', DarkColors.CARD_ELEVATED);
  }

  /** 主文字 */
  static textPrimary(): string {
    return ThemeManager.color('#141413', DarkColors.TEXT_PRIMARY);
  }

  /** 次级文字 */
  static textSecondary(): string {
    return ThemeManager.color('#5e5d59', DarkColors.TEXT_SECONDARY);
  }

  /** 三级文字 / 占位 */
  static textTertiary(): string {
    return ThemeManager.color('#87867f', DarkColors.TEXT_TERTIARY);
  }

  /** 边框 */
  static border(): string {
    return ThemeManager.color('#f0eee6', DarkColors.BORDER);
  }

  /** 品牌主色（深浅色下保持一致，深色下略提亮） */
  static accent(): string {
    return ThemeManager.color('#c96442', '#d97757');
  }

  /** 降价 */
  static drop(): string {
    return ThemeManager.color('#c96442', '#d97757');
  }

  /** 涨价 */
  static rise(): string {
    return ThemeManager.color('#b53333', '#e06060');
  }

  /** 监控正常 */
  static ok(): string {
    return ThemeManager.color('#7a9e6b', '#8fae7e');
  }

  /** 监控预警 */
  static warn(): string {
    return ThemeManager.color('#d9a441', '#e0b054');
  }
}
