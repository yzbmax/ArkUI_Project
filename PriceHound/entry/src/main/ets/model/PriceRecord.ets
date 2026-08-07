/** 价格记录模型 */
export class PriceRecord {
  id: string;
  productId: string;
  price: number;
  timestamp: number;   // 时间戳 ms
  source: string;      // 数据来源：mock / coingecko / manual

  constructor() {
    this.id = '';
    this.productId = '';
    this.price = 0;
    this.timestamp = Date.now();
    this.source = 'mock';
  }
}

/** 迷你走势点（用于 Sparkline） */
export class SparkPoint {
  timestamp: number;
  price: number;

  constructor(timestamp: number, price: number) {
    this.timestamp = timestamp;
    this.price = price;
  }
}
