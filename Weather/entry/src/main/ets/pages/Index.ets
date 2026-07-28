/**
 * 浮光 - 主页面
 * 全屏沉浸式动态艺术卡片
 * 包含粒子系统、毛玻璃卡片、多维度交互
 */
import { CardData, ParticleType, DayPeriod } from '../model/CardData';
import { ParticleEngine, ParticleEngineParams } from '../utils/ParticleEngine';
import { DataProvider } from '../utils/DataProvider';
import { Constants } from '../common/Constants';
import { DataToVisualMapper } from '../utils/DataToVisualMapper';
import { QUOTES_LIBRARY } from '../model/QuotesData';
import type { QuoteItem } from '../model/QuotesData';
import { vibrator } from '@kit.SensorServiceKit';
import { router } from '@kit.ArkUI';

interface CardDataWithFavorite extends CardData {
  isFavorite: boolean;
}

@Entry
@Component
struct Index {
  @State cardData: CardData | null = null;
  @State isLoading: boolean = true;
  @State bgColor: string = '#1a1a2e';

  // -- 动画状态 --
  @State breatheScale: number = 1.0;
  @State lightSweepX: number = -200;
  @State lightSweepOpacity: number = 0;
  @State cardShadowOffsetY: number = 0;

  // -- 交互状态 --
  @State rippleAnimValue: number = 0;
  @State rippleCenterX: number = 0;
  @State rippleCenterY: number = 0;
  @State showRipple: boolean = false;
  @State quoteOpacity: number = 1.0;
  @State showFavoriteStamp: boolean = false;
  @State favoriteStampScale: number = 0;
  @State cardBounceScale: number = 1.0;

  // -- 粒子引擎 --
  private particleEngine: ParticleEngine = new ParticleEngine();
  private canvasWidth: number = 360;
  private canvasHeight: number = 780;
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private canvasContext: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  // -- 计时器 --
  private breatheTimer: number = -1;
  private lightSweepTimer: number = -1;
  private rippleTimer: number = -1;

  // -- 触摸 --
  private isCardArea: boolean = false;
  private lastTapTime: number = 0;

  // -- 刷新动画 --
  @State refreshRotate: number = 0;
  @State isRefreshing: boolean = false;
  @State cardContentOpacity: number = 1;
  @State cardContentScale: number = 1;

  // -- 登录弹窗 --
  @State showLogin: boolean = true;
  @State username: string = '';
  @State password: string = '';
  @State loginError: string = '';
  @State loginDialogOpacity: number = 0;
  @State loginDialogScale: number = 0.85;
  @State loginButtonScale: number = 1.0;
  @State loginShakeX: number = 0;

  aboutToAppear(): void {
    this.loadCardData();
    this.startBreathingAnimation();
    this.startLightSweepCycle();
    setTimeout(() => {
      this.animateLoginEnter();
    }, 300);
  }

  aboutToDisappear(): void {
    this.clearAllTimers();
    this.particleEngine.stopAnimation();
  }

  async loadCardData(): Promise<void> {
    this.isLoading = true;
    try {
      const ctx = this.getUIContext().getHostContext();
      const seed = DataProvider.getNextRefreshSeed();
      const card = await DataProvider.buildNewCard(ctx!, seed);
      this.cardData = card;
      this.bgColor = this.deriveBgColor(card.primaryColor);
      const isFav = await DataProvider.isTodayCardFavorite(ctx!, card.cardId);
      (card as CardDataWithFavorite).isFavorite = isFav;
    } catch (e) {
      console.error('Load card failed');
    }
    this.isLoading = false;
  }

  async refreshCard(): Promise<void> {
    if (this.isRefreshing) {
      return;
    }
    this.isRefreshing = true;

    // 旋转动画
    const animStart: number = Date.now();
    const animDuration: number = 400;
    const animateSpin: () => void = (): void => {
      const elapsed: number = Date.now() - animStart;
      const t: number = Math.min(1, elapsed / animDuration);
      const eased: number = 1 - Math.pow(1 - t, 3);
      this.refreshRotate = eased * 360;
      if (t < 1) {
        setTimeout(animateSpin, 16);
      }
    };
    setTimeout(animateSpin, 16);

    // 卡片内容淡出
    animateTo({ duration: 180, curve: Curve.EaseIn }, () => {
      this.cardContentOpacity = 0;
      this.cardContentScale = 0.95;
    });
    await new Promise<void>((r: (value: void) => void) => setTimeout(r, 200));

    // 重新生成卡片
    try {
      const ctx = this.getUIContext().getHostContext();
      const seed: number = DataProvider.getNextRefreshSeed();
      const card: CardData = await DataProvider.buildNewCard(ctx!, seed);
      const isFav: boolean = await DataProvider.isTodayCardFavorite(ctx!, card.cardId);
      (card as CardDataWithFavorite).isFavorite = isFav;
      this.cardData = card;
      this.bgColor = this.deriveBgColor(card.primaryColor);
      this.initParticlesFromCard();
    } catch (e) {
      console.error('Refresh card failed');
    }

    // 卡片内容淡入
    animateTo({ duration: 350, curve: Curve.EaseOut }, () => {
      this.cardContentOpacity = 1;
      this.cardContentScale = 1;
    });

    this.isRefreshing = false;
    this.refreshRotate = 0;
  }

  // ---- 动画 ----

  startBreathingAnimation(): void {
    const period: number = 8000;
    const step: () => void = (): void => {
      const now: number = Date.now();
      const p: number = (now % period) / period;
      const rad: number = p * Math.PI * 2;
      this.breatheScale = 1.0 + Math.sin(rad) * 0.02;
      if (this.cardData) {
        this.cardShadowOffsetY = Math.sin(rad) * 2;
      }
      // 降低更新频率：100ms ≈ 10fps，人眼无法察觉呼吸动画的差异
      this.breatheTimer = setTimeout(step, 100);
    };
    step();
  }

  startLightSweepCycle(): void {
    const trigger: () => void = (): void => {
      const interval: number = 10000 + Math.random() * 5000;
      this.lightSweepTimer = setTimeout(() => {
        this.triggerLightSweep();
        trigger();
      }, interval);
    };
    trigger();
  }

  triggerLightSweep(): void {
    const startTime: number = Date.now();
    const duration: number = 1500;
    // 降低帧更新频率：每 50ms 更新一次（20fps）
    const frameInterval: number = 50;
    const animateSweep: () => void = (): void => {
      const elapsed: number = Date.now() - startTime;
      const t: number = Math.min(1, elapsed / duration);
      const eased: number = t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
      this.lightSweepX = -60 + eased * (360 + 120);
      this.lightSweepOpacity = t < 0.15 ? t / 0.15 * 0.6 : t > 0.85 ? (1 - t) / 0.15 * 0.6 : 0.6;
      if (t < 1) {
        setTimeout(animateSweep, frameInterval);
      } else {
        this.lightSweepOpacity = 0;
      }
    };
    animateSweep();
  }

  // ---- 交互处理 ----

  handleTapOutside(event: ClickEvent): void {
    if (this.isCardArea) {
      return;
    }
    const now: number = Date.now();
    if (now - this.lastTapTime < 300) {
      return;
    }
    this.lastTapTime = now;

    // 波纹
    this.rippleCenterX = event.x ?? (this.canvasWidth / 2);
    this.rippleCenterY = event.y ?? (this.canvasHeight / 2);
    this.rippleAnimValue = 0;
    this.showRipple = true;
    if (this.rippleTimer !== -1) {
      clearTimeout(this.rippleTimer);
    }
    const rippleStart: number = Date.now();
    const rippleDuration: number = 600;
    const animateRipple: () => void = (): void => {
      const elapsed: number = Date.now() - rippleStart;
      const t: number = Math.min(1, elapsed / rippleDuration);
      const eased: number = 1 - Math.pow(1 - t, 3);
      this.rippleAnimValue = eased;
      if (t < 1) {
        this.rippleTimer = setTimeout(animateRipple, 16);
      } else {
        this.showRipple = false;
        this.rippleAnimValue = 0;
      }
    };
    animateRipple();

    // 切换哲言
    animateTo({ duration: 200, curve: Curve.EaseIn }, () => {
      this.quoteOpacity = 0;
    });
    setTimeout(() => {
      this.switchQuote();
      animateTo({ duration: 300, curve: Curve.EaseOut }, () => {
        this.quoteOpacity = 1;
      });
    }, 220);
  }

  handleDoubleClick(): void {
    if (!this.cardData) {
      return;
    }
    // 弹跳动画
    this.cardBounceScale = 1.05;
    setTimeout(() => {
      this.cardBounceScale = 0.97;
    }, 150);
    setTimeout(() => {
      this.cardBounceScale = 1.0;
    }, 280);

    // 收藏
    this.showFavoriteStamp = true;
    this.favoriteStampScale = 0;
    animateTo({ duration: 400, curve: Curve.EaseOut }, () => {
      this.favoriteStampScale = 1.0;
    });
    setTimeout(() => {
      animateTo({ duration: 300, curve: Curve.EaseIn }, () => {
        this.favoriteStampScale = 0;
      });
    }, 1200);
    setTimeout(() => {
      this.showFavoriteStamp = false;
    }, 1500);

    const ctx = this.getUIContext().getHostContext();
    DataProvider.saveFavoriteCard(ctx!, this.cardData);
    if (this.cardData) {
      (this.cardData as CardDataWithFavorite).isFavorite = true;
    }
  }

  triggerLongPress(): void {
    if (!this.cardData) {
      return;
    }
    try {
      vibrator.startVibration({
        type: 'time',
        duration: 15
      }, {
        id: 0,
        usage: 'alarm'
      });
    } catch (e) {
      // 震动失败不影响功能
    }
    // 光边效果：临时设置阴影
    const originalY: number = this.cardShadowOffsetY;
    this.cardShadowOffsetY = 0;
    setTimeout(() => {
      this.cardShadowOffsetY = originalY;
    }, 800);
  }

  handleSwipeUp(): void {
    router.pushUrl({ url: 'pages/HistoryPage' });
  }

  handleTouchMove(event: TouchEvent): void {
    if (!this.cardData) {
      return;
    }
    const touch: TouchObject | undefined = event.touches?.[0];
    if (touch) {
      this.isCardArea = (touch.x > 30 && touch.x < 330 && touch.y > 100 && touch.y < 540);
    }
  }

  handleTouchUp(): void {
    this.isCardArea = false;
  }

  // ---- Canvas ----

  initParticlesFromCard(): void {
    if (!this.cardData) {
      return;
    }
    const params: ParticleEngineParams = {
      particleCount: this.cardData.particleCount,
      baseSpeed: this.cardData.particleSpeed,
      gravityDirection: this.cardData.gravityDirection,
      baseOpacity: this.cardData.particleOpacity,
      particleType: this.cardData.particleType,
      primaryColor: this.cardData.particleColor
    };
    this.particleEngine.updateParams(params);
  }

  switchQuote(): void {
    if (!this.cardData) {
      return;
    }
    const currentPeriod: DayPeriod = this.cardData.dayPeriod;
    const periodQuotes = QUOTES_LIBRARY.filter((q) => q.periods.includes(currentPeriod));
    if (periodQuotes.length === 0) {
      return;
    }
    let newIdx: number = Math.floor(Math.random() * periodQuotes.length);
    while (periodQuotes[newIdx].text === this.cardData.quote && periodQuotes.length > 1) {
      newIdx = Math.floor(Math.random() * periodQuotes.length);
    }
    this.cardData.quote = periodQuotes[newIdx].text;
    this.cardData.quoteAuthor = periodQuotes[newIdx].author;
  }

  clearAllTimers(): void {
    if (this.breatheTimer !== -1) {
      clearTimeout(this.breatheTimer);
    }
    if (this.lightSweepTimer !== -1) {
      clearTimeout(this.lightSweepTimer);
    }
    if (this.rippleTimer !== -1) {
      clearTimeout(this.rippleTimer);
    }
  }

  // ---- 登录 ----

  handleLogin(): void {
    this.loginError = '';
    if (this.username.length <= 6) {
      this.loginError = '用户名需大于 6 位';
      this.shakeLoginDialog();
      return;
    }
    if (this.password.length <= 8) {
      this.loginError = '密码需大于 8 位';
      this.shakeLoginDialog();
      return;
    }
    this.animateLoginExit(() => {
      this.showLogin = false;
    });
  }

  animateLoginEnter(): void {
    this.loginDialogOpacity = 0;
    this.loginDialogScale = 0.85;
    animateTo({ duration: 500, curve: Curve.EaseOut }, () => {
      this.loginDialogOpacity = 1;
      this.loginDialogScale = 1.0;
    });
  }

  animateLoginExit(callback: () => void): void {
    animateTo({ duration: 350, curve: Curve.EaseIn }, () => {
      this.loginDialogOpacity = 0;
      this.loginDialogScale = 0.9;
    });
    setTimeout(callback, 360);
  }

  shakeLoginDialog(): void {
    const shakeSeq: number[] = [0, -10, 10, -8, 8, -4, 4, -2, 2, 0];
    let i: number = 0;
    const step: () => void = (): void => {
      if (i < shakeSeq.length) {
        this.loginShakeX = shakeSeq[i];
        i++;
        setTimeout(step, 35);
      }
    };
    step();
  }

  // ---- 工具 ----

  getPeriodGreeting(): string {
    if (!this.cardData) {
      return '';
    }
    switch (this.cardData.dayPeriod) {
      case DayPeriod.MORNING:
        return '早安';
      case DayPeriod.NOON:
        return '午安';
      case DayPeriod.AFTERNOON:
        return '下午好';
      case DayPeriod.NIGHT:
        return '晚安';
      default:
        return '';
    }
  }

  deriveBgColor(primaryHex: string): string {
    const hx: string = primaryHex.replace('#', '');
    const r: number = parseInt(hx.substring(0, 2), 16);
    const g: number = parseInt(hx.substring(2, 4), 16);
    const b: number = parseInt(hx.substring(4, 6), 16);
    const max: number = Math.max(r, g, b);
    const blend: number = max > 128 ? 0.45 : 0.55;
    const dr: number = Math.round(r * blend + 8);
    const dg: number = Math.round(g * blend + 8);
    const db: number = Math.round(b * blend + 8);
    const fmt: (n: number) => string = (n: number): string => n.toString(16).padStart(2, '0');
    return `#${fmt(dr)}${fmt(dg)}${fmt(db)}`;
  }

  deriveBgColorTop(bgHex: string): string {
    const hx: string = bgHex.replace('#', '');
    const r: number = Math.min(255, parseInt(hx.substring(0, 2), 16) + 30);
    const g: number = Math.min(255, parseInt(hx.substring(2, 4), 16) + 30);
    const b: number = Math.min(255, parseInt(hx.substring(4, 6), 16) + 30);
    const fmt: (n: number) => string = (n: number): string => n.toString(16).padStart(2, '0');
    return `#${fmt(r)}${fmt(g)}${fmt(b)}`;
  }

  build() {
    Stack() {
      // 粒子 Canvas
      Canvas(this.canvasContext)
        .width('100%')
        .height('100%')
        .onReady(() => {
          this.canvasWidth = this.canvasContext.width;
          this.canvasHeight = this.canvasContext.height;
          if (this.cardData) {
            this.initParticlesFromCard();
          }
          this.particleEngine.startAnimation(this.canvasContext);
        })

      // 毛玻璃卡片
      if (this.cardData) {
        Column() {
          Stack() {
            // 光掠过动画
            if (this.lightSweepOpacity > 0.01) {
              Column()
                .position({ x: this.lightSweepX, y: -10 })
                .width(60)
                .height(120)
                .borderRadius(30)
                .linearGradient({
                  direction: GradientDirection.Right,
                  colors: [
                    ['rgba(255,255,255,0)', 0],
                    [`rgba(255,255,255,${this.lightSweepOpacity})`, 0.5],
                    ['rgba(255,255,255,0)', 1]
                  ]
                })
            }

            // 卡片内容
            Column() {
              // 问候语
              Text(this.getPeriodGreeting())
                .fontSize(28)
                .fontWeight(200)
                .fontFamily('HarmonyOS Sans Thin')
                .fontColor(this.cardData.textColor)
                .margin({ top: 24, bottom: 8 })

              // 日期
              Text(this.cardData.dateStr)
                .fontSize(12)
                .fontColor('rgba(255,255,255,0.4)')
                .margin({ bottom: 20 })

              // 温度 & 步数
              Row() {
                Column() {
                  Text(this.cardData.temperatureStr)
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.45)')
                  Text(this.cardData.weather.description)
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.5)')
                }
                .alignItems(HorizontalAlign.Start)

                Blank()

                Column() {
                  Text(`${this.cardData.steps} 步`)
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.45)')
                  Text('今日步数')
                    .fontSize(12)
                    .fontColor('rgba(255,255,255,0.5)')
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .margin({ bottom: 20 })

              Blank()

              // 哲言
              Column() {
                Text(this.cardData.quote)
                  .fontSize(16)
                  .fontWeight(300)
                  .fontColor(this.cardData.textColor)
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .opacity(this.quoteOpacity)
                  .margin({ bottom: 6 })

                Text(`—— ${this.cardData.quoteAuthor}`)
                  .fontSize(12)
                  .fontColor('rgba(255,255,255,0.35)')
                  .textAlign(TextAlign.Center)
                  .width('100%')
                  .opacity(this.quoteOpacity)
              }

              Blank()
            }
            .width('100%')
            .height('100%')
            .padding(24)

            // 收藏图标
            if (this.cardData && (this.cardData as CardDataWithFavorite).isFavorite) {
              SymbolGlyph($r('sys.symbol.heart_fill'))
                .fontSize(16)
                .fontColor(['#ff6b8a'])
                .position({ x: '100%', y: 16 })
                .translate({ x: -36 })
            }

            // 收藏邮票动画
            if (this.showFavoriteStamp) {
              Column() {
                SymbolGlyph($r('sys.symbol.star_fill'))
                  .fontSize(36)
                  .fontColor(['#FFD700'])
              }
              .width(50)
              .height(50)
              .borderRadius(25)
              .backgroundColor('rgba(255,215,0,0.2)')
              .border({ width: 1, color: 'rgba(255,215,0,0.6)' })
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .scale({ x: this.favoriteStampScale, y: this.favoriteStampScale })
            }
          }
          .width('100%')
          .height('100%')

          // 长按提示
          Text('长按收藏 | 双击分享')
            .fontSize(10)
            .fontColor('rgba(255,255,255,0.25)')
            .margin({ top: 8 })
        }
        .width('85%')
        .height('55%')
        .borderRadius(Constants.CARD_BORDER_RADIUS)
        .backdropBlur(12) // 从 20 降至 12，降低 GPU 模糊采样
        .backgroundColor(this.cardData.cardBgColor)
        .border({ width: 0.5, color: 'rgba(255,255,255,0.15)' })
        .shadow({
          radius: 20,
          color: this.cardData.glowColor,
          offsetX: 0,
          offsetY: this.cardShadowOffsetY,
          fill: false
        })
        .scale({
          x: this.breatheScale * this.cardBounceScale * this.cardContentScale,
          y: this.breatheScale * this.cardBounceScale * this.cardContentScale
        })
        .opacity(this.cardContentOpacity)
        .animation({ duration: 150, curve: Curve.EaseInOut })
        .onClick(() => {
          const now: number = Date.now();
          if (now - this.lastTapTime < 400) {
            this.handleDoubleClick();
            this.lastTapTime = 0;
          } else {
            this.lastTapTime = now;
          }
        })
        .gesture(
          LongPressGesture({ repeat: false, duration: 600 })
            .onAction(() => {
              this.triggerLongPress();
            })
        )
      }

      // 波纹
      if (this.showRipple) {
        Circle()
          .position({
            x: this.rippleCenterX - 10 - this.rippleAnimValue * 150,
            y: this.rippleCenterY - 10 - this.rippleAnimValue * 150
          })
          .width(20 + this.rippleAnimValue * 300)
          .height(20 + this.rippleAnimValue * 300)
          .fill('rgba(255,255,255,0)')
          .stroke(`rgba(255,255,255,${0.4 * (1 - this.rippleAnimValue)})`)
          .strokeWidth(1.5 * (1 - this.rippleAnimValue))
      }

      // 加载指示器
      if (this.isLoading) {
        LoadingProgress()
          .width(40)
          .height(40)
          .color('#ffffff')
      }

      // 换一张按钮
      Button() {
        SymbolGlyph($r('sys.symbol.arrow_2_circlepath'))
          .fontSize(20)
          .fontColor(['rgba(255,255,255,0.7)'])
          .rotate({ angle: this.refreshRotate })
          .animation({ duration: 400, curve: Curve.EaseOut })
      }
      .width(40)
      .height(40)
      .borderRadius(20)
      .backgroundColor('rgba(255,255,255,0.1)')
      .backdropBlur(6) // 降低按钮模糊
      .position({ x: '100%', y: 50 })
      .translate({ x: -56 })
      .enabled(!this.isRefreshing)
      .onClick(() => {
        this.refreshCard();
      })

      // -- 登录弹窗 --
      if (this.showLogin) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor('rgba(0,0,0,0.65)')
            .backdropBlur(4) // 降低遮罩模糊
            .onClick(() => {})
            .opacity(this.loginDialogOpacity)
            .animation({ duration: 400, curve: Curve.EaseOut })

          Column() {
            Text('浮光')
              .fontSize(28)
              .fontWeight(200)
              .fontFamily('HarmonyOS Sans Thin')
              .fontColor('rgba(255,255,255,0.9)')
              .margin({ bottom: 4 })

            Text('每日动态艺术卡片')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.4)')
              .margin({ bottom: 28 })

            TextInput({ placeholder: '用户名（大于6位）', text: this.username })
              .placeholderColor('rgba(255,255,255,0.25)')
              .placeholderFont({ size: 13 })
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.85)')
              .backgroundColor('rgba(255,255,255,0.06)')
              .borderRadius(10)
              .height(44)
              .padding({ left: 14, right: 14 })
              .caretColor('rgba(255,255,255,0.5)')
              .onChange((value: string) => {
                this.username = value;
                this.loginError = '';
              })
              .border({
                width: this.username.length > 0 && this.username.length <= 6 ? 1 : 0,
                color: '#ff6b6b'
              })
              .width('100%')
              .margin({ bottom: 12 })

            TextInput({ placeholder: '密码（大于8位）', text: this.password })
              .type(InputType.Password)
              .placeholderColor('rgba(255,255,255,0.25)')
              .placeholderFont({ size: 13 })
              .fontSize(14)
              .fontColor('rgba(255,255,255,0.85)')
              .backgroundColor('rgba(255,255,255,0.06)')
              .borderRadius(10)
              .height(44)
              .padding({ left: 14, right: 14 })
              .caretColor('rgba(255,255,255,0.5)')
              .onChange((value: string) => {
                this.password = value;
                this.loginError = '';
              })
              .border({
                width: this.password.length > 0 && this.password.length <= 8 ? 1 : 0,
                color: '#ff6b6b'
              })
              .width('100%')
              .margin({ bottom: 4 })

            if (this.loginError.length > 0) {
              Text(this.loginError)
                .fontSize(12)
                .fontColor('#ff6b6b')
                .margin({ top: 4, bottom: 8 })
                .width('100%')
                .textAlign(TextAlign.Start)
                .padding({ left: 4 })
                .transition({ type: TransitionType.Insert, opacity: 0, translate: { y: -8 } })
            } else {
              Blank().height(28)
            }

            Button('进入浮光')
              .width('100%')
              .height(44)
              .fontSize(15)
              .fontWeight(400)
              .fontColor('#ffffff')
              .borderRadius(22)
              .backgroundColor(
                this.loginButtonScale < 1 ? 'rgba(255,255,255,0.2)' : 'rgba(255,255,255,0.12)'
              )
              .backdropBlur(4)
              .border({ width: 0.5, color: 'rgba(255,255,255,0.2)' })
              .scale({ x: this.loginButtonScale, y: this.loginButtonScale })
              .onClick(() => {
                this.handleLogin();
              })
              .onTouch((event: TouchEvent) => {
                if (event.type === TouchType.Down) {
                  this.loginButtonScale = 0.95;
                } else {
                  this.loginButtonScale = 1.0;
                }
              })
          }
          .width('78%')
          .padding({ left: 24, right: 24, top: 36, bottom: 28 })
          .borderRadius(20)
          .backgroundColor('rgba(255,255,255,0.06)')
          .backdropBlur(12) // 从 20 降至 12
          .border({ width: 0.5, color: 'rgba(255,255,255,0.12)' })
          .shadow({
            radius: 30,
            color: 'rgba(0,0,0,0.5)',
            offsetX: 0,
            offsetY: 8,
            fill: false
          })
          .opacity(this.loginDialogOpacity)
          .scale({ x: this.loginDialogScale, y: this.loginDialogScale })
          .translate({ x: this.loginShakeX })
          .animation({ duration: 350, curve: Curve.EaseOut })
        }
        .width('100%')
        .height('100%')
      }
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      direction: GradientDirection.RightBottom,
      colors: [
        [this.deriveBgColorTop(this.bgColor), 0.0],
        [this.bgColor, 1.0]
      ]
    })
    .animation({ duration: 600, curve: Curve.EaseInOut })
    .onClick((event: ClickEvent) => {
      this.handleTapOutside(event);
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Move) {
        this.handleTouchMove(event);
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.handleTouchUp();
      }
    })
    .gesture(
      PanGesture({ direction: PanDirection.Up, distance: 80 })
        .onActionEnd(() => {
          this.handleSwipeUp();
        })
    )
  }
}
