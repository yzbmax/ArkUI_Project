import { router } from '@kit.ArkUI';
import { RoutePath } from '../constants/AppConstants';

interface ProductDetailParams {
  productId: string;
}

interface AlertSettingParams {
  productId: string;
  productName: string;
}

/** 空路由参数（避免无类型对象字面量） */
const EMPTY_PARAMS: Record<string, Object> = {};

/** 路由工具：统一跳转封装 */
export class RouterUtil {
  static push(route: string, params: Object = EMPTY_PARAMS): void {
    try {
      router.pushUrl({ url: route, params: params as Record<string, Object> });
    } catch (e) {
      console.error('RouterUtil.push error: ' + JSON.stringify(e));
    }
  }

  static replace(route: string, params: Object = EMPTY_PARAMS): void {
    try {
      router.replaceUrl({ url: route, params: params as Record<string, Object> });
    } catch (e) {
      console.error('RouterUtil.replace error: ' + JSON.stringify(e));
    }
  }

  static back(): void {
    try {
      router.back();
    } catch (e) {
      console.error('RouterUtil.back error: ' + JSON.stringify(e));
    }
  }

  /** 跳转商品详情 */
  static toProductDetail(productId: string): void {
    const p: ProductDetailParams = { productId: productId };
    RouterUtil.push(RoutePath.PRODUCT_DETAIL, p);
  }

  /** 跳转价格走势 */
  static toPriceChart(productId: string): void {
    const p: ProductDetailParams = { productId: productId };
    RouterUtil.push(RoutePath.PRICE_CHART, p);
  }

  /** 跳转比价 */
  static toCompare(productId: string): void {
    const p: ProductDetailParams = { productId: productId };
    RouterUtil.push(RoutePath.COMPARE, p);
  }

  /** 跳转提醒设置 */
  static toAlertSetting(productId: string, productName: string): void {
    const p: AlertSettingParams = { productId: productId, productName: productName };
    RouterUtil.push(RoutePath.ALERT_SETTING, p);
  }
}
