import { router } from '@kit.ArkUI';
import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { getRepo } from '../repository/DataRepository';
import { Product } from '../model/Product';
import { PriceUtil } from '../utils/PriceUtil';
import { DateUtil } from '../utils/DateUtil';
import { TimeFilterBar } from '../components/TimeFilterBar';
import { PriceTag } from '../components/PriceTag';
import { RouterUtil } from '../utils/RouterUtil';
import { PriceRecord } from '../model/PriceRecord';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * PriceChartPage.ets
 * 价格走势图页：时间范围筛选 + Canvas 大图 + 关键指标 + 记录列表
 */
@Entry
@Component
export struct PriceChartPage {
  @StorageProp('theme.isDark') @Watch('onThemeChanged') isDark: boolean = false;
  @State productId: string = '';
  @State rangeIndex: number = 1; // 0=7d 1=30d 2=90d 3=all
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  @State canvasKey: number = 0;

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params !== undefined && params['productId'] !== undefined) {
      this.productId = params['productId'] as string;
    }
  }

  private onThemeChanged(): void {
    this.drawChart();
  }

  private product(): Product {
    const p = getRepo().getProduct(this.productId);
    return p !== undefined ? p : new Product();
  }

  private rangeRecords(): Array<PriceRecord> {
    const recs = getRepo().getRecords(this.productId);
    const now = Date.now();
    let days = 0;
    if (this.rangeIndex === 0) {
      days = 7;
    } else if (this.rangeIndex === 1) {
      days = 30;
    } else if (this.rangeIndex === 2) {
      days = 90;
    } else {
      return recs;
    }
    const threshold = now - days * 24 * 3600 * 1000;
    const result: Array<PriceRecord> = [];
    for (let i = 0; i < recs.length; i++) {
      if (recs[i].timestamp >= threshold) {
        result.push(recs[i]);
      }
    }
    return result.length >= 2 ? result : recs;
  }

  private minPrice(): number {
    const recs = this.rangeRecords();
    if (recs.length === 0) {
      return 0;
    }
    let min = recs[0].price;
    for (let i = 1; i < recs.length; i++) {
      if (recs[i].price < min) {
        min = recs[i].price;
      }
    }
    return min;
  }

  private maxPrice(): number {
    const recs = this.rangeRecords();
    if (recs.length === 0) {
      return 0;
    }
    let max = recs[0].price;
    for (let i = 1; i < recs.length; i++) {
      if (recs[i].price > max) {
        max = recs[i].price;
      }
    }
    return max;
  }

  private changePercent(): number {
    const recs = this.rangeRecords();
    if (recs.length < 2) {
      return 0;
    }
    const first = recs[0].price;
    const last = recs[recs.length - 1].price;
    if (first === 0) {
      return 0;
    }
    return ((last - first) / first) * 100;
  }

  private drawChart(): void {
    const recs = this.rangeRecords();
    if (recs.length < 2) {
      return;
    }
    const ctx = this.ctx;
    const W = 340;
    const H = 240;
    ctx.clearRect(0, 0, W, H);
    const padX = 16;
    const padTop = 20;
    const padBottom = 30;

    const min = this.minPrice();
    const max = this.maxPrice();
    const range = max - min;
    const innerW = W - padX * 2;
    const innerH = H - padTop - padBottom;

    const toX = (i: number): number => {
      return padX + (i / (recs.length - 1)) * innerW;
    };
    const toY = (v: number): number => {
      if (range === 0) {
        return padTop + innerH / 2;
      }
      return padTop + (1 - (v - min) / range) * innerH;
    };

    // 网格（仅水平，柔和）
    ctx.strokeStyle = this.isDark ? 'rgba(226,222,212,0.10)' : 'rgba(94,93,89,0.12)';
    ctx.lineWidth = 1;
    for (let g = 0; g <= 4; g++) {
      const y = padTop + (g / 4) * innerH;
      ctx.beginPath();
      ctx.moveTo(padX, y);
      ctx.lineTo(W - padX, y);
      ctx.stroke();
    }

    // 渐变面积
    const grad = ctx.createLinearGradient(0, 0, 0, H);
    grad.addColorStop(0, this.isDark ? 'rgba(201,100,66,0.35)' : 'rgba(201,100,66,0.25)');
    grad.addColorStop(1, this.isDark ? 'rgba(201,100,66,0.05)' : 'rgba(201,100,66,0.02)');
    ctx.beginPath();
    ctx.moveTo(toX(0), toY(recs[0].price));
    for (let i = 1; i < recs.length; i++) {
      ctx.lineTo(toX(i), toY(recs[i].price));
    }
    ctx.lineTo(toX(recs.length - 1), padTop + innerH);
    ctx.lineTo(toX(0), padTop + innerH);
    ctx.closePath();
    ctx.fillStyle = grad;
    ctx.fill();

    // 折线
    const down = recs[recs.length - 1].price <= recs[0].price;
    const lineColor = down ? ThemeManager.accent() : ThemeManager.rise();
    ctx.strokeStyle = lineColor;
    ctx.lineWidth = 2;
    ctx.lineJoin = 'round';
    ctx.lineCap = 'round';
    ctx.beginPath();
    ctx.moveTo(toX(0), toY(recs[0].price));
    for (let i = 1; i < recs.length; i++) {
      ctx.lineTo(toX(i), toY(recs[i].price));
    }
    ctx.stroke();

    // 最新点
    ctx.beginPath();
    ctx.arc(toX(recs.length - 1), toY(recs[recs.length - 1].price), 4, 0, Math.PI * 2);
    ctx.fillStyle = lineColor;
    ctx.fill();

    // X 轴标签
    ctx.fillStyle = ThemeManager.textTertiary();
    ctx.font = '11px sans-serif';
    const labels: Array<number> = [0, Math.floor((recs.length - 1) / 2), recs.length - 1];
    for (let i = 0; i < labels.length; i++) {
      const idx = labels[i];
      const label = DateUtil.axisLabel(recs[idx].timestamp, this.rangeDays());
      ctx.fillText(label, toX(idx) - 15, H - 8);
    }

    // Y 轴价格标签
    const yLabels: Array<number> = [min, min + range / 2, max];
    for (let i = 0; i < yLabels.length; i++) {
      const v = yLabels[i];
      const text = `¥${Math.round(v)}`;
      ctx.fillText(text, 0, toY(v) + 4);
    }
  }

  private rangeDays(): number {
    if (this.rangeIndex === 0) {
      return 7;
    } else if (this.rangeIndex === 1) {
      return 30;
    } else if (this.rangeIndex === 2) {
      return 90;
    }
    return 365;
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
        Column({ space: 2 }) {
          Text(this.product().name)
            .fontFamily(DesignTypography.FONT_SERIF)
            .fontSize(DesignTypography.SIZE_TITLE)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.textPrimary())
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text('价格走势')
            .fontSize(DesignTypography.SIZE_LABEL)
            .fontColor(ThemeManager.textTertiary())
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: DesignSpacing.SM })
        Blank().width(36)
      }
      .width('100%')
      .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.MD, bottom: DesignSpacing.MD })

      Scroll() {
        Column({ space: DesignSpacing.XL }) {
          // ===== 关键指标 =====
          Row({ space: DesignSpacing.MD }) {
            Column({ space: 4 }) {
              Text('当前价格')
                .fontSize(DesignTypography.SIZE_LABEL)
                .fontColor(ThemeManager.textTertiary())
              PriceTag({ price: this.product().currentPrice, fontSize: 24 })
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            this.metricCell('区间最低', PriceUtil.format(this.minPrice()), ThemeManager.drop())
            this.metricCell('区间最高', PriceUtil.format(this.maxPrice()), ThemeManager.rise())
            this.metricCell('区间涨跌', `${this.changePercent() >= 0 ? '+' : ''}${this.changePercent().toFixed(1)}%`,
              this.changePercent() <= 0 ? ThemeManager.drop() : ThemeManager.rise())
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 时间筛选 =====
          TimeFilterBar({
            selectedIndex: this.rangeIndex,
            onSelect: (index: number) => {
              this.rangeIndex = index;
              this.canvasKey++;
              this.drawChart();
            },
          })
            .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })

          // ===== 走势大图 =====
          Column() {
            Canvas(this.ctx)
              .width('100%')
              .height(240)
              .onReady(() => this.drawChart())
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 记录列表 =====
          Row() {
            Text('价格记录')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H3)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
            Blank()
          }
          .width('100%')
          .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })

          Column({ space: DesignSpacing.MD }) {
            ForEach(this.rangeRecords().reverse().slice(0, 10), (rec: PriceRecord) => {
              Row({ space: DesignSpacing.MD }) {
                Column({ space: 2 }) {
                  Text(PriceUtil.format(rec.price))
                    .fontFamily(DesignTypography.FONT_MONO)
                    .fontSize(DesignTypography.SIZE_PRICE_SM)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(ThemeManager.textPrimary())
                  Text(rec.source === 'coingecko' ? '实时行情源' : '模拟数据源')
                    .fontSize(DesignTypography.SIZE_LABEL)
                    .fontColor(ThemeManager.textTertiary())
                }
                .alignItems(HorizontalAlign.Start)
                Blank()
                Text(DateUtil.formatDateTime(rec.timestamp))
                  .fontSize(DesignTypography.SIZE_BODY_SM)
                  .fontColor(ThemeManager.textSecondary())
              }
              .width('100%')
              .padding(DesignSpacing.MD)
              .backgroundColor(ThemeManager.card())
              .borderRadius(DesignRadius.MD)
            }, (rec: PriceRecord) => rec.id)
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

  @Builder
  metricCell(label: string, value: string, color: string) {
    Column({ space: 2 }) {
      Text(label)
        .fontSize(DesignTypography.SIZE_LABEL)
        .fontColor(ThemeManager.textTertiary())
      Text(value)
        .fontFamily(DesignTypography.FONT_MONO)
        .fontSize(DesignTypography.SIZE_CAPTION)
        .fontWeight(FontWeight.Medium)
        .fontColor(color)
        .maxLines(1)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}
