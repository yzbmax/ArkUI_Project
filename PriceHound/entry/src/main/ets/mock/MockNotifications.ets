import { AppNotification } from '../model/AppNotification';

const HOUR: number = 3600 * 1000;

/** 预制通知消息 */
export class MockNotifications {
  static list: Array<AppNotification> = [
    { id: 'n001', title: '降价提醒', content: 'Apple AirPods Pro 3 降价至 ¥1899，已低于目标价 ¥1999', time: Date.now() - 3 * HOUR, isRead: false, productId: 'p001' },
    { id: 'n002', title: '监控异常', content: '联想拯救者 Y7000P 价格获取失败，请检查商品链接', time: Date.now() - 26 * HOUR, isRead: false, productId: 'p005' },
    { id: 'n003', title: '波动预警', content: '戴森 V12 无绳吸尘器 24h 内波动超过 5%', time: Date.now() - 2 * 24 * HOUR, isRead: true, productId: 'p003' },
    { id: 'n004', title: '周报', content: '本周共监控 12 件商品，为你节省 ¥186', time: Date.now() - 3 * 24 * HOUR, isRead: true, productId: '' },
    { id: 'n005', title: '降价提醒', content: 'Bose QuietComfort 45 降价至 ¥1599，为近 30 天最低', time: Date.now() - 5 * 24 * HOUR, isRead: true, productId: 'p006' },
  ];
}
