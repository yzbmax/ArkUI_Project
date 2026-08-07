import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * SettingItem.ets
 * 设置项（图标 + 标题 + 副标题 + 右侧内容/箭头/开关）
 */
@Component
export struct SettingItem {
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop icon: string = '';
  @Prop showArrow: boolean = false;
  @Prop switchValue: boolean = false;
  @Prop showSwitch: boolean = false;
  @Prop rightText: string = '';
  onSwitchChange: (value: boolean) => void = () => {};
  onClickItem: () => void = () => {};

  build() {
    Row({ space: DesignSpacing.MD }) {
      if (this.icon.length > 0) {
        Text(this.icon)
          .fontSize(DesignTypography.SIZE_TITLE)
          .width(28)
          .height(28)
          .textAlign(TextAlign.Center)
      }
      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(DesignTypography.SIZE_BODY)
          .fontColor(ThemeManager.textPrimary())
          .maxLines(1)
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(DesignTypography.SIZE_LABEL)
            .fontColor(ThemeManager.textTertiary())
            .maxLines(1)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      if (this.showSwitch) {
        Toggle({ type: ToggleType.Switch, isOn: this.switchValue })
          .selectedColor(ThemeManager.accent())
          .onChange((isOn: boolean) => {
            this.onSwitchChange(isOn);
          })
      } else if (this.rightText.length > 0) {
        Text(this.rightText)
          .fontSize(DesignTypography.SIZE_BODY_SM)
          .fontColor(ThemeManager.textTertiary())
      }

      if (this.showArrow) {
        Text('›')
          .fontSize(22)
          .fontColor(ThemeManager.textTertiary())
      }
    }
    .width('100%')
    .padding({
      left: DesignSpacing.LG,
      right: DesignSpacing.LG,
      top: 14,
      bottom: 14,
    })
    .backgroundColor(ThemeManager.card())
    .borderRadius(DesignRadius.MD)
    .onClick(() => this.onClickItem())
  }
}
