/**
 * AppCard —— 无边框卡片（P02）
 * 浅色/深色双主题，可选唯一柔和阴影；通过 @BuilderParam 传入内容，onTap 支持整卡点击。
 * 注意：@Prop 名不可与组件内置属性（padding/shadow）重名，故用 pad / withShadow。
 */
import { Colors, Space, CardShadow, Radius } from '../theme/AppTheme';

@Component
export struct AppCard {
  @Prop dark: boolean = false;
  @Prop withShadow: boolean = false;
  @Prop pad: number = Space.md;
  @Prop radius: number = Radius.card;
  @Prop cardWidth: string = '100%';
  @BuilderParam content: () => void = this.defaultContent;
  onTap?: () => void = undefined;

  @Builder
  defaultContent() {
  }

  build() {
    Column() {
      this.content();
    }
    .width(this.cardWidth)
    .padding(this.pad)
    .borderRadius(this.radius)
    .backgroundColor(this.dark ? Colors.darkSurface : Colors.white)
    .shadow(this.withShadow
      ? { radius: CardShadow.radius, color: CardShadow.color, offsetX: CardShadow.offsetX, offsetY: CardShadow.offsetY }
      : undefined)
    .onClick(() => {
      if (this.onTap) {
        this.onTap();
      }
    });
  }
}
