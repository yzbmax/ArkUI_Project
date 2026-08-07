import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * StatCard.ets
 * 看板统计卡片（数字 + 标签，纯色圆底 + 柔和标题）
 */
@Component
export struct StatCard {
  @Prop label: string = '';
  @Prop value: string = '0';
  @Prop icon: string = '📊';
  @Prop valueColor: string = '';
  @Prop accentColor: string = '';

  build() {
    Column({ space: DesignSpacing.SM }) {
      Row({ space: DesignSpacing.XS }) {
        Text(this.icon)
          .fontSize(DesignTypography.SIZE_CAPTION)
        Text(this.label)
          .fontSize(DesignTypography.SIZE_LABEL)
          .fontColor(ThemeManager.textTertiary())
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')

      Text(this.value)
        .fontFamily(DesignTypography.FONT_MONO)
        .fontSize(DesignTypography.SIZE_H2)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.valueColor.length > 0 ? this.valueColor : ThemeManager.textPrimary())
        .maxLines(1)
    }
    .width('100%')
    .padding(DesignSpacing.LG)
    .backgroundColor(ThemeManager.card())
    .borderRadius(DesignRadius.LG)
    .alignItems(HorizontalAlign.Start)
  }
}
