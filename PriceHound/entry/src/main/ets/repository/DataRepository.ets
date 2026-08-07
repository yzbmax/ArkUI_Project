import { Product, MonitorStatus } from '../model/Product';
import { PriceRecord } from '../model/PriceRecord';
import { AlertRule } from '../model/AlertRule';
import { AppNotification } from '../model/AppNotification';
import { Category } from '../model/Category';
import { Tag } from '../model/Tag';
import { MockProducts } from '../mock/MockProducts';
import { MockPriceRecords } from '../mock/MockPriceRecords';
import { MockAlertRules } from '../mock/MockAlertRules';
import { MockNotifications } from '../mock/MockNotifications';
import { MockCategories } from '../mock/MockCategories';
import { MockTags } from '../mock/MockTags';
import { DataSourceType } from '../constants/AppConstants';
import { CoinGeckoApi, CoinMarket } from '../service/CoinGeckoApi';

/**
 * DataRepository.ets
 * 全局单例数据仓库：商品 / 价格记录 / 提醒规则 / 通知
 * 内置 Mock 数据，支持切换 CoinGecko 免费 API 数据源
 */

let instance: DataRepository | null = null;

export class DataRepository {
  products: Array<Product>;
  priceRecords: Map<string, Array<PriceRecord>>;
  alertRules: Array<AlertRule>;
  notifications: Array<AppNotification>;
  categories: Array<Category>;
  tags: Array<Tag>;
  dataSource: number;
  coinMarkets: Array<CoinMarket> = [];

  private constructor() {
    this.products = MockProducts.load();
    this.priceRecords = new Map();
    this.alertRules = MockAlertRules.list;
    this.notifications = MockNotifications.list;
    this.categories = MockCategories.list;
    this.tags = MockTags.list;
    this.dataSource = DataSourceType.MOCK;
    // 初始化价格记录
    for (let i = 0; i < this.products.length; i++) {
      const p = this.products[i];
      this.priceRecords.set(p.id, MockPriceRecords.forProduct(p.id, p.currentPrice));
    }
  }

  static getInstance(): DataRepository {
    if (instance === null) {
      instance = new DataRepository();
    }
    return instance;
  }

  /** 价格记录 */
  getRecords(productId: string): Array<PriceRecord> {
    const rec = this.priceRecords.get(productId);
    return rec !== undefined ? rec : [];
  }

  /** 商品 */
  getProduct(productId: string): Product | undefined {
    for (let i = 0; i < this.products.length; i++) {
      if (this.products[i].id === productId) {
        return this.products[i];
      }
    }
    return undefined;
  }

  addProduct(p: Product): void {
    this.products.unshift(p);
    this.priceRecords.set(p.id, MockPriceRecords.forProduct(p.id, p.currentPrice));
  }

  updateProduct(p: Product): void {
    for (let i = 0; i < this.products.length; i++) {
      if (this.products[i].id === p.id) {
        this.products[i] = p;
        break;
      }
    }
  }

  removeProduct(productId: string): void {
    this.products = this.products.filter((p) => p.id !== productId);
    this.priceRecords.delete(productId);
    this.alertRules = this.alertRules.filter((r) => r.productId !== productId);
  }

  toggleTop(productId: string): void {
    const p = this.getProduct(productId);
    if (p !== undefined) {
      p.isTop = !p.isTop;
    }
  }

  markPurchased(productId: string, price: number): void {
    const p = this.getProduct(productId);
    if (p !== undefined) {
      p.isPurchased = true;
      p.purchasedPrice = price;
    }
  }

  /** 提醒规则 */
  addAlertRule(rule: AlertRule): void {
    this.alertRules.unshift(rule);
  }

  toggleAlertRule(ruleId: string): void {
    for (let i = 0; i < this.alertRules.length; i++) {
      if (this.alertRules[i].id === ruleId) {
        this.alertRules[i].isActive = !this.alertRules[i].isActive;
        break;
      }
    }
  }

  removeAlertRule(ruleId: string): void {
    this.alertRules = this.alertRules.filter((r) => r.id !== ruleId);
  }

  /** 通知 */
  markNotificationRead(notificationId: string): void {
    for (let i = 0; i < this.notifications.length; i++) {
      if (this.notifications[i].id === notificationId) {
        this.notifications[i].isRead = true;
        break;
      }
    }
  }

  markAllNotificationsRead(): void {
    for (let i = 0; i < this.notifications.length; i++) {
      this.notifications[i].isRead = true;
    }
  }

  clearNotifications(): void {
    this.notifications = [];
  }

  /** 切换数据源 */
  async switchDataSource(source: number): Promise<boolean> {
    this.dataSource = source;
    if (source === DataSourceType.COINGECKO) {
      const markets = await CoinGeckoApi.fetchTopMarkets(50);
      if (markets.length > 0) {
        this.coinMarkets = markets;
        // 用真实币价更新商品价格（稳定映射）
        this.applyCoinPrices();
        return true;
      }
      // 失败回退 Mock
      this.dataSource = DataSourceType.MOCK;
      return false;
    }
    // 切回 Mock：清空真实数据缓存，重建走势
    MockPriceRecords.clearCache();
    for (let i = 0; i < this.products.length; i++) {
      const p = this.products[i];
      this.priceRecords.set(p.id, MockPriceRecords.forProduct(p.id, p.currentPrice));
    }
    return true;
  }

  private applyCoinPrices(): void {
    const markets = this.coinMarkets;
    if (markets.length === 0) {
      return;
    }
    for (let i = 0; i < this.products.length; i++) {
      const p = this.products[i];
      // 用商品 id 的 hash 稳定选取一个币种
      const idx = this.hashId(p.id) % markets.length;
      const m = markets[idx];
      const newPrice = Math.round(m.current_price * 100) / 100;
      const rec = new PriceRecord();
      rec.id = `${p.id}_cg_${Date.now()}`;
      rec.productId = p.id;
      rec.price = newPrice;
      rec.timestamp = Date.now();
      rec.source = 'coingecko';
      const existing = this.priceRecords.get(p.id);
      const list = existing !== undefined ? existing : [];
      list.push(rec);
      this.priceRecords.set(p.id, list);
      p.currentPrice = newPrice;
      p.lastRefreshTime = Date.now();
      if (m.price_change_percentage_24h > 3) {
        p.status = MonitorStatus.WARN;
      } else {
        p.status = MonitorStatus.NORMAL;
      }
    }
  }

  private hashId(s: string): number {
    let h: number = 0;
    for (let i = 0; i < s.length; i++) {
      h = ((h << 5) - h + s.charCodeAt(i)) | 0;
    }
    return Math.abs(h);
  }
}

/** 便利函数：获取单例 */
export function getRepo(): DataRepository {
  return DataRepository.getInstance();
}
