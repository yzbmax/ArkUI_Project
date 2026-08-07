import { Product, MonitorStatus, Platform } from '../model/Product';
import { MockPriceRecords } from './MockPriceRecords';

/**
 * MockProducts.ets
 * 预制 12 条商品数据（各平台、各价格段、不同分类）
 */

const now: number = Date.now();
const HOUR: number = 3600 * 1000;

function buildProduct(id: string, name: string, platform: number, categoryId: string,
  currentPrice: number, originalPrice: number, status: number, isTop: boolean,
  addHoursAgo: number, refreshMinutesAgo: number, imageUrl: string): Product {
  let p = new Product();
  p.id = id;
  p.name = name;
  p.platform = platform;
  p.categoryId = categoryId;
  p.currentPrice = currentPrice;
  p.originalPrice = originalPrice;
  p.lowestPrice = Math.round(currentPrice * (0.72 + (Math.random() * 0.12)));
  p.highestPrice = Math.round(originalPrice * 1.05);
  p.status = status;
  p.isTop = isTop;
  p.addTime = now - addHoursAgo * HOUR;
  p.lastRefreshTime = now - refreshMinutesAgo * 60 * 1000;
  p.url = `https://example.com/${id}`;
  p.imageUrl = imageUrl;
  p.tags = [];
  return p;
}

export class MockProducts {
  static products: Array<Product> = [];

  static load(): Array<Product> {
    if (MockProducts.products.length > 0) {
      return MockProducts.products;
    }
    let list: Array<Product> = [];
    list.push(buildProduct('p001', 'Apple AirPods Pro 3 主动降噪无线耳机', Platform.JD, 'c_audio',
      1899, 2199, MonitorStatus.NORMAL, true, 240, 5, '🎧'));
    list.push(buildProduct('p002', '小米电视 S Pro 75 英寸 Mini LED 4K', Platform.JD, 'c_tv',
      4599, 5999, MonitorStatus.NORMAL, false, 200, 18, '📺'));
    list.push(buildProduct('p003', '戴森 V12 无绳吸尘器 轻量版', Platform.TAOBAO, 'c_home',
      3299, 3990, MonitorStatus.WARN, true, 180, 45, '🧹'));
    list.push(buildProduct('p004', '索尼 WH-1000XM5 头戴式降噪耳机', Platform.TAOBAO, 'c_audio',
      2299, 2899, MonitorStatus.NORMAL, false, 160, 90, '🎧'));
    list.push(buildProduct('p005', '联想拯救者 Y7000P 游戏本 i7/RTX4060', Platform.JD, 'c_computer',
      7299, 8499, MonitorStatus.ERROR, false, 140, 220, '💻'));
    list.push(buildProduct('p006', 'Bose QuietComfort 45 无线消噪耳机', Platform.SUNING, 'c_audio',
      1599, 2299, MonitorStatus.NORMAL, false, 120, 12, '🎧'));
    list.push(buildProduct('p007', '大疆 DJI Mini 4 Pro 航拍无人机', Platform.OFFICIAL, 'c_camera',
      4788, 5388, MonitorStatus.PAUSED, false, 100, 300, '🚁'));
    list.push(buildProduct('p008', '极米 H6 4K 投影仪 高亮版', Platform.PINDUODUO, 'c_tv',
      3999, 4999, MonitorStatus.NORMAL, false, 90, 8, '📽️'));
    list.push(buildProduct('p009', '华为 MatePad Pro 13.2 平板电脑', Platform.JD, 'c_tablet',
      5199, 5699, MonitorStatus.WARN, false, 70, 30, '📱'));
    list.push(buildProduct('p010', '罗技 MX Master 3S 无线蓝牙鼠标', Platform.TAOBAO, 'c_computer',
      549, 699, MonitorStatus.NORMAL, false, 60, 15, '🖱️'));
    list.push(buildProduct('p011', '西门子 变频滚筒洗衣机 10kg', Platform.SUNING, 'c_home',
      3299, 4299, MonitorStatus.NORMAL, false, 40, 25, '🧺'));
    list.push(buildProduct('p012', 'Kindle Scribe 10.2 英寸电子书阅读器', Platform.OFFICIAL, 'c_ebook',
      1999, 2499, MonitorStatus.NORMAL, true, 20, 3, '📖'));

    // 附加价格历史，确保每个商品有走势数据
    for (let i = 0; i < list.length; i++) {
      MockPriceRecords.forProduct(list[i].id, list[i].currentPrice);
    }
    MockProducts.products = list;
    return list;
  }
}
