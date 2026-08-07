/** 提醒类型枚举 */
export enum AlertType {
  TARGET_PRICE = 0,   // 目标价格
  DROP_PERCENT = 1,   // 降幅百分比
  BELOW_LOWEST = 2,   // 低于历史最低
}

export const alertTypeName: Map<number, string> = new Map([
  [AlertType.TARGET_PRICE, '目标价格'],
  [AlertType.DROP_PERCENT, '降幅百分比'],
  [AlertType.BELOW_LOWEST, '低于历史最低'],
]);

/** 提醒规则模型 */
export class AlertRule {
  id: string;
  productId: string;
  productName: string;
  type: number;
  threshold: number;       // 目标价格 / 百分比
  isActive: boolean;
  createdAt: number;

  constructor() {
    this.id = '';
    this.productId = '';
    this.productName = '';
    this.type = AlertType.TARGET_PRICE;
    this.threshold = 0;
    this.isActive = true;
    this.createdAt = Date.now();
  }
}
