import { MotionDuration, MotionCurve, MotionDistance } from '../constants/MotionTokens';
import { DesignRadius } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * AnimatedCard.ets
 * 通用卡片容器：按压反馈（缩放）+ 入场动画（上移淡入）+ 柔和圆角
 * 用于列表项 / 卡片式入口，统一交互动效
 */
@Component
export struct AnimatedCard {
  /** 是否显示入场动画（列表出现时渐进） */
  @Prop animateIn: boolean = true;
  /** 入场延迟（用于列表错峰，单位 ms） */
  @Prop delayMs: number = 0;
  /** 卡片背景色 */
  @Prop bgColor: string = '';
  @State pressed: boolean = false;
  @State entered: boolean = false;

  aboutToAppear(): void {
    if (this.animateIn && this.delayMs > 0) {
      setTimeout(() => {
        this.entered = true;
      }, this.delayMs);
    } else {
      this.entered = true;
    }
  }

  @Builder
  slotBuilder() {}

  build() {
    Column() {
      this.slotBuilder()
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.bgColor.length > 0 ? this.bgColor : ThemeManager.card())
    .borderRadius(DesignRadius.LG)
    .scale({ x: this.pressed ? 0.98 : 1, y: this.pressed ? 0.98 : 1 })
    .opacity(this.entered ? 1 : 0)
    .translate({ y: this.entered ? 0 : MotionDistance.ITEM })
    .animation({
      duration: MotionDuration.BASE,
      curve: MotionCurve.EASE_SPRING,
      delay: 0,
    })
    .onTouch((event: TouchEvent) => {
      if (event.type === TouchType.Down) {
        this.pressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.pressed = false;
      }
    })
  }
}
