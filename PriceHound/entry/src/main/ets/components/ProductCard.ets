import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { Product, platformName } from '../model/Product';
import { PriceTag } from './PriceTag';
import { PriceSparkline } from './PriceSparkline';
import { MonitorStatusDot } from './MonitorStatusDot';
import { TagBadge } from './TagBadge';
import { getRepo } from '../repository/DataRepository';
import { RouterUtil } from '../utils/RouterUtil';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * ProductCard.ets
 * 商品卡片（列表模式）：缩略图 + 名称 + 平台 + 标签 + 价格 + 迷你走势 + 状态
 * 支持 列表/宫格 两种模式切换
 */
@Component
export struct ProductCard {
  @Prop productId: string = '';
  @Prop gridMode: boolean = false;

  private getProduct(): Product {
    const p = getRepo().getProduct(this.productId);
    if (p !== undefined) {
      return p;
    }
    return new Product();
  }

  private sparkData(): Array<number> {
    const records = getRepo().getRecords(this.productId);
    const nums: Array<number> = [];
    // 取最近 15 条
    const start = Math.max(0, records.length - 15);
    for (let i = start; i < records.length; i++) {
      nums.push(records[i].price);
    }
    return nums;
  }

  build() {
    if (this.gridMode) {
      // ===== 宫格模式 =====
      Column({ space: DesignSpacing.SM }) {
        Stack({ alignContent: Alignment.TopEnd }) {
          Text(this.getProduct().imageUrl)
            .fontSize(44)
            .width(64)
            .height(64)
            .textAlign(TextAlign.Center)
            .backgroundColor(ThemeManager.surface())
            .borderRadius(DesignRadius.MD)
          if (this.getProduct().isTop) {
            Text('★')
              .fontSize(DesignTypography.SIZE_CAPTION)
              .fontColor(ThemeManager.warn())
              .margin(4)
          }
        }
        .width('100%')
        .height(80)

        Text(this.getProduct().name)
          .fontSize(DesignTypography.SIZE_CAPTION)
          .fontColor(ThemeManager.textPrimary())
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')

        Row() {
          PriceTag({ price: this.getProduct().currentPrice, fontSize: 18 })
          Blank()
        }
        .width('100%')
      }
      .padding(DesignSpacing.MD)
      .backgroundColor(ThemeManager.card())
      .borderRadius(DesignRadius.LG)
      .onClick(() => RouterUtil.toProductDetail(this.productId))
    } else {
      // ===== 列表模式 =====
      Row({ space: DesignSpacing.MD }) {
        // 缩略图
        Stack({ alignContent: Alignment.TopEnd }) {
          Text(this.getProduct().imageUrl)
            .fontSize(40)
            .width(64)
            .height(64)
            .textAlign(TextAlign.Center)
            .backgroundColor(ThemeManager.surface())
            .borderRadius(DesignRadius.MD)
          if (this.getProduct().isTop) {
            Text('★')
              .fontSize(DesignTypography.SIZE_LABEL)
              .fontColor(ThemeManager.warn())
              .margin(4)
          }
        }

        Column({ space: 6 }) {
          Text(this.getProduct().name)
            .fontSize(DesignTypography.SIZE_BODY_SM)
            .fontColor(ThemeManager.textPrimary())
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')

          Row({ space: DesignSpacing.SM }) {
            Text(platformName.get(this.getProduct().platform) ?? '')
              .fontSize(DesignTypography.SIZE_LABEL)
              .fontColor(ThemeManager.textTertiary())
            if (this.getProduct().tags.length > 0) {
              TagBadge({ text: this.getProduct().tags[0], small: true })
            }
            Blank()
          }
          .width('100%')

          Row() {
            PriceTag({ price: this.getProduct().currentPrice, fontSize: 20 })
            Blank()
            MonitorStatusDot({ status: this.getProduct().status })
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        // 迷你走势
        PriceSparkline({
          points: this.sparkData(),
          chartWidth: 90,
          chartHeight: 34,
        })
      }
      .padding(DesignSpacing.LG)
      .backgroundColor(ThemeManager.card())
      .borderRadius(DesignRadius.LG)
      .width('100%')
      .onClick(() => RouterUtil.toProductDetail(this.productId))
    }
  }
}
