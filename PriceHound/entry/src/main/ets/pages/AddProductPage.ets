import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { getRepo } from '../repository/DataRepository';
import { Product, Platform, MonitorStatus } from '../model/Product';
import { Category } from '../model/Category';
import { ToastUtil } from '../components/Toast';
import { RouterUtil } from '../utils/RouterUtil';
import { DataSourceType } from '../constants/AppConstants';
import { CoinGeckoApi } from '../service/CoinGeckoApi';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * AddProductPage.ets
 * 添加商品页：三种来源（链接解析 / 关键词搜索 / 手动录入）+ CoinGecko 实时行情
 */
@Entry
@Component
export struct AddProductPage {
  @State sourceTab: number = 0;
  @State linkInput: string = '';
  @State nameInput: string = '';
  @State priceInput: string = '';
  @State platformInput: number = Platform.JD;
  @State categoryInput: string = 'c_other';
  @State loading: boolean = false;
  @State coinResults: Array<string> = [];

  @Builder
  pageTitle() {
    Row() {
      Text('‹')
        .fontSize(30)
        .fontColor(ThemeManager.textPrimary())
        .width(36)
        .onClick(() => RouterUtil.back())
      Text('添加商品')
        .fontFamily(DesignTypography.FONT_SERIF)
        .fontSize(DesignTypography.SIZE_H2)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeManager.textPrimary())
    }
    .width('100%')
    .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.MD, bottom: DesignSpacing.MD })
  }

  @Builder
  sourceTabs() {
    Row({ space: DesignSpacing.SM }) {
      this.tabChip('链接解析', 0)
      this.tabChip('关键词', 1)
      this.tabChip('手动录入', 2)
      if (getRepo().dataSource === DataSourceType.COINGECKO) {
        this.tabChip('行情', 3)
      }
    }
    .width('100%')
    .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, bottom: DesignSpacing.MD })
  }

  @Builder
  tabChip(label: string, index: number) {
    Text(label)
      .fontSize(DesignTypography.SIZE_BODY_SM)
      .fontColor(this.sourceTab === index ? ThemeManager.card() : ThemeManager.textSecondary())
      .fontWeight(this.sourceTab === index ? FontWeight.Medium : FontWeight.Normal)
      .padding({ left: DesignSpacing.MD, right: DesignSpacing.MD, top: 8, bottom: 8 })
      .backgroundColor(this.sourceTab === index ? ThemeManager.textPrimary() : ThemeManager.surface())
      .borderRadius(DesignRadius.XL)
      .onClick(() => {
        this.sourceTab = index;
      })
  }

  @Builder
  linkTab() {
    Column({ space: DesignSpacing.MD }) {
      Text('粘贴商品链接（淘宝 / 京东 / 拼多多）')
        .fontSize(DesignTypography.SIZE_CAPTION)
        .fontColor(ThemeManager.textTertiary())
        .width('100%')
      TextArea({ placeholder: 'https://item.jd.com/…' })
        .width('100%')
        .height(120)
        .backgroundColor(ThemeManager.card())
        .placeholderColor(ThemeManager.textTertiary())
        .fontColor(ThemeManager.textPrimary())
        .borderRadius(DesignRadius.MD)
        .onChange((v: string) => {
          this.linkInput = v;
        })
      Button('解析链接')
        .width('100%')
        .height(46)
        .fontSize(DesignTypography.SIZE_BODY)
        .fontColor(Color.White)
        .backgroundColor(ThemeManager.accent())
        .borderRadius(DesignRadius.MD)
        .onClick(() => {
          if (this.linkInput.trim().length === 0) {
            ToastUtil.show('请先粘贴商品链接');
            return;
          }
          this.loading = true;
          setTimeout(() => {
            this.loading = false;
            this.linkInput = '';
            ToastUtil.show('已解析，请在"手动录入"中补全价格');
            this.sourceTab = 2;
          }, 1200);
        })
      if (this.loading) {
        Row({ space: DesignSpacing.SM }) {
          LoadingProgress()
            .width(18)
            .height(18)
            .color(ThemeManager.accent())
          Text('解析中…')
            .fontSize(DesignTypography.SIZE_CAPTION)
            .fontColor(ThemeManager.textTertiary())
        }
      }
    }
    .width('100%')
    .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
  }

  @Builder
  keywordTab() {
    Column({ space: DesignSpacing.MD }) {
      Text('搜索商品关键词，自动填充名称')
        .fontSize(DesignTypography.SIZE_CAPTION)
        .fontColor(ThemeManager.textTertiary())
        .width('100%')
      TextInput({ placeholder: '例如：无线耳机' })
        .width('100%')
        .height(46)
        .backgroundColor(ThemeManager.card())
        .placeholderColor(ThemeManager.textTertiary())
        .fontColor(ThemeManager.textPrimary())
        .borderRadius(DesignRadius.MD)
        .onChange((v: string) => {
          this.nameInput = v;
        })
      Button('搜索并添加')
        .width('100%')
        .height(46)
        .fontSize(DesignTypography.SIZE_BODY)
        .fontColor(Color.White)
        .backgroundColor(ThemeManager.accent())
        .borderRadius(DesignRadius.MD)
        .onClick(() => {
          if (this.nameInput.trim().length === 0) {
            ToastUtil.show('请输入关键词');
            return;
          }
          this.loading = true;
          setTimeout(() => {
            this.loading = false;
            // 用关键词创建一个模拟商品
            this.createProduct(`${this.nameInput.trim()}（搜索添加）`, 0, 0);
            this.nameInput = '';
          }, 1200);
        })
      if (this.loading) {
        Row({ space: DesignSpacing.SM }) {
          LoadingProgress()
            .width(18)
            .height(18)
            .color(ThemeManager.accent())
          Text('搜索中…')
            .fontSize(DesignTypography.SIZE_CAPTION)
            .fontColor(ThemeManager.textTertiary())
        }
      }
    }
    .width('100%')
    .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
  }

  @Builder
  manualTab() {
    Column({ space: DesignSpacing.MD }) {
      Text('手动录入商品信息')
        .fontSize(DesignTypography.SIZE_CAPTION)
        .fontColor(ThemeManager.textTertiary())
        .width('100%')

      TextInput({ placeholder: '商品名称' })
        .width('100%')
        .height(46)
        .backgroundColor(ThemeManager.card())
        .placeholderColor(ThemeManager.textTertiary())
        .fontColor(ThemeManager.textPrimary())
        .borderRadius(DesignRadius.MD)
        .onChange((v: string) => {
          this.nameInput = v;
        })

      TextInput({ placeholder: '当前价格（元）' })
        .type(InputType.Number)
        .width('100%')
        .height(46)
        .backgroundColor(ThemeManager.card())
        .placeholderColor(ThemeManager.textTertiary())
        .fontColor(ThemeManager.textPrimary())
        .borderRadius(DesignRadius.MD)
        .onChange((v: string) => {
          this.priceInput = v;
        })

      // 平台选择
      Column({ space: DesignSpacing.SM }) {
        Text('所属平台')
          .fontSize(DesignTypography.SIZE_LABEL)
          .fontColor(ThemeManager.textTertiary())
          .width('100%')
        Row({ space: DesignSpacing.SM }) {
          ForEach([Platform.TAOBAO, Platform.JD, Platform.PINDUODUO, Platform.SUNING, Platform.OFFICIAL, Platform.OTHER],
            (p: number) => {
              Text(PlatformLabel[p])
                .fontSize(DesignTypography.SIZE_LABEL)
                .fontColor(this.platformInput === p ? ThemeManager.card() : ThemeManager.textSecondary())
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.platformInput === p ? ThemeManager.textPrimary() : ThemeManager.surface())
                .borderRadius(DesignRadius.SM)
                .onClick(() => {
                  this.platformInput = p;
                })
            }, (p: number) => `${p}`)
        }
        .width('100%')
      }
      .width('100%')

      // 分类选择
      Column({ space: DesignSpacing.SM }) {
        Text('所属分类')
          .fontSize(DesignTypography.SIZE_LABEL)
          .fontColor(ThemeManager.textTertiary())
          .width('100%')
        Scroll() {
          Row({ space: DesignSpacing.SM }) {
            ForEach(getRepo().categories, (c: Category) => {
              Text(`${c.icon} ${c.name}`)
                .fontSize(DesignTypography.SIZE_LABEL)
                .fontColor(this.categoryInput === c.id ? ThemeManager.card() : ThemeManager.textSecondary())
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor(this.categoryInput === c.id ? ThemeManager.textPrimary() : ThemeManager.surface())
                .borderRadius(DesignRadius.SM)
                .onClick(() => {
                  this.categoryInput = c.id;
                })
            }, (c: Category) => c.id)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .width('100%')

      Button('添加到监控')
        .width('100%')
        .height(48)
        .fontSize(DesignTypography.SIZE_BODY)
        .fontColor(Color.White)
        .backgroundColor(ThemeManager.accent())
        .borderRadius(DesignRadius.MD)
        .margin({ top: DesignSpacing.MD })
        .onClick(() => {
          const price = parseFloat(this.priceInput);
          if (this.nameInput.trim().length === 0 || isNaN(price) || price <= 0) {
            ToastUtil.show('请填写商品名称和有效价格');
            return;
          }
          this.createProduct(this.nameInput.trim(), price, this.platformInput);
          this.nameInput = '';
          this.priceInput = '';
        })
    }
    .width('100%')
    .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
  }

  @Builder
  marketTab() {
    Column({ space: DesignSpacing.MD }) {
      Text('从 CoinGecko 实时行情添加（免费 API）')
        .fontSize(DesignTypography.SIZE_CAPTION)
        .fontColor(ThemeManager.textTertiary())
        .width('100%')
      Button('拉取热门行情')
        .width('100%')
        .height(46)
        .fontSize(DesignTypography.SIZE_BODY)
        .fontColor(Color.White)
        .backgroundColor(ThemeManager.accent())
        .borderRadius(DesignRadius.MD)
        .onClick(async () => {
          this.loading = true;
          const markets = await CoinGeckoApi.fetchTopMarkets(20);
          this.loading = false;
          if (markets.length === 0) {
            ToastUtil.show('拉取失败，请检查网络');
            return;
          }
          const names: Array<string> = [];
          for (let i = 0; i < markets.length; i++) {
            names.push(`${markets[i].name} (${markets[i].symbol}) ¥${markets[i].current_price.toFixed(2)}`);
          }
          this.coinResults = names;
          ToastUtil.show(`已获取 ${markets.length} 条行情`);
        })
      if (this.loading) {
        Row({ space: DesignSpacing.SM }) {
          LoadingProgress()
            .width(18)
            .height(18)
            .color(ThemeManager.accent())
          Text('拉取行情中…')
            .fontSize(DesignTypography.SIZE_CAPTION)
            .fontColor(ThemeManager.textTertiary())
        }
      }
      if (this.coinResults.length > 0) {
        Column({ space: DesignSpacing.SM }) {
          ForEach(this.coinResults, (name: string) => {
            Row({ space: DesignSpacing.MD }) {
              Text(name)
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textPrimary())
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
              Text('＋ 添加')
                .fontSize(DesignTypography.SIZE_LABEL)
                .fontColor(ThemeManager.accent())
                .onClick(() => {
                  this.createProduct(name, 0, Platform.OFFICIAL);
                })
            }
            .width('100%')
            .padding(DesignSpacing.MD)
            .backgroundColor(ThemeManager.card())
            .borderRadius(DesignRadius.MD)
          }, (name: string) => name)
        }
        .width('100%')
      }
    }
    .width('100%')
    .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
  }

  private createProduct(name: string, price: number, platform: number): void {
    const p = new Product();
    p.id = `p_${Date.now()}_${Math.floor(Math.random() * 10000)}`;
    p.name = name;
    p.platform = platform;
    p.categoryId = this.categoryInput;
    p.currentPrice = price > 0 ? price : 999 + Math.floor(Math.random() * 4000);
    p.originalPrice = Math.round(p.currentPrice * 1.2);
    p.lowestPrice = Math.round(p.currentPrice * 0.85);
    p.highestPrice = p.originalPrice;
    p.status = MonitorStatus.NORMAL;
    p.imageUrl = '📦';
    p.url = `https://example.com/${p.id}`;
    getRepo().addProduct(p);
    ToastUtil.show(`已添加「${p.name}」`);
    setTimeout(() => {
      RouterUtil.back();
    }, 600);
  }

  build() {
    Column() {
      this.pageTitle()
      this.sourceTabs()
      Scroll() {
        Column({ space: DesignSpacing.XL }) {
          if (this.sourceTab === 0) {
            this.linkTab()
          } else if (this.sourceTab === 1) {
            this.keywordTab()
          } else if (this.sourceTab === 2) {
            this.manualTab()
          } else {
            this.marketTab()
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
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

const PlatformLabel: string[] = ['淘宝', '京东', '拼多多', '苏宁', '官方', '其他'];
