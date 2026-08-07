/**
 * AppConstants.ets
 * 应用级常量：路由路径、数据源配置、默认值
 */

export class RoutePath {
  static readonly INDEX: string = 'pages/Index';
  static readonly DASHBOARD: string = 'pages/DashboardPage';
  static readonly DISCOVER: string = 'pages/DiscoverPage';
  static readonly ALERT: string = 'pages/AlertPage';
  static readonly PROFILE: string = 'pages/ProfilePage';
  static readonly ADD_PRODUCT: string = 'pages/AddProductPage';
  static readonly PRODUCT_DETAIL: string = 'pages/ProductDetailPage';
  static readonly PRICE_CHART: string = 'pages/PriceChartPage';
  static readonly COMPARE: string = 'pages/ComparePage';
  static readonly ALERT_SETTING: string = 'pages/AlertSettingPage';
  static readonly EXPORT: string = 'pages/ExportPage';
  static readonly MONITOR_SETTING: string = 'pages/MonitorSettingPage';
  static readonly NOTIFICATION_SETTING: string = 'pages/NotificationSettingPage';
  static readonly APPEARANCE_SETTING: string = 'pages/AppearanceSettingPage';
  static readonly ABOUT: string = 'pages/AboutPage';
  static readonly BACKUP: string = 'pages/BackupRestorePage';
}

export enum DataSourceType {
  MOCK = 0,
  COINGECKO = 1,
}

export class AppConfig {
  static readonly APP_NAME: string = 'PriceHound';
  static readonly VERSION: string = '1.0.0';
  static readonly DEFAULT_REFRESH_MINUTES: number = 30;
  static readonly MAX_PRICE_RECORDS: number = 50;
  static readonly WIFI_ONLY_DEFAULT: boolean = false;
  static readonly BATTERY_PAUSE_DEFAULT: boolean = true;
  static readonly DEFAULT_DATA_SOURCE: number = DataSourceType.MOCK;
}

export class StorageKey {
  static readonly DATA_SOURCE: string = 'settings.dataSource';
  static readonly REFRESH_MINUTES: string = 'settings.refreshMinutes';
  static readonly WIFI_ONLY: string = 'settings.wifiOnly';
  static readonly BATTERY_PAUSE: string = 'settings.batteryPause';
  static readonly NOTIFY_ENABLED: string = 'settings.notifyEnabled';
  static readonly NOTIFY_SOUND: string = 'settings.notifySound';
  static readonly NOTIFY_VIBRATE: string = 'settings.notifyVibrate';
  static readonly REPORT_TIME: string = 'settings.reportTime';
  static readonly DND_ENABLED: string = 'settings.dndEnabled';
  static readonly THEME_MODE: string = 'settings.themeMode';
  static readonly PRODUCTS: string = 'data.products';
  static readonly PRICE_RECORDS: string = 'data.priceRecords';
  static readonly ALERT_RULES: string = 'data.alertRules';
  static readonly NOTIFICATIONS: string = 'data.notifications';
}

export enum ThemeMode {
  LIGHT = 0,
  DARK = 1,
  SYSTEM = 2,
}
