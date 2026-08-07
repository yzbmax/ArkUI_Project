import { DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * CategoryChip.ets
 * 分类筛选胶囊（选中=主色底白字，未选中=次级底主色字）
 */
@Component
export struct CategoryChip {
  @Prop label: string = '';
  @Prop icon: string = '';
  @Prop selected: boolean = false;
  onClickChip: () => void = () => {};

  build() {
    Row({ space: 5 }) {
      Text(this.icon)
        .fontSize(DesignTypography.SIZE_CAPTION)
        .fontColor(this.selected ? Color.White : ThemeManager.textPrimary())
      Text(this.label)
        .fontSize(DesignTypography.SIZE_BODY_SM)
        .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(this.selected ? Color.White : ThemeManager.textPrimary())
    }
    .padding({
      left: DesignRadius.MD,
      right: DesignRadius.MD,
      top: 8,
      bottom: 8,
    })
    .backgroundColor(this.selected ? ThemeManager.accent() : ThemeManager.surface())
    .borderRadius(DesignRadius.XL)
    .onClick(() => this.onClickChip())
  }
}
