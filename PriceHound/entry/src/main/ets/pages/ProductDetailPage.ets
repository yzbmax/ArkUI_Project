import { router } from '@kit.ArkUI';
import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { getRepo } from '../repository/DataRepository';
import { Product, platformName } from '../model/Product';
import { PriceUtil } from '../utils/PriceUtil';
import { DateUtil } from '../utils/DateUtil';
import { PriceSparkline } from '../components/PriceSparkline';
import { TagBadge } from '../components/TagBadge';
import { MonitorStatusDot } from '../components/MonitorStatusDot';
import { ToastUtil } from '../components/Toast';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { RouterUtil } from '../utils/RouterUtil';
import { AlertRule, AlertType } from '../model/AlertRule';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * ProductDetailPage.ets
 * 商品详情页：商品信息 + 价格区间 + 走势 + 相关操作（提醒/分享/购买/删除）
 */
@Entry
@Component
export struct ProductDetailPage {
  @StorageProp('theme.isDark') isDark: boolean = false;
  @State productId: string = '';
  @State refreshKey: number = 0;
  @State showRemoveDialog: boolean = false;
  @State showPurchaseDialog: boolean = false;
  @State purchasePrice: string = '';
  dialogController: CustomDialogController | null = null;
  purchaseDialogController: CustomDialogController | null = null;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params !== undefined && params['productId'] !== undefined) {
      this.productId = params['productId'] as string;
    }
    this.dialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: '移除商品',
        content: '确定将该商品从监控列表中移除吗？相关价格记录也会删除。',
        confirmText: '移除',
        danger: true,
        onConfirm: () => {
          getRepo().removeProduct(this.productId);
          ToastUtil.show('已移除');
          RouterUtil.back();
        },
      }),
      alignment: DialogAlignment.Center,
      customStyle: true,
    });
    this.purchaseDialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: '标记已购买',
        content: '记录你的实际购买价格，将停止对该商品的降价监控。',
        confirmText: '确认购买',
        onConfirm: () => {
          const price = parseFloat(this.purchasePrice);
          if (!isNaN(price) && price > 0) {
            getRepo().markPurchased(this.productId, price);
            ToastUtil.show('已标记购买');
          }
          this.refreshKey++;
        },
      }),
      alignment: DialogAlignment.Center,
      customStyle: true,
    });
  }

  private product(): Product {
    const p = getRepo().getProduct(this.productId);
    if (p !== undefined) {
      return p;
    }
    return new Product();
  }

  private sparkData(): Array<number> {
    const recs = getRepo().getRecords(this.productId);
    const nums: Array<number> = [];
    const start = Math.max(0, recs.length - 20);
    for (let i = start; i < recs.length; i++) {
      nums.push(recs[i].price);
    }
    return nums;
  }

  private addQuickAlert(): void {
    const p = this.product();
    const rule = new AlertRule();
    rule.id = `r_${Date.now()}`;
    rule.productId = p.id;
    rule.productName = p.name;
    rule.type = AlertType.TARGET_PRICE;
    rule.threshold = Math.round(p.currentPrice * 0.9);
    rule.isActive = true;
    getRepo().addAlertRule(rule);
    ToastUtil.show('已创建降价 10% 提醒');
    this.refreshKey++;
  }

  private openLink(): void {
    const p = this.product();
    if (p.url.length > 0) {
      ToastUtil.show(`正在打开商品链接…\n${p.url}`);
    }
  }

  build() {
    Column() {
      // ===== 顶部导航 =====
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor(ThemeManager.textPrimary())
          .width(36)
          .onClick(() => RouterUtil.back())
        Blank()
        Text('详情')
          .fontFamily(DesignTypography.FONT_SERIF)
          .fontSize(DesignTypography.SIZE_TITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeManager.textPrimary())
        Blank()
        Text('⋯')
          .fontSize(24)
          .fontColor(ThemeManager.textTertiary())
          .width(36)
      }
      .width('100%')
      .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.MD, bottom: DesignSpacing.MD })

      Scroll() {
        Column({ space: DesignSpacing.XL }) {
          // ===== 商品信息卡 =====
          Column({ space: DesignSpacing.LG }) {
            Row({ space: DesignSpacing.LG }) {
              Text(this.product().imageUrl)
                .fontSize(56)
                .width(88)
                .height(88)
                .textAlign(TextAlign.Center)
                .backgroundColor(ThemeManager.surface())
                .borderRadius(DesignRadius.MD)
              Column({ space: DesignSpacing.SM }) {
                Text(this.product().name)
                  .fontFamily(DesignTypography.FONT_SERIF)
                  .fontSize(DesignTypography.SIZE_TITLE)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeManager.textPrimary())
                  .maxLines(2)
                  .lineHeight(26)
                Row({ space: DesignSpacing.SM }) {
                  TagBadge({ text: platformName.get(this.product().platform) ?? '', small: true })
                  MonitorStatusDot({ status: this.product().status })
                }
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')

            Divider().color(ThemeManager.border())

            // ===== 价格区 =====
            Row() {
              Column({ space: 4 }) {
                Text('当前价格')
                  .fontSize(DesignTypography.SIZE_LABEL)
                  .fontColor(ThemeManager.textTertiary())
                Text(PriceUtil.format(this.product().currentPrice))
                  .fontFamily(DesignTypography.FONT_MONO)
                  .fontSize(DesignTypography.SIZE_H1)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeManager.accent())
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Column({ space: 4 }) {
                Text('划线价')
                  .fontSize(DesignTypography.SIZE_LABEL)
                  .fontColor(ThemeManager.textTertiary())
                Text(PriceUtil.format(this.product().originalPrice))
                  .fontFamily(DesignTypography.FONT_MONO)
                  .fontSize(DesignTypography.SIZE_PRICE_SM)
                  .fontColor(ThemeManager.textTertiary())
                  .decoration({ type: TextDecorationType.LineThrough })
              }
              .alignItems(HorizontalAlign.End)
            }
            .width('100%')

            // ===== 价格区间 =====
            Row({ space: DesignSpacing.MD }) {
              this.priceCell('历史最低', PriceUtil.format(this.product().lowestPrice), ThemeManager.drop())
              this.priceCell('历史最高', PriceUtil.format(this.product().highestPrice), ThemeManager.rise())
              this.priceCell('累计节省', PriceUtil.format(this.product().originalPrice - this.product().currentPrice), ThemeManager.accent())
            }
            .width('100%')

            // ===== 操作按钮 =====
            Row({ space: DesignSpacing.MD }) {
              Button('提醒设置')
                .layoutWeight(1)
                .height(44)
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textPrimary())
                .backgroundColor(ThemeManager.surface())
                .borderRadius(DesignRadius.MD)
                .onClick(() => RouterUtil.toAlertSetting(this.productId, this.product().name))
              Button('比价')
                .layoutWeight(1)
                .height(44)
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textPrimary())
                .backgroundColor(ThemeManager.surface())
                .borderRadius(DesignRadius.MD)
                .onClick(() => RouterUtil.toCompare(this.productId))
            }
            .width('100%')
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 价格走势 =====
          Column({ space: DesignSpacing.MD }) {
            Row() {
              Text('价格走势')
                .fontFamily(DesignTypography.FONT_SERIF)
                .fontSize(DesignTypography.SIZE_H3)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeManager.textPrimary())
              Blank()
              Text('查看完整走势 ›')
                .fontSize(DesignTypography.SIZE_CAPTION)
                .fontColor(ThemeManager.accent())
                .onClick(() => RouterUtil.toPriceChart(this.productId))
            }
            .width('100%')
            PriceSparkline({ points: this.sparkData(), chartWidth: 320, chartHeight: 100, strokeColor: ThemeManager.accent() })
              .width('100%')
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 信息元数据 =====
          Column({ space: DesignSpacing.MD }) {
            Row() {
              Text('添加时间')
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textTertiary())
              Blank()
              Text(DateUtil.formatDateTime(this.product().addTime))
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textSecondary())
            }
            .width('100%')
            Row() {
              Text('最近刷新')
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textTertiary())
              Blank()
              Text(DateUtil.relativeTime(this.product().lastRefreshTime))
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textSecondary())
            }
            .width('100%')
            Row() {
              Text('商品链接')
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textTertiary())
              Blank()
              Text(this.product().url)
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.accent())
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .onClick(() => this.openLink())
            }
            .width('100%')
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 快捷操作 =====
          Column({ space: DesignSpacing.MD }) {
            this.actionRow('🎯', '创建降价提醒', '当前价下降 10% 时提醒', () => this.addQuickAlert())
            this.actionRow('💾', '导出此商品数据', '导出 CSV 格式价格历史', () => {
              ToastUtil.show('已导出 CSV');
            })
            this.actionRow('🗑', '移除监控', '删除该商品及所有记录', () => {
              if (this.dialogController !== null) {
                this.dialogController.open();
              }
            }, true)
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          Blank().height(40)
        }
        .width('100%')
        .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.MD })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.bg())
  }

  @Builder
  priceCell(label: string, value: string, color: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(DesignTypography.SIZE_LABEL)
        .fontColor(ThemeManager.textTertiary())
      Text(value)
        .fontFamily(DesignTypography.FONT_MONO)
        .fontSize(DesignTypography.SIZE_PRICE_SM)
        .fontWeight(FontWeight.Medium)
        .fontColor(color)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  actionRow(icon: string, title: string, subtitle: string, action: () => void, danger: boolean = false) {
    Row({ space: DesignSpacing.MD }) {
      Text(icon)
        .fontSize(DesignTypography.SIZE_TITLE)
        .width(30)
        .height(30)
      Column({ space: 2 }) {
        Text(title)
          .fontSize(DesignTypography.SIZE_BODY_SM)
          .fontColor(danger ? ThemeManager.rise() : ThemeManager.textPrimary())
          .fontWeight(FontWeight.Medium)
        Text(subtitle)
          .fontSize(DesignTypography.SIZE_LABEL)
          .fontColor(ThemeManager.textTertiary())
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text('›')
        .fontSize(22)
        .fontColor(ThemeManager.textTertiary())
    }
    .width('100%')
    .padding({ top: 4, bottom: 4 })
    .onClick(() => action())
  }
}
