import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { getRepo } from '../repository/DataRepository';
import { Product } from '../model/Product';
import { PriceUtil } from '../utils/PriceUtil';
import { DateUtil } from '../utils/DateUtil';
import { StatCard } from '../components/StatCard';
import { SectionHeader } from '../components/SectionHeader';
import { PriceSparkline } from '../components/PriceSparkline';
import { EmptyState } from '../components/EmptyState';
import { RouterUtil } from '../utils/RouterUtil';
import { MonitorStatusDot } from '../components/MonitorStatusDot';
import { DashboardViewModel } from '../viewmodel/DashboardViewModel';
import { ThemeManager } from '../utils/ThemeManager';
import { MotionDuration, MotionCurve } from '../constants/MotionTokens';
import { SkeletonList } from '../components/SkeletonList';

/**
 * DashboardPage.ets
 * 看板页：顶部问候 + 4 个统计卡片 + 变动 Top5 + 提醒条数角标
 * - 统计逻辑下沉 DashboardViewModel
 * - 深色适配 + 下拉刷新 + 列表渐入动画
 */

interface TopMove {
  p: Product;
  change: number;       // 近7日涨跌幅 %
}

@Component
export struct DashboardPage {
  @State refreshKey: number = 0;
  @State refreshing: boolean = false;
  @State loading: boolean = true;
  @StorageProp('theme.isDark') isDark: boolean = false;

  aboutToAppear(): void {
    this.refreshKey++;
    // 模拟加载骨架屏
    setTimeout(() => {
      this.loading = false;
    }, 400);
  }

  private topMoves(): Array<TopMove> {
    const result: Array<TopMove> = [];
    const moves = DashboardViewModel.topMoves(5);
    for (let i = 0; i < moves.length; i++) {
      const p = getRepo().getProduct(moves[i].productId);
      if (p !== undefined) {
        result.push({ p: p, change: moves[i].changePercent });
      }
    }
    return result;
  }

  private sparkData(p: Product): Array<number> {
    return DashboardViewModel.sparkOf(p.id, 7);
  }

  @Builder
  emptyPlaceholder() {
    if (getRepo().products.length === 0) {
      EmptyState({
        icon: '📦',
        title: '还没有监控商品',
        subtitle: '点击右上角 + 添加第一个商品吧',
        actionText: '去添加',
        actionClick: () => RouterUtil.push('pages/AddProductPage'),
      })
    }
  }

  build() {
    Refresh({ refreshing: this.refreshing })
      .onRefreshing(() => {
        setTimeout(() => {
          this.refreshKey++;
          this.refreshing = false;
        }, 600);
      }) {
      Scroll() {
        Column({ space: DesignSpacing.XL }) {
          if (this.loading) {
            SkeletonList({ count: 3 })
            Blank().height(72)
          } else {
            // ===== 顶部问候 =====
            Row() {
              Column({ space: 2 }) {
                Text(`${DashboardViewModel.greeting()} 👋`)
                  .fontFamily(DesignTypography.FONT_SERIF)
                  .fontSize(DesignTypography.SIZE_H2)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeManager.textPrimary())
                Text(`${DateUtil.formatDate(Date.now())} · PriceHound`)
                  .fontSize(DesignTypography.SIZE_CAPTION)
                  .fontColor(ThemeManager.textTertiary())
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Button() {
                Text('＋')
                  .fontSize(22)
                  .fontColor(Color.White)
              }
              .width(44)
              .height(44)
              .borderRadius(DesignRadius.MD)
              .backgroundColor(ThemeManager.accent())
              .stateStyles({
                pressed: {
                  .scale({ x: 0.92, y: 0.92 })
                }
              })
              .onClick(() => RouterUtil.push('pages/AddProductPage'))
            }
            .width('100%')
            .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.LG })

            // ===== 统计卡片 =====
            Grid() {
              GridItem() {
                StatCard({ label: '监控商品', value: `${getRepo().products.length}`, icon: '📦' })
              }
              GridItem() {
                StatCard({ label: '今日变动', value: `${DashboardViewModel.computeStats().todayChanges}`, icon: '📈' })
              }
              GridItem() {
                StatCard({
                  label: '累计节省',
                  value: PriceUtil.format(DashboardViewModel.computeStats().totalSaved),
                  icon: '💰',
                  valueColor: ThemeManager.accent(),
                })
              }
              GridItem() {
                StatCard({
                  label: '今日节省',
                  value: PriceUtil.format(DashboardViewModel.computeStats().todaySaved),
                  icon: '🎉',
                  valueColor: ThemeManager.accent(),
                })
              }
            }
            .columnsTemplate('1fr 1fr')
            .rowsTemplate('1fr 1fr')
            .columnsGap(DesignSpacing.MD)
            .rowsGap(DesignSpacing.MD)
            .width('100%')
            .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
            .height(220)

            // ===== 波动 Top5 =====
            SectionHeader({ title: '波动 Top 5', moreText: '查看全部' })
            Column({ space: DesignSpacing.MD }) {
              ForEach(this.topMoves(), (item: TopMove, index: number) => {
                Row({ space: DesignSpacing.MD }) {
                  Text(`${index + 1}`)
                    .fontFamily(DesignTypography.FONT_MONO)
                    .fontSize(DesignTypography.SIZE_BODY_SM)
                    .fontColor(ThemeManager.textTertiary())
                    .width(20)
                  Column({ space: 4 }) {
                    Text(item.p.name)
                      .fontSize(DesignTypography.SIZE_BODY_SM)
                      .fontColor(ThemeManager.textPrimary())
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Row({ space: DesignSpacing.SM }) {
                      MonitorStatusDot({ status: item.p.status })
                    }
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)

                  PriceSparkline({ points: this.sparkData(item.p), chartWidth: 80, chartHeight: 30 })

                  Column({ space: 2 }) {
                    Text(PriceUtil.format(item.p.currentPrice))
                      .fontFamily(DesignTypography.FONT_MONO)
                      .fontSize(DesignTypography.SIZE_PRICE_SM)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(item.change <= 0 ? ThemeManager.drop() : ThemeManager.rise())
                    Text(`${item.change <= 0 ? '▼' : '▲'} ${Math.abs(item.change).toFixed(1)}%`)
                      .fontSize(DesignTypography.SIZE_LABEL)
                      .fontColor(item.change <= 0 ? ThemeManager.drop() : ThemeManager.rise())
                  }
                  .alignItems(HorizontalAlign.End)
                }
                .width('100%')
                .padding(DesignSpacing.MD)
                .backgroundColor(ThemeManager.card())
                .borderRadius(DesignRadius.MD)
                .translate({ y: this.refreshKey > 0 && index < 3 ? 8 : 0 })
                .opacity(this.refreshKey > 0 && index < 3 ? 0 : 1)
                .animation({
                  duration: MotionDuration.BASE,
                  curve: MotionCurve.EASE_OUT,
                  delay: index * MotionDuration.STAGGER,
                })
                .onClick(() => RouterUtil.toProductDetail(item.p.id))
              }, (item: TopMove) => item.p.id)
            }
            .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })

            // ===== 空状态兜底 =====
            this.emptyPlaceholder()

            // 底部留白给 TabBar
            Blank().height(72)
          }
        }
        .width('100%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeManager.bg())
      .scrollBar(BarState.Off)
    }
  }
}
