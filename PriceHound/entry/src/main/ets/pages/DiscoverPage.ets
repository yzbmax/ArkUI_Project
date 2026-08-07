import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { getRepo } from '../repository/DataRepository';
import { Product } from '../model/Product';
import { Category } from '../model/Category';
import { ProductCard } from '../components/ProductCard';
import { EmptyState } from '../components/EmptyState';
import { CategoryChip } from '../components/CategoryChip';
import { RouterUtil } from '../utils/RouterUtil';
import { DataSourceType } from '../constants/AppConstants';
import { ProductViewModel, ProductSortType } from '../viewmodel/ProductViewModel';
import { ThemeManager } from '../utils/ThemeManager';
import { MotionDuration, MotionCurve } from '../constants/MotionTokens';

/**
 * DiscoverPage.ets
 * 发现页：搜索 + 分类筛选 + 商品网格（支持 Mock / CoinGecko 数据源提示）
 * - 筛选/排序下沉 ProductViewModel
 * - 深色适配 + 下拉刷新 + 列表渐入动画
 */
@Component
export struct DiscoverPage {
  @State keyword: string = '';
  @State selectedCategory: string = 'all';
  @State gridMode: boolean = false;
  @State refreshKey: number = 0;
  @State sortType: number = ProductSortType.ADD_TIME;
  @State refreshing: boolean = false;
  @StorageProp('theme.isDark') isDark: boolean = false;

  private categories(): Array<string> {
    const list: Array<string> = ['all'];
    for (let i = 0; i < getRepo().categories.length; i++) {
      list.push(getRepo().categories[i].id);
    }
    return list;
  }

  private categoryName(id: string): string {
    if (id === 'all') {
      return '全部';
    }
    const cat = getRepo().categories.find((c: Category): boolean => c.id === id);
    return cat !== undefined ? cat.name : '全部';
  }

  private filtered(): Array<Product> {
    const base = ProductViewModel.filter(this.keyword, this.selectedCategory);
    return ProductViewModel.sort(base, this.sortType as ProductSortType);
  }

  build() {
    Column() {
      // ===== 顶部标题 =====
      Row() {
        Column({ space: 2 }) {
          Text('发现')
            .fontFamily(DesignTypography.FONT_SERIF)
            .fontSize(DesignTypography.SIZE_H1)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.textPrimary())
          Text(getRepo().dataSource === DataSourceType.COINGECKO ? '数据源：CoinGecko 实时行情' : '数据源：本地模拟数据')
            .fontSize(DesignTypography.SIZE_LABEL)
            .fontColor(getRepo().dataSource === DataSourceType.COINGECKO ? ThemeManager.accent() : ThemeManager.textTertiary())
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

      // ===== 搜索框 =====
      Search({ value: this.keyword, placeholder: '搜索商品名称' })
        .width('100%')
        .height(44)
        .margin({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.MD })
        .backgroundColor(ThemeManager.card())
        .placeholderColor(ThemeManager.textTertiary())
        .placeholderFont({ size: DesignTypography.SIZE_BODY_SM })
        .fontColor(ThemeManager.textPrimary())
        .textFont({ size: DesignTypography.SIZE_BODY_SM })
        .onChange((value: string) => {
          this.keyword = value;
        })

      // ===== 分类筛选 =====
      Scroll() {
        Row({ space: DesignSpacing.SM }) {
          CategoryChip({
            label: '全部',
            icon: '🗂️',
            selected: this.selectedCategory === 'all',
            onClickChip: () => {
              this.selectedCategory = 'all';
            },
          })
          ForEach(this.categories(), (id: string) => {
            if (id !== 'all') {
              CategoryChip({
                label: this.categoryName(id),
                icon: '📦',
                selected: this.selectedCategory === id,
                onClickChip: () => {
                  this.selectedCategory = id;
                },
              })
            }
          }, (id: string) => id)
        }
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.MD, bottom: DesignSpacing.MD })

      // ===== 视图切换 + 排序 =====
      Row() {
        Text(`${this.filtered().length} 件商品`)
          .fontSize(DesignTypography.SIZE_CAPTION)
          .fontColor(ThemeManager.textTertiary())
        Blank()
        Row({ space: DesignSpacing.MD }) {
          Text(this.sortName(this.sortType))
            .fontSize(DesignTypography.SIZE_LABEL)
            .fontColor(ThemeManager.accent())
            .onClick(() => {
              this.cycleSort();
            })
          Text(this.gridMode ? '列表' : '宫格')
            .fontSize(DesignTypography.SIZE_LABEL)
            .fontColor(ThemeManager.accent())
            .onClick(() => {
              this.gridMode = !this.gridMode;
            })
        }
      }
      .width('100%')
      .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, bottom: DesignSpacing.MD })

      // ===== 商品列表 =====
      Column() {
        Refresh({ refreshing: this.refreshing })
          .onRefreshing(() => {
            setTimeout(() => {
              this.refreshKey++;
              this.refreshing = false;
            }, 600);
          }) {
          Column() {
            if (this.filtered().length === 0) {
              EmptyState({
                icon: '🔍',
                title: '没有找到商品',
                subtitle: '换个关键词或分类试试',
              })
            } else if (this.gridMode) {
              Grid() {
                ForEach(this.filtered(), (p: Product) => {
                  GridItem() {
                    ProductCard({ productId: p.id, gridMode: true })
                  }
                  .opacity(this.refreshKey > 0 ? 0.4 : 1)
                  .animation({ duration: MotionDuration.BASE, curve: MotionCurve.EASE_OUT })
                }, (p: Product) => p.id)
              }
              .columnsTemplate('1fr 1fr')
              .columnsGap(DesignSpacing.MD)
              .rowsGap(DesignSpacing.MD)
              .width('100%')
              .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
            } else {
              Column({ space: DesignSpacing.MD }) {
                ForEach(this.filtered(), (p: Product, index: number) => {
                  ProductCard({ productId: p.id, gridMode: false })
                    .translate({ y: this.refreshKey > 0 && index < 3 ? 10 : 0 })
                    .opacity(this.refreshKey > 0 && index < 3 ? 0 : 1)
                    .animation({
                      duration: MotionDuration.BASE,
                      curve: MotionCurve.EASE_OUT,
                      delay: index * MotionDuration.STAGGER,
                    })
                }, (p: Product) => p.id)
              }
              .width('100%')
              .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
            }
            Blank().height(72)
          }
          .width('100%')
          .height('100%')
        }
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.bg())
  }

  private sortName(type: number): string {
    switch (type) {
      case ProductSortType.PRICE_ASC:
        return '价格 ↑';
      case ProductSortType.PRICE_DESC:
        return '价格 ↓';
      case ProductSortType.CHANGE_ASC:
        return '降幅最大';
      default:
        return '最新添加';
    }
  }

  private cycleSort(): void {
    const next: number = (this.sortType + 1) % 4;
    this.sortType = next;
  }
}
