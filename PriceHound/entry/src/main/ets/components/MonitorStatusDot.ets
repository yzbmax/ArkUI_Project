import { DesignTypography } from '../constants/DesignTokens';
import { monitorStatusName, monitorStatusIcon, MonitorStatus } from '../model/Product';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * MonitorStatusDot.ets
 * 监控状态标签（圆点 + 文案）
 */
@Component
export struct MonitorStatusDot {
  @Prop status: number = MonitorStatus.NORMAL;

  private getColor(): string {
    switch (this.status) {
      case MonitorStatus.NORMAL:
        return ThemeManager.ok();
      case MonitorStatus.WARN:
        return ThemeManager.warn();
      case MonitorStatus.ERROR:
        return ThemeManager.rise();
      default:
        return ThemeManager.textTertiary();
    }
  }

  build() {
    Row({ space: 5 }) {
      Text('●')
        .fontSize(9)
        .fontColor(this.getColor())
      Text(monitorStatusIcon.get(this.status) ?? '')
        .fontSize(DesignTypography.SIZE_LABEL)
      Text(monitorStatusName.get(this.status) ?? '')
        .fontSize(DesignTypography.SIZE_LABEL)
        .fontColor(ThemeManager.textTertiary())
    }
    .alignItems(VerticalAlign.Center)
  }
}
