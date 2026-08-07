import { DesignSpacing } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * LoadingOverlay.ets
 * 全屏加载遮罩（暖色旋转圈 + 文案）
 */
@Component
export struct LoadingOverlay {
  @Prop loading: boolean = false;
  @Prop text: string = '加载中…';

  build() {
    if (this.loading) {
      Stack() {
        Column({ space: DesignSpacing.MD }) {
          LoadingProgress()
            .width(40)
            .height(40)
            .color(ThemeManager.accent())
          Text(this.text)
            .fontSize(14)
            .fontColor(ThemeManager.textSecondary())
        }
        .padding(DesignSpacing.XL)
        .backgroundColor(ThemeManager.card())
        .borderRadius(16)
      }
      .width('100%')
      .height('100%')
      .backgroundColor(ThemeManager.isDark() ? 'rgba(0,0,0,0.45)' : 'rgba(20,20,19,0.15)')
      .zIndex(99)
    }
  }
}
