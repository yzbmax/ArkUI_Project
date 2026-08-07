import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * EmptyState.ets
 * 空状态占位（暖色调，图标 + 标题 + 副文案 + 可选动作按钮）
 */
@Component
export struct EmptyState {
  @Prop icon: string = '📦';
  @Prop title: string = '暂无数据';
  @Prop subtitle: string = '这里还空空如也';
  @Prop actionText: string = '';
  actionClick: () => void = () => {};

  build() {
    Column({ space: DesignSpacing.MD }) {
      Text(this.icon)
        .fontSize(56)
        .opacity(0.8)
      Text(this.title)
        .fontFamily(DesignTypography.FONT_SERIF)
        .fontSize(DesignTypography.SIZE_H3)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeManager.textPrimary())
      Text(this.subtitle)
        .fontSize(DesignTypography.SIZE_BODY_SM)
        .fontColor(ThemeManager.textTertiary())
        .textAlign(TextAlign.Center)
      if (this.actionText.length > 0) {
        Button(this.actionText)
          .fontSize(DesignTypography.SIZE_BODY)
          .fontColor(ThemeManager.textPrimary())
          .backgroundColor(ThemeManager.surface())
          .borderRadius(DesignRadius.MD)
          .height(44)
          .margin({ top: DesignSpacing.SM })
          .onClick(() => this.actionClick())
      }
    }
    .width('100%')
    .padding({ top: 60, bottom: 60, left: DesignSpacing.XL, right: DesignSpacing.XL })
    .justifyContent(FlexAlign.Center)
  }
}
