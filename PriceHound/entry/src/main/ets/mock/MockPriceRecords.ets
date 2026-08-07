import { PriceRecord } from '../model/PriceRecord';

/**
 * MockPriceRecords.ets
 * 生成 30 天价格走势（每天 2 条记录，带随机波动）
 * 采用确定性伪随机（基于 productId 的 hash 种子），保证每次加载走势一致
 */

const DAY: number = 24 * 3600 * 1000;
const cache: Map<string, Array<PriceRecord>> = new Map();

/** 简单字符串 hash 作为随机种子 */
function hashSeed(s: string): number {
  let h: number = 0;
  for (let i = 0; i < s.length; i++) {
    h = ((h << 5) - h + s.charCodeAt(i)) | 0;
  }
  return Math.abs(h);
}

function seededRandom(seed: number): () => number {
  let state: number = seed % 2147483647;
  if (state <= 0) {
    state += 2147483646;
  }
  return () => {
    state = (state * 16807) % 2147483647;
    return (state - 1) / 2147483646;
  };
}

export class MockPriceRecords {
  /** 生成某商品 30 天价格记录 */
  static forProduct(productId: string, currentPrice: number): Array<PriceRecord> {
    if (cache.has(productId)) {
      return cache.get(productId) as Array<PriceRecord>;
    }
    const rand: () => number = seededRandom(hashSeed(productId));
    const records: Array<PriceRecord> = [];
    const now: number = Date.now();
    let price: number = currentPrice * (0.92 + rand() * 0.14);

    // 30 天，每天 2 条记录
    for (let d = 29; d >= 0; d--) {
      for (let tick = 0; tick < 2; tick++) {
        const rec = new PriceRecord();
        rec.id = `${productId}_${d}_${tick}`;
        rec.productId = productId;
        rec.timestamp = now - d * DAY - tick * (DAY / 2);
        price = price * (0.97 + rand() * 0.06);
        rec.price = Math.round(price);
        rec.source = 'mock';
        records.push(rec);
      }
    }
    // 最后一条为当前真实价格
    const last = new PriceRecord();
    last.id = `${productId}_last`;
    last.productId = productId;
    last.timestamp = now;
    last.price = currentPrice;
    last.source = 'mock';
    records.push(last);

    cache.set(productId, records);
    return records;
  }

  /** 一次性清空缓存（用于切换数据源后重建） */
  static clearCache(): void {
    cache.clear();
  }
}
