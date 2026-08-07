import { DesignSpacing, DesignTypography } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * TimeFilterBar.ets
 * 时间范围筛选（7天 / 30天 / 90天 / 全部）
 */
@Component
export struct TimeFilterBar {
  @Prop options: string[] = ['近7天', '近30天', '近90天', '全部'];
  @Prop selectedIndex: number = 1;
  onSelect: (index: number) => void = () => {};

  build() {
    Row({ space: DesignSpacing.SM }) {
      ForEach(this.options, (item: string, index: number) => {
        Text(item)
          .fontSize(DesignTypography.SIZE_BODY_SM)
          .fontColor(index === this.selectedIndex ? ThemeManager.card() : ThemeManager.textPrimary())
          .fontWeight(index === this.selectedIndex ? FontWeight.Medium : FontWeight.Normal)
          .padding({
            left: DesignSpacing.MD,
            right: DesignSpacing.MD,
            top: 6,
            bottom: 6,
          })
          .backgroundColor(index === this.selectedIndex ? ThemeManager.textPrimary() : ThemeManager.surface())
          .borderRadius(DesignSpacing.XS)
          .onClick(() => this.onSelect(index))
      }, (item: string) => item)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
