/**
 * GlassNavBar —— 玻璃标题栏
 * 半透明深色 + blur 近似 DESIGN.md backdrop-filter（PRD 第 4.5 章）。
 * 高度 48vp；标题白字；支持返回按钮与右侧操作文字。
 */
import { Colors, Font, NavHeight, Space } from '../theme/AppTheme';

@Component
export struct GlassNavBar {
  @Prop title: string = '';
  @Prop showBack: boolean = false;
  @Prop rightText: string = '';
  onBack?: () => void = undefined;
  onRight?: () => void = undefined;

  build() {
    // Stack：底层模糊背景（玻璃），上层清晰文字，避免文字被 blur 糊掉
    Stack({ alignContent: Alignment.Center }) {
      // 背景层：半透明深色 + blur 近似 DESIGN backdrop-filter（不影响前景文字）
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(Colors.navBarBg)
        .blur(20);

      // 前景内容层：清晰标题/返回/右侧操作
      Row() {
        if (this.showBack) {
          Text('‹')
            .fontSize(28)
            .fontColor(Colors.white)
            .width(32)
            .height(32)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              if (this.onBack) {
                this.onBack();
              }
            });
        }
        Text(this.title)
          .fontSize(Font.caption.size)
          .fontWeight(FontWeight.Regular)
          .fontColor(Colors.white)
          .letterSpacing(Font.caption.letterSpacing)
          .layoutWeight(1)
          .textAlign(this.showBack ? TextAlign.Start : TextAlign.Center);
        if (this.rightText) {
          Text(this.rightText)
            .fontSize(Font.caption.size)
            .fontColor(Colors.brightBlue)
            .onClick(() => {
              if (this.onRight) {
                this.onRight();
              }
            });
        }
      }
      .width('100%')
      .height('100%')
      .padding({ left: Space.md, right: Space.md })
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .height(NavHeight);
  }
}
