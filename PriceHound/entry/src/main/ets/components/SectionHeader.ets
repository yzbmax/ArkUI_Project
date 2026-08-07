import { DesignSpacing, DesignTypography } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * SectionHeader.ets
 * 页面分区标题（衬线标题 + 可选"查看全部"）
 */
@Component
export struct SectionHeader {
  @Prop title: string = '';
  @Prop moreText: string = '';
  moreClick: () => void = () => {};

  build() {
    Row() {
      Text(this.title)
        .fontFamily(DesignTypography.FONT_SERIF)
        .fontSize(DesignTypography.SIZE_H3)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeManager.textPrimary())
      Blank()
      if (this.moreText.length > 0) {
        Text(this.moreText)
          .fontSize(DesignTypography.SIZE_BODY_SM)
          .fontColor(ThemeManager.accent())
          .onClick(() => this.moreClick())
      }
    }
    .width('100%')
    .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
  }
}
