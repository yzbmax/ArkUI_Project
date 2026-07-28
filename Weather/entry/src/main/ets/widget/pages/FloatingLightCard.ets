/**
 * 浮光万能卡片 (2x2 Form Widget)
 */
import { CardData, WeatherData } from '../../model/CardData';
import { DataToVisualMapper } from '../../utils/DataToVisualMapper';

const MOCK_WEATHER: WeatherData = {
  weatherCode: 0,
  temperature: 26,
  description: '晴'
};

@Entry
@Component
struct FloatingLightCard {
  @State cardTitle: string = '浮光';
  @State quote: string = '万物皆有裂痕，那是光照进来的地方。';
  @State temperature: string = '26°C';
  @State steps: string = '5234步';
  @State weatherDesc: string = '晴';
  @State primaryColor: string = '#7eb8da';
  @State secondaryColor: string = '#5a8ab5';
  @State dotOpacity1: number = 0.3;
  @State dotOpacity2: number = 0.4;
  @State dotOpacity3: number = 0.25;
  @State dotOpacity4: number = 0.35;
  @State dotOpacity5: number = 0.28;

  aboutToAppear(): void {
    const mockCard = DataToVisualMapper.map(MOCK_WEATHER, 5234, Date.now());
    this.quote = mockCard.quote;
    this.temperature = mockCard.temperatureStr;
    this.steps = `${mockCard.steps}步`;
    this.weatherDesc = mockCard.weather.description;
    this.primaryColor = mockCard.primaryColor;
    this.secondaryColor = mockCard.secondaryColor;
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .borderRadius(16)
        .linearGradient({
          direction: GradientDirection.RightBottom,
          colors: [
            [this.primaryColor, 0.0],
            [this.secondaryColor, 1.0]
          ]
        })

      // 光点装饰
      Stack() {
        Circle().width(4).height(4)
          .fill('rgba(255,255,255,0.35)')
          .position({ x: '15%', y: '20%' })
          .shadow({ radius: 6, color: 'rgba(255,255,255,0.3)', offsetX: 0, offsetY: 0 })

        Circle().width(3).height(3)
          .fill('rgba(255,255,255,0.3)')
          .position({ x: '75%', y: '15%' })

        Circle().width(5).height(5)
          .fill('rgba(255,255,255,0.25)')
          .position({ x: '60%', y: '70%' })

        Circle().width(3).height(3)
          .fill('rgba(255,255,255,0.32)')
          .position({ x: '25%', y: '65%' })

        Circle().width(4).height(4)
          .fill('rgba(255,255,255,0.28)')
          .position({ x: '85%', y: '45%' })
      }
      .width('100%')
      .height('100%')

      // 半透明蒙层
      Column()
        .width('100%')
        .height('100%')
        .borderRadius(16)
        .backgroundColor('rgba(0,0,0,0.15)')

      // 内容
      Column() {
        Row() {
          Text(this.cardTitle)
            .fontSize(11)
            .fontWeight(300)
            .fontColor('rgba(255,255,255,0.8)')

          Blank()

          Text(this.weatherDesc)
            .fontSize(10)
            .fontColor('rgba(255,255,255,0.55)')
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 10 })

        Blank()

        Text(this.quote)
          .fontSize(12)
          .fontWeight(200)
          .fontColor('rgba(255,255,255,0.88)')
          .maxLines(3)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(18)
          .textAlign(TextAlign.Center)
          .padding({ left: 14, right: 14 })
          .textShadow({
            radius: 4,
            color: 'rgba(255,255,255,0.25)',
            offsetX: 0,
            offsetY: 0
          })

        Blank()

        Row() {
          Text(this.steps)
            .fontSize(9)
            .fontColor('rgba(255,255,255,0.5)')

          Blank()

          Text(this.temperature)
            .fontSize(9)
            .fontColor('rgba(255,255,255,0.5)')
        }
        .width('100%')
        .padding({ left: 12, right: 12, bottom: 10 })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .borderRadius(16)
    .onClick(() => {
      postCardAction(this, {
        action: 'router',
        abilityName: 'EntryAbility',
        params: { message: 'fromWidget' }
      });
    })
  }
}
