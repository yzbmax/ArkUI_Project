import { AlertRule, AlertType } from '../model/AlertRule';

/** 预制提醒规则 */
export class MockAlertRules {
  static list: Array<AlertRule> = [
    { id: 'r001', productId: 'p001', productName: 'Apple AirPods Pro 3 主动降噪无线耳机', type: AlertType.TARGET_PRICE, threshold: 1599, isActive: true, createdAt: Date.now() - 40 * 24 * 3600 * 1000 },
    { id: 'r002', productId: 'p003', productName: '戴森 V12 无绳吸尘器 轻量版', type: AlertType.DROP_PERCENT, threshold: 15, isActive: true, createdAt: Date.now() - 30 * 24 * 3600 * 1000 },
    { id: 'r003', productId: 'p008', productName: '极米 H6 4K 投影仪 高亮版', type: AlertType.BELOW_LOWEST, threshold: 0, isActive: false, createdAt: Date.now() - 12 * 24 * 3600 * 1000 },
    { id: 'r004', productId: 'p010', productName: '罗技 MX Master 3S 无线蓝牙鼠标', type: AlertType.TARGET_PRICE, threshold: 499, isActive: true, createdAt: Date.now() - 5 * 24 * 3600 * 1000 },
  ];
}
