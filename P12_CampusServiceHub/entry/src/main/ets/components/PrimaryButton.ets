/**
 * PrimaryButton —— Apple Blue 主 CTA
 * type: 0 = Apple Blue 主按钮，1 = 深色次级按钮；disabled 时置灰禁用。
 * ButtonType 为 ArkUI 全局枚举，无需 import。
 */
import { Colors, Font, Radius } from '../theme/AppTheme';

@Component
export struct PrimaryButton {
  @Prop label: string = '';
  @Prop disabled: boolean = false;
  @Prop type: number = 0; // 0 blue, 1 dark
  onPress?: () => void = undefined;

  build() {
    Button(this.label, { type: ButtonType.Normal })
      .width('100%')
      .height(48)
      .borderRadius(Radius.cta)
      .backgroundColor(this.disabled
        ? Colors.textTertiary
        : (this.type === 1 ? Colors.textDark : Colors.blue))
      .fontColor(Colors.white)
      .fontSize(Font.body.size)
      .fontWeight(Font.bodyEmphasis.weight)
      .enabled(!this.disabled)
      .onClick(() => {
        if (this.onPress && !this.disabled) {
          this.onPress();
        }
      });
  }
}
