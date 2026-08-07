import { DesignTypography } from '../constants/DesignTokens';
import { PriceUtil } from '../utils/PriceUtil';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * PriceTag.ets
 * 等宽字体价格标签（降价=品牌色 / 普通=深色 / 涨价=红色）
 */
@Component
export struct PriceTag {
  @Prop price: number = 0;
  @Prop fontSize: number = DesignTypography.SIZE_PRICE;
  @Prop color: string = '';
  @Prop bold: boolean = true;

  build() {
    Text(PriceUtil.format(this.price))
      .fontFamily(DesignTypography.FONT_MONO)
      .fontSize(this.fontSize)
      .fontWeight(this.bold ? FontWeight.Medium : FontWeight.Normal)
      .fontColor(this.color.length > 0 ? this.color : ThemeManager.textPrimary())
  }
}
