import { router } from '@kit.ArkUI';
import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { getRepo } from '../repository/DataRepository';
import { Product, Platform, platformName } from '../model/Product';
import { PriceUtil } from '../utils/PriceUtil';
import { PriceTag } from '../components/PriceTag';
import { TagBadge } from '../components/TagBadge';
import { ToastUtil } from '../components/Toast';
import { RouterUtil } from '../utils/RouterUtil';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * ComparePage.ets
 * 比价页：跨平台比价 + 同类目推荐对比 + 去平台购买
 */
@Entry
@Component
export struct ComparePage {
  @StorageProp('theme.isDark') isDark: boolean = false;
  @State productId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params !== undefined && params['productId'] !== undefined) {
      this.productId = params['productId'] as string;
    }
  }

  private product(): Product {
    const p = getRepo().getProduct(this.productId);
    return p !== undefined ? p : new Product();
  }

  /** 跨平台报价（模拟：基于当前价浮动） */
  private offers(): Array<Offer> {
    const p = this.product();
    const base = p.currentPrice;
    const list: Array<Offer> = [];
    list.push({ platform: Platform.JD, name: '京东自营', price: base, shipping: '免运费', delivery: '次日达', isBest: true });
    list.push({ platform: Platform.TAOBAO, name: '天猫旗舰店', price: Math.round(base * 1.03), shipping: '免运费', delivery: '3-5天', isBest: false });
    list.push({ platform: Platform.PINDUODUO, name: '拼多多百亿补贴', price: Math.round(base * 0.93), shipping: '免运费', delivery: '5-7天', isBest: false });
    list.push({ platform: Platform.SUNING, name: '苏宁易购', price: Math.round(base * 1.01), shipping: '运费¥10', delivery: '次日达', isBest: false });
    return list;
  }

  /** 同类目商品（模拟推荐） */
  private related(): Array<Product> {
    const p = this.product();
    const result: Array<Product> = [];
    for (let i = 0; i < getRepo().products.length; i++) {
      const item = getRepo().products[i];
      if (item.id !== p.id && item.categoryId === p.categoryId) {
        result.push(item);
      }
    }
    // 不足补其他商品
    for (let i = 0; i < getRepo().products.length && result.length < 3; i++) {
      const item = getRepo().products[i];
      if (item.id !== p.id && result.indexOf(item) < 0) {
        result.push(item);
      }
    }
    return result.slice(0, 3);
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor(ThemeManager.textPrimary())
          .width(36)
          .onClick(() => RouterUtil.back())
        Text('比价')
          .fontFamily(DesignTypography.FONT_SERIF)
          .fontSize(DesignTypography.SIZE_TITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeManager.textPrimary())
        Blank()
        Blank().width(36)
      }
      .width('100%')
      .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.MD, bottom: DesignSpacing.MD })

      Scroll() {
        Column({ space: DesignSpacing.XL }) {
          // ===== 商品标题 =====
          Row({ space: DesignSpacing.MD }) {
            Text(this.product().imageUrl)
              .fontSize(44)
              .width(64)
              .height(64)
              .textAlign(TextAlign.Center)
              .backgroundColor(ThemeManager.surface())
              .borderRadius(DesignRadius.MD)
            Column({ space: 4 }) {
              Text(this.product().name)
                .fontFamily(DesignTypography.FONT_SERIF)
                .fontSize(DesignTypography.SIZE_TITLE)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeManager.textPrimary())
                .maxLines(2)
                .lineHeight(25)
              Text(`当前价 ${PriceUtil.format(this.product().currentPrice)}`)
                .fontSize(DesignTypography.SIZE_CAPTION)
                .fontColor(ThemeManager.textTertiary())
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 跨平台报价 =====
          Row() {
            Text('全网比价')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H3)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
            Blank()
            Text('数据更新于 5 分钟前')
              .fontSize(DesignTypography.SIZE_LABEL)
              .fontColor(ThemeManager.textTertiary())
          }
          .width('100%')
          .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })

          Column({ space: DesignSpacing.MD }) {
            ForEach(this.offers(), (o: Offer) => {
              Row({ space: DesignSpacing.MD }) {
                Column({ space: 4 }) {
                  Row({ space: DesignSpacing.XS }) {
                    Text(platformName.get(o.platform) ?? '')
                      .fontSize(DesignTypography.SIZE_BODY_SM)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(ThemeManager.textPrimary())
                    if (o.isBest) {
                      TagBadge({ text: '最划算', small: true })
                    }
                  }
                  Text(`${o.name} · ${o.delivery} · ${o.shipping}`)
                    .fontSize(DesignTypography.SIZE_LABEL)
                    .fontColor(ThemeManager.textTertiary())
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Column({ space: 2 }) {
                  PriceTag({
                    price: o.price,
                    fontSize: 18,
                    color: o.isBest ? ThemeManager.accent() : ThemeManager.textPrimary(),
                  })
                  Text(o.isBest ? '全网最低' : '')
                    .fontSize(DesignTypography.SIZE_LABEL)
                    .fontColor(ThemeManager.accent())
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .padding(DesignSpacing.MD)
              .backgroundColor(o.isBest ? ThemeManager.color('#fdf0e9', '#3a2b22') : ThemeManager.card())
              .borderRadius(DesignRadius.MD)
              .border({ width: o.isBest ? 1 : 0, color: ThemeManager.accent() })
              .onClick(() => {
                ToastUtil.show(`正在前往${platformName.get(o.platform) ?? ''}查看`);
              })
            }, (o: Offer) => `${o.platform}`)
          }
          .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })

          // ===== 同类推荐 =====
          Row() {
            Text('同类商品对比')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H3)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
            Blank()
          }
          .width('100%')
          .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })

          Column({ space: DesignSpacing.MD }) {
            ForEach(this.related(), (p: Product) => {
              Row({ space: DesignSpacing.MD }) {
                Text(p.imageUrl)
                  .fontSize(36)
                  .width(52)
                  .height(52)
                  .textAlign(TextAlign.Center)
                  .backgroundColor(ThemeManager.surface())
                  .borderRadius(DesignRadius.MD)
                Column({ space: 4 }) {
                  Text(p.name)
                    .fontSize(DesignTypography.SIZE_BODY_SM)
                    .fontColor(ThemeManager.textPrimary())
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(platformName.get(p.platform) ?? '')
                    .fontSize(DesignTypography.SIZE_LABEL)
                    .fontColor(ThemeManager.textTertiary())
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                Column({ space: 2 }) {
                  PriceTag({ price: p.currentPrice, fontSize: 18 })
                  Text(p.currentPrice < this.product().currentPrice ? '更便宜' : '')
                    .fontSize(DesignTypography.SIZE_LABEL)
                    .fontColor(ThemeManager.drop())
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .padding(DesignSpacing.MD)
              .backgroundColor(ThemeManager.card())
              .borderRadius(DesignRadius.MD)
              .onClick(() => RouterUtil.toProductDetail(p.id))
            }, (p: Product) => p.id)
          }
          .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })

          Blank().height(40)
        }
        .width('100%')
        .padding({ top: DesignSpacing.MD })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.bg())
  }
}

interface Offer {
  platform: number;
  name: string;
  price: number;
  shipping: string;
  delivery: string;
  isBest: boolean;
}
