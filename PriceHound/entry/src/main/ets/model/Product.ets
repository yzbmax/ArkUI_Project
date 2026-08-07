/** 监控状态枚举 */
export enum MonitorStatus {
  NORMAL = 0,   // 🟢 监控中
  WARN = 1,     // 🟡 波动预警
  ERROR = 2,    // 🔴 异常
  PAUSED = 3,   // ⏸ 已暂停
}

export const monitorStatusName: Map<number, string> = new Map([
  [MonitorStatus.NORMAL, '监控中'],
  [MonitorStatus.WARN, '波动预警'],
  [MonitorStatus.ERROR, '获取异常'],
  [MonitorStatus.PAUSED, '已暂停'],
]);

export const monitorStatusIcon: Map<number, string> = new Map([
  [MonitorStatus.NORMAL, '🟢'],
  [MonitorStatus.WARN, '🟡'],
  [MonitorStatus.ERROR, '🔴'],
  [MonitorStatus.PAUSED, '⏸'],
]);

/** 商品平台枚举 */
export enum Platform {
  TAOBAO = 0,
  JD = 1,
  PINDUODUO = 2,
  SUNING = 3,
  OFFICIAL = 4,
  OTHER = 5,
}

export const platformName: Map<number, string> = new Map([
  [Platform.TAOBAO, '淘宝'],
  [Platform.JD, '京东'],
  [Platform.PINDUODUO, '拼多多'],
  [Platform.SUNING, '苏宁'],
  [Platform.OFFICIAL, '官方商城'],
  [Platform.OTHER, '其他'],
]);

/** 商品模型 */
export class Product {
  id: string;
  name: string;
  imageUrl: string;
  url: string;
  platform: number;
  categoryId: string;
  tags: string[];
  currentPrice: number;
  originalPrice: number;
  lowestPrice: number;
  highestPrice: number;
  status: number;
  isTop: boolean;
  isPurchased: boolean;
  purchasedPrice: number;
  addTime: number;        // 时间戳 ms
  lastRefreshTime: number; // 时间戳 ms

  constructor() {
    this.id = '';
    this.name = '';
    this.imageUrl = '';
    this.url = '';
    this.platform = Platform.OTHER;
    this.categoryId = '';
    this.tags = [];
    this.currentPrice = 0;
    this.originalPrice = 0;
    this.lowestPrice = 0;
    this.highestPrice = 0;
    this.status = MonitorStatus.NORMAL;
    this.isTop = false;
    this.isPurchased = false;
    this.purchasedPrice = 0;
    this.addTime = Date.now();
    this.lastRefreshTime = Date.now();
  }
}
