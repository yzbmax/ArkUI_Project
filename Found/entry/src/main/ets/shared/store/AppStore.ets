/**
 * 全局状态管理（A007）
 * 登录态 / 主题 / 搜索历史 / 浏览足迹 / 缓存，持久化到 Preferences。
 */
import { preferences } from '@kit.ArkData';
import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppTheme } from '../theme/AppTheme';
import { HttpClient } from '../api/HttpClient';

const PREF_NAME = 'found_app_pref';
const DOMAIN: number = 0x0000;
const TAG: string = 'foundTheme';

export class UserProfile {
  id: string = '';
  nickname: string = '';
  avatar: ResourceStr = $r('app.media.user');
  role: string = 'student'; // student/teacher/staff
  campus: string = '中心校区';
  creditLevel: number = 1;
  creditScore: number = 0;
}

/** 后端返回的用户原始结构（数据层） */
export interface UserData {
  id: string;
  nickname: string;
  avatar: string;
  role: string;
  campus: string;
  creditScore: number;
  creditLevel: number;
  realName: string;
  department: string;
  studentId: string;
}

/** 后端用户数据 → UserProfile */
export function userFromJson(raw: UserData): UserProfile {
  const u = new UserProfile();
  u.id = raw.id;
  u.nickname = raw.nickname;
  u.avatar = raw.avatar || '';
  u.role = raw.role;
  u.campus = raw.campus;
  u.creditLevel = raw.creditLevel;
  u.creditScore = raw.creditScore;
  return u;
}

export class AppStore {
  static context: common.UIAbilityContext | null = null;
  static user: UserProfile | null = null;
  static token: string = '';
  static themeMode: string = 'system'; // system | light | dark
  static searchHistory: string[] = [];
  static footprint: string[] = []; // 浏览过的动态 id，最多 100

  static init(ctx: common.UIAbilityContext): void {
    AppStore.context = ctx;
    try {
      const pref = preferences.getPreferencesSync(ctx, { name: PREF_NAME });
      AppStore.themeMode = pref.getSync('themeMode', 'system') as string;
      AppTheme.setDark(AppStore.themeMode === 'dark');
      AppStorage.setOrCreate('isDark', AppStore.themeMode === 'dark');
      const token = pref.getSync('token', '') as string;
      AppStore.token = token;
      AppStorage.setOrCreate('token', token);
      if (token) {
        const raw = JSON.parse(pref.getSync('user', '{}') as string) as UserData;
        AppStore.user = userFromJson(raw);
      }
      AppStore.searchHistory = (pref.getSync('searchHistory', '[]') as string)
        .split(',').filter((s: string) => s.length > 0);
      AppStore.footprint = (pref.getSync('footprint', '') as string)
        .split(',').filter((s: string) => s.length > 0);
    } catch (e) {
      // 数据损坏时恢复默认，避免启动崩溃
      AppStore.user = null;
      AppStore.searchHistory = [];
    }
  }

  static isLogin(): boolean {
    return AppStore.user !== null;
  }

  static login(user: UserProfile, token: string): void {
    AppStore.user = user;
    AppStore.token = token;
    AppStorage.setOrCreate('token', token);
    AppStore.save('token', token);
    AppStore.save('user', JSON.stringify(user));
  }

  static logout(): void {
    AppStore.user = null;
    AppStore.token = '';
    AppStorage.setOrCreate('token', '');
    AppStore.save('token', '');
    AppStore.save('user', '{}');
  }

  /** 用 token 拉取最新用户信息（Splash 校验 token 有效性），失败则登出 */
  static async me(): Promise<void> {
    try {
      const data: UserData = await HttpClient.get<UserData>('/api/auth/me');
      AppStore.user = userFromJson(data);
    } catch (e) {
      AppStore.logout();
    }
  }

  static addSearchHistory(kw: string): void {
    if (!kw.trim()) {
      return;
    }
    AppStore.searchHistory = [kw, ...AppStore.searchHistory.filter((s) => s !== kw)].slice(0, 20);
    AppStore.save('searchHistory', AppStore.searchHistory.join(','));
  }

  static clearSearchHistory(): void {
    AppStore.searchHistory = [];
    AppStore.save('searchHistory', '');
  }

  static addFootprint(id: string): void {
    AppStore.footprint = [id, ...AppStore.footprint.filter((s) => s !== id)].slice(0, 100);
    AppStore.save('footprint', AppStore.footprint.join(','));
  }

  static clearFootprint(): void {
    AppStore.footprint = [];
    AppStore.save('footprint', '');
  }

  static save(key: string, value: string): void {
    if (!AppStore.context) {
      return;
    }
    try {
      const pref = preferences.getPreferencesSync(AppStore.context, { name: PREF_NAME });
      pref.putSync(key, value);
      pref.flushSync();
    } catch (e) {
      // 持久化失败时忽略
    }
  }

  static setDark(dark: boolean): void {
    AppTheme.setDark(dark);
    AppStore.themeMode = dark ? 'dark' : 'light';
    AppStore.save('themeMode', AppStore.themeMode);
    AppStore.save('isDark', dark ? 'true' : 'false');
    // 先应用颜色模式（改变运行配置），再更新 AppStorage 触发页面重渲染，
    // 使 $r() 在重渲染时按新配置重新解析（否则资源已切但界面不刷新）。
    // themeVersion 每次切换都 +1，保证即便 isDark 值未变化也一定触发重渲染。
    AppStore.applyColorMode();
    AppStorage.setOrCreate('isDark', dark);
    const ver: number = AppStorage.get<number>('themeVersion') ?? 0;
    AppStorage.setOrCreate('themeVersion', ver + 1);
  }

  /** 按存储的 themeMode 应用全局颜色模式，触发 dark 资源生效 */
  static applyColorMode(): void {
    if (!AppStore.context) {
      hilog.error(DOMAIN, TAG, 'applyColorMode: context is null');
      return;
    }
    try {
      const mode = AppStore.themeModeValue();
      AppStore.context.getApplicationContext().setColorMode(mode);
      hilog.info(DOMAIN, TAG, 'applyColorMode set mode=%{public}d themeMode=%{public}s', mode, AppStore.themeMode);
    } catch (e) {
      hilog.error(DOMAIN, TAG, 'applyColorMode failed: %{public}s', JSON.stringify(e));
    }
  }

  /** themeMode → 颜色模式枚举 */
  static themeModeValue(): ConfigurationConstant.ColorMode {
    if (AppStore.themeMode === 'dark') {
      return ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    }
    if (AppStore.themeMode === 'light') {
      return ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    }
    return ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET;
  }
}
