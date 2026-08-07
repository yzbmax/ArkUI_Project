import { getRepo } from '../repository/DataRepository';
import { MonitorStatus } from '../model/Product';
import { PriceRecord } from '../model/PriceRecord';
import { DashboardStats, TopMoveItem } from '../model/DashboardStats';
import { PriceMonitorViewModel } from './PriceMonitorViewModel';

/**
 * DashboardViewModel.ets
 * 看板模块 ViewModel：统计计算 / Top 波动 / 问候语
 */

export class DashboardViewModel {
  /** 计算看板统计 */
  static computeStats(): DashboardStats {
    const stats = new DashboardStats();
    const repo = getRepo();
    stats.totalMonitored = repo.products.length;

    const now: number = Date.now();
    const todayStart: number = now - (now % (24 * 3600 * 1000));
    const dayMs: number = 24 * 3600 * 1000;

    for (let i = 0; i < repo.products.length; i++) {
      const p = repo.products[i];
      const records = repo.getRecords(p.id);
      // 今日变动：最后一条记录在今天
      let todayChange = false;
      if (records.length > 0) {
        const last = records[records.length - 1];
        if (last.timestamp >= todayStart) {
          todayChange = true;
        }
      }
      if (todayChange) {
        stats.todayChanges++;
      }
      // 已购商品计入节省
      if (p.isPurchased && p.purchasedPrice > 0 && p.originalPrice > p.purchasedPrice) {
        const saved: number = p.originalPrice - p.purchasedPrice;
        stats.totalSaved += saved;
        if (p.addTime >= todayStart - dayMs) {
          stats.todaySaved += saved;
        }
      }
    }
    stats.totalSaved = Math.round(stats.totalSaved);
    stats.todaySaved = Math.round(stats.todaySaved);
    return stats;
  }

  /** 近 7 日波动 Top N（按涨跌幅绝对值排序） */
  static topMoves(limit: number): Array<TopMoveItem> {
    const repo = getRepo();
    const items: Array<TopMoveItem> = [];
    for (let i = 0; i < repo.products.length; i++) {
      const p = repo.products[i];
      const item = new TopMoveItem();
      item.productId = p.id;
      item.productName = p.name;
      item.changePercent = PriceMonitorViewModel.changePercentOf(p.id, 7);
      item.sparkPoints = DashboardViewModel.sparkOf(p.id, 7);
      items.push(item);
    }
    items.sort((a: TopMoveItem, b: TopMoveItem) => {
      return Math.abs(b.changePercent) - Math.abs(a.changePercent);
    });
    return items.slice(0, Math.min(limit, items.length));
  }

  /** 生成某商品近 N 天走势点（供 Sparkline） */
  static sparkOf(productId: string, days: number): Array<number> {
    const records: Array<PriceRecord> = PriceMonitorViewModel.filterByDays(getRepo().getRecords(productId), days);
    const points: Array<number> = [];
    for (let i = 0; i < records.length; i++) {
      points.push(records[i].price);
    }
    return points;
  }

  /** 波动预警商品数 */
  static warnCount(): number {
    const repo = getRepo();
    let n = 0;
    for (let i = 0; i < repo.products.length; i++) {
      if (repo.products[i].status === MonitorStatus.WARN) {
        n++;
      }
    }
    return n;
  }

  /** 今日是否已刷新过（用于"已更新"提示） */
  static hasTodayRefresh(): boolean {
    const repo = getRepo();
    const todayStart: number = Date.now() - (Date.now() % (24 * 3600 * 1000));
    for (let i = 0; i < repo.products.length; i++) {
      if (repo.products[i].lastRefreshTime >= todayStart) {
        return true;
      }
    }
    return false;
  }

  /** 按当前时间返回问候语 */
  static greeting(): string {
    const h: number = new Date().getHours();
    if (h >= 5 && h < 12) {
      return '早上好';
    }
    if (h >= 12 && h < 18) {
      return '下午好';
    }
    if (h >= 18 && h < 23) {
      return '晚上好';
    }
    return '夜深了';
  }
}
