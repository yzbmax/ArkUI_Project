/**
 * PillLink —— 胶囊文字链
 * 对应 DESIGN.md 980px 胶囊：透明底 + 蓝边 + 蓝字（ButtonType.Capsule）。
 * ButtonType 为 ArkUI 全局枚举，无需 import。
 */
import { Colors, Font } from '../theme/AppTheme';

@Component
export struct PillLink {
  @Prop label: string = '';
  onPress?: () => void = undefined;

  build() {
    Button(this.label, { type: ButtonType.Capsule })
      .backgroundColor(Color.Transparent)
      .border({ width: 1, color: Colors.linkBlue })
      .fontColor(Colors.linkBlue)
      .fontSize(Font.link.size)
      .fontWeight(Font.body.weight)
      .padding({ left: 16, right: 16, top: 8, bottom: 8 })
      .onClick(() => {
        if (this.onPress) {
          this.onPress();
        }
      });
  }
}
