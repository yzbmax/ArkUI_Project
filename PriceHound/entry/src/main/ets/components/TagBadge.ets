import { DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * TagBadge.ets
 * 标签徽章（柔色底 + 深色文字）
 */
@Component
export struct TagBadge {
  @Prop text: string = '';
  @Prop color: string = '';
  @Prop small: boolean = false;

  private resolveColor(): string {
    return this.color.length > 0 ? this.color : ThemeManager.accent();
  }

  private bgColor(): string {
    // 将主色转为柔化背景（叠加透明度）
    return this.resolveColor() + '22';
  }

  build() {
    Text(this.text)
      .fontSize(this.small ? DesignTypography.SIZE_LABEL : DesignTypography.SIZE_CAPTION)
      .fontColor(this.resolveColor())
      .fontWeight(FontWeight.Medium)
      .padding({
        left: this.small ? 6 : 10,
        right: this.small ? 6 : 10,
        top: this.small ? 2 : 4,
        bottom: this.small ? 2 : 4,
      })
      .backgroundColor(this.bgColor())
      .borderRadius(this.small ? 6 : DesignRadius.SM)
  }
}
