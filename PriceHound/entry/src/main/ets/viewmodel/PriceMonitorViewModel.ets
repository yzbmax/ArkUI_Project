import { getRepo } from '../repository/DataRepository';
import { PriceRecord } from '../model/PriceRecord';
import { Product, MonitorStatus } from '../model/Product';

/**
 * PriceMonitorViewModel.ets
 * 价格监控模块 ViewModel：手动刷新 / 记录查询 / 区间统计 / 涨跌幅
 */

export class PriceMonitorViewModel {
  /** 手动刷新单个商品：追加一条新价格记录并返回新价格；失败返回 -1 */
  static manualRefresh(productId: string): number {
    const repo = getRepo();
    const p = repo.getProduct(productId);
    if (p === undefined) {
      return -1;
    }
    const oldPrice: number = p.currentPrice;
    // 模拟一次小幅波动（-2% ~ +3%）
    const delta: number = oldPrice * (0.98 + Math.random() * 0.05);
    const newPrice: number = Math.max(1, Math.round(delta));
    const rec = new PriceRecord();
    rec.id = `${productId}_manual_${Date.now()}`;
    rec.productId = productId;
    rec.price = newPrice;
    rec.timestamp = Date.now();
    rec.source = 'manual';
    const existing = repo.getRecords(productId);
    const list: Array<PriceRecord> = existing.slice();
    list.push(rec);
    repo.priceRecords.set(productId, list);

    p.currentPrice = newPrice;
    p.lastRefreshTime = Date.now();
    if (newPrice < p.lowestPrice) {
      p.lowestPrice = newPrice;
    }
    if (newPrice > p.highestPrice) {
      p.highestPrice = newPrice;
    }
    // 波动大于 3% 触发预警状态
    const changePct: number = ((newPrice - oldPrice) / oldPrice) * 100;
    if (Math.abs(changePct) > 3) {
      p.status = MonitorStatus.WARN;
    } else {
      p.status = MonitorStatus.NORMAL;
    }
    return newPrice;
  }

  /** 查询商品价格记录（默认全部） */
  static recordsOf(productId: string): Array<PriceRecord> {
    return getRepo().getRecords(productId);
  }

  /** 按天数范围筛选记录 */
  static filterByDays(records: Array<PriceRecord>, days: number): Array<PriceRecord> {
    if (days <= 0) {
      return records.slice();
    }
    const start: number = Date.now() - days * 24 * 3600 * 1000;
    const out: Array<PriceRecord> = [];
    for (let i = 0; i < records.length; i++) {
      if (records[i].timestamp >= start) {
        out.push(records[i]);
      }
    }
    return out;
  }

  /** 区间涨跌幅 %（相对区间首条） */
  static changePercentOf(productId: string, days: number): number {
    const filtered = PriceMonitorViewModel.filterByDays(getRepo().getRecords(productId), days);
    if (filtered.length < 2) {
      return 0;
    }
    const first = filtered[0].price;
    const last = filtered[filtered.length - 1].price;
    return first === 0 ? 0 : ((last - first) / first) * 100;
  }

  /** 区间最低价 */
  static lowestIn(records: Array<PriceRecord>): number {
    let min: number = -1;
    for (let i = 0; i < records.length; i++) {
      if (min < 0 || records[i].price < min) {
        min = records[i].price;
      }
    }
    return min < 0 ? 0 : min;
  }

  /** 区间最高价 */
  static highestIn(records: Array<PriceRecord>): number {
    let max: number = 0;
    for (let i = 0; i < records.length; i++) {
      if (records[i].price > max) {
        max = records[i].price;
      }
    }
    return max;
  }

  /** 区间均价 */
  static averageIn(records: Array<PriceRecord>): number {
    if (records.length === 0) {
      return 0;
    }
    let sum: number = 0;
    for (let i = 0; i < records.length; i++) {
      sum += records[i].price;
    }
    return Math.round(sum / records.length);
  }

  /** 距历史最低的百分比（0 表示已是最低） */
  static aboveLowestPct(productId: string): number {
    const p = getRepo().getProduct(productId);
    if (p === undefined || p.lowestPrice === 0) {
      return 0;
    }
    return ((p.currentPrice - p.lowestPrice) / p.lowestPrice) * 100;
  }

  /** 相比原价的折扣百分比 */
  static discountPct(p: Product): number {
    if (p.originalPrice <= 0) {
      return 0;
    }
    return Math.round((1 - p.currentPrice / p.originalPrice) * 100);
  }
}
