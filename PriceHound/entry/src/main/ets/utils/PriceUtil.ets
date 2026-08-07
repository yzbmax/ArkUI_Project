/** 价格格式化工具 */
export class PriceUtil {
  /** 分单位价格（整数）格式化为 ¥1,234 */
  static format(price: number): string {
    const rounded = Math.round(price);
    const s = `${rounded}`;
    let result = '';
    let count = 0;
    for (let i = s.length - 1; i >= 0; i--) {
      result = s.charAt(i) + result;
      count++;
      if (count % 3 === 0 && i > 0) {
        result = ',' + result;
      }
    }
    return `¥${result}`;
  }

  /** 分单位价格格式化为小数显示 ¥1,234.00 */
  static formatPrecise(price: number): string {
    const v = price.toFixed(2);
    const parts = v.split('.');
    const intPart = parts[0];
    const decPart = parts[1];
    let result = '';
    let count = 0;
    for (let i = intPart.length - 1; i >= 0; i--) {
      result = intPart.charAt(i) + result;
      count++;
      if (count % 3 === 0 && i > 0) {
        result = ',' + result;
      }
    }
    return `¥${result}.${decPart}`;
  }

  /** 变化百分比：-12.5% / +3.2% */
  static percent(change: number): string {
    if (change >= 0) {
      return `+${change.toFixed(1)}%`;
    }
    return `${change.toFixed(1)}%`;
  }
}
