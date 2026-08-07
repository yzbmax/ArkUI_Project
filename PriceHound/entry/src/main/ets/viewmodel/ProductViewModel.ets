import { getRepo } from '../repository/DataRepository';
import { Product, Platform, MonitorStatus } from '../model/Product';
import { AlertRule } from '../model/AlertRule';

/**
 * ProductViewModel.ets
 * 商品模块 ViewModel：查询 / 筛选 / 排序 / 增删 / 置顶 / 已购
 */

/** 商品排序方式 */
export enum ProductSortType {
  ADD_TIME = 0,     // 最新添加
  PRICE_ASC = 1,    // 价格升序
  PRICE_DESC = 2,   // 价格降序
  CHANGE_ASC = 3,   // 降幅最大优先
}

export class ProductViewModel {
  /** 搜索 + 分类筛选 */
  static filter(keyword: string, categoryId: string): Array<Product> {
    const kw = keyword.trim().toLowerCase();
    const list: Array<Product> = [];
    const all = getRepo().products;
    for (let i = 0; i < all.length; i++) {
      const p = all[i];
      if (categoryId !== 'all' && p.categoryId !== categoryId) {
        continue;
      }
      if (kw.length > 0 && p.name.toLowerCase().indexOf(kw) < 0) {
        continue;
      }
      list.push(p);
    }
    return list;
  }

  /** 排序：置顶始终在前 */
  static sort(products: Array<Product>, sortType: ProductSortType): Array<Product> {
    const list = products.slice();
    list.sort((a: Product, b: Product) => {
      if (a.isTop !== b.isTop) {
        return a.isTop ? -1 : 1;
      }
      if (sortType === ProductSortType.PRICE_ASC) {
        return a.currentPrice - b.currentPrice;
      }
      if (sortType === ProductSortType.PRICE_DESC) {
        return b.currentPrice - a.currentPrice;
      }
      if (sortType === ProductSortType.CHANGE_ASC) {
        return ProductViewModel.percentOf(a) - ProductViewModel.percentOf(b);
      }
      return b.addTime - a.addTime;
    });
    return list;
  }

  /** 近 7 日涨跌幅 % */
  static percentOf(p: Product): number {
    const recs = getRepo().getRecords(p.id);
    if (recs.length < 2) {
      return 0;
    }
    const first = recs[0].price;
    const last = recs[recs.length - 1].price;
    return first === 0 ? 0 : ((last - first) / first) * 100;
  }

  /** 新建商品并加入仓库 */
  static addProduct(name: string, platform: number, currentPrice: number,
    originalPrice: number, url: string, categoryId: string, tags: Array<string>): Product {
    const repo = getRepo();
    const p = new Product();
    p.id = `p_${Date.now()}_${Math.floor(Math.random() * 100000)}`;
    p.name = name;
    p.platform = platform;
    p.currentPrice = currentPrice;
    p.originalPrice = originalPrice > 0 ? originalPrice : currentPrice;
    p.lowestPrice = currentPrice;
    p.highestPrice = currentPrice;
    p.url = url;
    p.categoryId = categoryId;
    p.tags = tags;
    p.status = MonitorStatus.NORMAL;
    repo.addProduct(p);
    return p;
  }

  /** 删除商品（连同价格记录与提醒规则） */
  static remove(productId: string): void {
    getRepo().removeProduct(productId);
  }

  /** 切换置顶 */
  static toggleTop(productId: string): void {
    getRepo().toggleTop(productId);
  }

  /** 标记已购 */
  static markPurchased(productId: string, price: number): void {
    getRepo().markPurchased(productId, price);
  }

  /** 取消已购 */
  static unmarkPurchased(productId: string): void {
    const p = getRepo().getProduct(productId);
    if (p !== undefined) {
      p.isPurchased = false;
      p.purchasedPrice = 0;
    }
  }

  /** 查询单个商品 */
  static getProduct(productId: string): Product | undefined {
    return getRepo().getProduct(productId);
  }

  /** 该商品当前有效提醒规则 */
  static activeRulesOf(productId: string): Array<AlertRule> {
    const rules = getRepo().alertRules;
    const list: Array<AlertRule> = [];
    for (let i = 0; i < rules.length; i++) {
      if (rules[i].productId === productId && rules[i].isActive) {
        list.push(rules[i]);
      }
    }
    return list;
  }

  /** 商品总数（供角标） */
  static totalCount(): number {
    return getRepo().products.length;
  }

  /** 平台名 */
  static platformName(platform: number): string {
    const names: Map<number, string> = new Map([
      [Platform.TAOBAO, '淘宝'],
      [Platform.JD, '京东'],
      [Platform.PINDUODUO, '拼多多'],
      [Platform.SUNING, '苏宁'],
      [Platform.OFFICIAL, '官方商城'],
      [Platform.OTHER, '其他'],
    ]);
    return names.has(platform) ? (names.get(platform) as string) : '其他';
  }
}

/** 供页面排序使用的别名导出（保持调用语义清晰） */
export function sortProducts(products: Array<Product>, sortType: ProductSortType): Array<Product> {
  return ProductViewModel.sort(products, sortType);
}
