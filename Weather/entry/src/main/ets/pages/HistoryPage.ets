/**
 * 历史收藏列表页
 */
import { CardData } from '../model/CardData';
import { DataProvider } from '../utils/DataProvider';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct HistoryPage {
  @State favorites: CardData[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    this.loadFavorites();
  }

  async loadFavorites(): Promise<void> {
    this.isLoading = true;
    try {
      const ctx = this.getUIContext().getHostContext();
      const favs = await DataProvider.getFavoriteCards(ctx!);
      this.favorites = favs;
    } catch (e) {
      console.error('Load favorites failed');
    }
    this.isLoading = false;
  }

  build() {
    Column() {
      // 顶部栏
      Row() {
        Button() {
          SymbolGlyph($r('sys.symbol.chevron_left'))
            .fontSize(24)
            .fontColor(['#ffffff'])
        }
        .width(44)
        .height(44)
        .backgroundColor('rgba(255,255,255,0.1)')
        .borderRadius(22)
        .onClick(() => {
          router.back();
        })

        Text('收藏卡片')
          .fontSize(20)
          .fontWeight(500)
          .fontColor('#ffffff')
          .margin({ left: 16 })

        Blank()

        Text(`${this.favorites.length} 张`)
          .fontSize(14)
          .fontColor('rgba(255,255,255,0.5)')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 12, bottom: 12 })

      // 内容
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#ffffff')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.favorites.length === 0) {
        Column() {
          SymbolGlyph($r('sys.symbol.heart'))
            .fontSize(48)
            .fontColor(['rgba(255,255,255,0.3)'])

          Text('还没有收藏呢')
            .fontSize(16)
            .fontColor('rgba(255,255,255,0.5)')
            .margin({ top: 16 })

          Text('双击卡片即可收藏')
            .fontSize(13)
            .fontColor('rgba(255,255,255,0.3)')
            .margin({ top: 8 })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        // 瀑布流
        Grid() {
          ForEach(this.favorites, (card: CardData, index: number) => {
            GridItem() {
              this.buildCardItem(card)
            }
          }, (card: CardData) => card.cardId)
        }
        .columnsTemplate('1fr 1fr')
        .rowsGap(12)
        .columnsGap(12)
        .padding({ left: 16, right: 16, top: 8, bottom: 24 })
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#1a1a2e')
  }

  @Builder
  buildCardItem(card: CardData) {
    Column() {
      Stack() {
        Row()
          .width('100%')
          .height('100%')
          .borderRadius(16)
          .linearGradient({
            direction: GradientDirection.Bottom,
            colors: [
              [card.primaryColor, 0],
              [card.secondaryColor, 1]
            ]
          })

        Column()
          .width('100%')
          .height('100%')
          .borderRadius(16)
          .backgroundColor('rgba(255,255,255,0.05)')
          .backdropBlur(4)

        Column() {
          Text(card.quote)
            .fontSize(11)
            .fontWeight(300)
            .fontColor(card.textColor)
            .maxLines(3)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .lineHeight(16)
            .padding({ left: 10, right: 10 })
            .textShadow({
              radius: 4,
              color: card.glowColor,
              offsetX: 0,
              offsetY: 0
            })

          Blank()

          Row() {
            Text(`${card.steps}步`)
              .fontSize(9)
              .fontColor(card.textColor)
              .opacity(0.5)

            Blank()

            Text(card.dateStr)
              .fontSize(9)
              .fontColor(card.textColor)
              .opacity(0.5)

            Text(card.temperatureStr)
              .fontSize(9)
              .fontColor(card.textColor)
              .opacity(0.5)
              .margin({ left: 6 })
          }
          .width('100%')
          .padding({ left: 10, right: 10, bottom: 8 })
        }
        .width('100%')
        .height('100%')
        .padding({ top: 12, bottom: 4 })
      }
      .width('100%')
      .aspectRatio(3 / 4)
      .borderRadius(16)
      .border({ width: 0.5, color: 'rgba(255,255,255,0.15)' })
      .shadow({
        radius: 8,
        color: card.glowColor,
        offsetX: 0,
        offsetY: 2,
        fill: false
      })
    }
    .width('100%')
    .onClick(() => {
      AlertDialog.show({
        title: card.dateStr,
        message: `${card.quote}\n\n—— ${card.quoteAuthor}\n\n${card.temperatureStr} · ${card.steps}步 · ${card.weather.description}`,
        autoCancel: true,
        alignment: DialogAlignment.Center
      });
    })
  }
}
