import { getRepo } from '../repository/DataRepository';
import { AlertRule, AlertType } from '../model/AlertRule';
import { AppNotification } from '../model/AppNotification';
import { Product } from '../model/Product';
import { PriceRecord } from '../model/PriceRecord';

/**
 * AlertViewModel.ets
 * 提醒模块 ViewModel：规则增删改 / 触发判定 / 通知管理
 */

export class AlertViewModel {
  /** 新增提醒规则 */
  static addRule(productId: string, productName: string, type: number, threshold: number): AlertRule {
    const rule = new AlertRule();
    rule.id = `rule_${Date.now()}_${Math.floor(Math.random() * 10000)}`;
    rule.productId = productId;
    rule.productName = productName;
    rule.type = type;
    rule.threshold = threshold;
    rule.isActive = true;
    rule.createdAt = Date.now();
    getRepo().addAlertRule(rule);
    return rule;
  }

  /** 切换规则启停 */
  static toggleRule(ruleId: string): void {
    getRepo().toggleAlertRule(ruleId);
  }

  /** 删除规则 */
  static removeRule(ruleId: string): void {
    getRepo().removeAlertRule(ruleId);
  }

  /** 全部规则 */
  static allRules(): Array<AlertRule> {
    return getRepo().alertRules.slice();
  }

  /** 某商品规则 */
  static rulesOf(productId: string): Array<AlertRule> {
    const all = getRepo().alertRules;
    const out: Array<AlertRule> = [];
    for (let i = 0; i < all.length; i++) {
      if (all[i].productId === productId) {
        out.push(all[i]);
      }
    }
    return out;
  }

  /** 启用中的规则数 */
  static activeCount(): number {
    const all = getRepo().alertRules;
    let n = 0;
    for (let i = 0; i < all.length; i++) {
      if (all[i].isActive) {
        n++;
      }
    }
    return n;
  }

  /** 判断当前价格是否触发某规则 */
  static isTriggered(rule: AlertRule, currentPrice: number, records: Array<PriceRecord>): boolean {
    if (rule.type === AlertType.TARGET_PRICE) {
      return currentPrice <= rule.threshold;
    }
    if (rule.type === AlertType.DROP_PERCENT) {
      if (records.length < 2) {
        return false;
      }
      const base: number = records[0].price;
      if (base === 0) {
        return false;
      }
      const drop: number = ((base - currentPrice) / base) * 100;
      return drop >= rule.threshold;
    }
    if (rule.type === AlertType.BELOW_LOWEST) {
      // 历史最低价取该商品全部记录中的最小值
      const all = getRepo().getRecords(rule.productId);
      let lowest: number = -1;
      for (let i = 0; i < all.length; i++) {
        if (lowest < 0 || all[i].price < lowest) {
          lowest = all[i].price;
        }
      }
      return lowest > 0 && currentPrice < lowest;
    }
    return false;
  }

  /** 刷新后检查商品所有规则，触发则产生通知 */
  static checkAndNotify(p: Product): void {
    const rules = AlertViewModel.rulesOf(p.id);
    const records = getRepo().getRecords(p.id);
    for (let i = 0; i < rules.length; i++) {
      const rule = rules[i];
      if (!rule.isActive) {
        continue;
      }
      if (AlertViewModel.isTriggered(rule, p.currentPrice, records)) {
        AlertViewModel.notify(rule, p.currentPrice);
      }
    }
  }

  /** 生成一条通知（去重：同商品 5 分钟内不重复） */
  static notify(rule: AlertRule, price: number): void {
    const repo = getRepo();
    const recent = repo.notifications;
    const now: number = Date.now();
    for (let i = 0; i < recent.length; i++) {
      if (recent[i].productId === rule.productId && now - recent[i].time < 5 * 60 * 1000) {
        return; // 已有近期通知，跳过
      }
    }
    const n = new AppNotification();
    n.id = `noti_${now}_${Math.floor(Math.random() * 10000)}`;
    n.title = `「${rule.productName}」价格提醒`;
    n.content = AlertViewModel.triggerText(rule, price);
    n.time = now;
    n.isRead = false;
    n.productId = rule.productId;
    repo.notifications.unshift(n);
  }

  private static triggerText(rule: AlertRule, price: number): string {
    if (rule.type === AlertType.TARGET_PRICE) {
      return `当前价格 ¥${Math.round(price)} 已降至目标价 ¥${Math.round(rule.threshold)} 以下`;
    }
    if (rule.type === AlertType.DROP_PERCENT) {
      return `当前价格 ¥${Math.round(price)}，已较监测价下降超过 ${rule.threshold}%`;
    }
    return `当前价格 ¥${Math.round(price)} 已低于历史最低价，是入手好时机`;
  }

  /** 通知列表 */
  static notifications(): Array<AppNotification> {
    return getRepo().notifications.slice();
  }

  /** 未读数量 */
  static unreadCount(): number {
    const list = getRepo().notifications;
    let n = 0;
    for (let i = 0; i < list.length; i++) {
      if (!list[i].isRead) {
        n++;
      }
    }
    return n;
  }

  /** 单条已读 */
  static markRead(notificationId: string): void {
    getRepo().markNotificationRead(notificationId);
  }

  /** 全部已读 */
  static markAllRead(): void {
    getRepo().markAllNotificationsRead();
  }

  /** 清空通知 */
  static clearAll(): void {
    getRepo().clearNotifications();
  }
}
