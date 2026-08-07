import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { SettingItem } from '../components/SettingItem';
import { RouterUtil } from '../utils/RouterUtil';
import { AppConfig } from '../constants/AppConstants';
import { getRepo } from '../repository/DataRepository';
import { DashboardViewModel } from '../viewmodel/DashboardViewModel';
import { PriceUtil } from '../utils/PriceUtil';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * ProfilePage.ets
 * 我的页：个人信息卡 + 数据统计 + 设置分组入口
 */
@Component
export struct ProfilePage {
  @State refreshKey: number = 0;
  @StorageProp('theme.isDark') isDark: boolean = false;

  private monitoredCount(): number {
    return getRepo().products.length;
  }

  build() {
    Scroll() {
      Column({ space: DesignSpacing.XL }) {
        // ===== 个人信息卡 =====
        Row({ space: DesignSpacing.LG }) {
          Text('🐶')
            .fontSize(44)
            .width(64)
            .height(64)
            .textAlign(TextAlign.Center)
            .backgroundColor(ThemeManager.surface())
            .borderRadius(DesignRadius.XL)
          Column({ space: 4 }) {
            Text('价格侦探')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H2)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
            Text('用 PriceHound 盯住每一次降价')
              .fontSize(DesignTypography.SIZE_CAPTION)
              .fontColor(ThemeManager.textTertiary())
          }
          .alignItems(HorizontalAlign.Start)
          Blank()
        }
        .width('100%')
        .padding(DesignSpacing.XL)
        .backgroundColor(ThemeManager.card())
        .borderRadius(DesignRadius.LG)

        // ===== 统计 =====
        Row() {
          this.statCell(`${this.monitoredCount()}`, '监控商品')
          this.statCell(PriceUtil.format(DashboardViewModel.computeStats().totalSaved), '累计节省')
          this.statCell(`${DashboardViewModel.computeStats().todayChanges}`, '今日变动')
        }
        .width('100%')
        .padding(DesignSpacing.LG)
        .backgroundColor(ThemeManager.card())
        .borderRadius(DesignRadius.LG)

        // ===== 设置分组 =====
        Column({ space: DesignSpacing.MD }) {
          Text('数据与管理')
            .fontSize(DesignTypography.SIZE_OVERLINE)
            .fontColor(ThemeManager.textTertiary())
            .width('100%')
          SettingItem({
            icon: '🛒',
            title: '添加商品',
            subtitle: '链接 / 搜索 / 手动添加',
            showArrow: true,
            onClickItem: () => RouterUtil.push('pages/AddProductPage'),
          })
          SettingItem({
            icon: '🔄',
            title: '监控设置',
            subtitle: '刷新频率 / 数据源 / 省电',
            showArrow: true,
            onClickItem: () => RouterUtil.push('pages/MonitorSettingPage'),
          })
          SettingItem({
            icon: '💾',
            title: '导出数据',
            subtitle: 'CSV / JSON 格式',
            showArrow: true,
            onClickItem: () => RouterUtil.push('pages/ExportPage'),
          })
          SettingItem({
            icon: '📦',
            title: '备份与恢复',
            subtitle: '本地备份 / 还原',
            showArrow: true,
            onClickItem: () => RouterUtil.push('pages/BackupRestorePage'),
          })
        }
        .width('100%')

        Column({ space: DesignSpacing.MD }) {
          Text('提醒与外观')
            .fontSize(DesignTypography.SIZE_OVERLINE)
            .fontColor(ThemeManager.textTertiary())
            .width('100%')
          SettingItem({
            icon: '🔔',
            title: '通知设置',
            subtitle: '声音 / 震动 / 免打扰',
            showArrow: true,
            onClickItem: () => RouterUtil.push('pages/NotificationSettingPage'),
          })
          SettingItem({
            icon: '🎨',
            title: '外观设置',
            subtitle: '深色模式 / 显示偏好',
            showArrow: true,
            onClickItem: () => RouterUtil.push('pages/AppearanceSettingPage'),
          })
        }
        .width('100%')

        Column({ space: DesignSpacing.MD }) {
          Text('关于')
            .fontSize(DesignTypography.SIZE_OVERLINE)
            .fontColor(ThemeManager.textTertiary())
            .width('100%')
          SettingItem({
            icon: 'ℹ️',
            title: '关于 PriceHound',
            subtitle: `版本 ${AppConfig.VERSION}`,
            showArrow: true,
            onClickItem: () => RouterUtil.push('pages/AboutPage'),
          })
        }
        .width('100%')

        Blank().height(72)
      }
      .width('100%')
      .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.LG })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.bg())
    .scrollBar(BarState.Off)
  }

  @Builder
  statCell(value: string, label: string) {
    Column({ space: 2 }) {
      Text(value)
        .fontFamily(DesignTypography.FONT_MONO)
        .fontSize(DesignTypography.SIZE_PRICE_SM)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeManager.textPrimary())
      Text(label)
        .fontSize(DesignTypography.SIZE_LABEL)
        .fontColor(ThemeManager.textTertiary())
    }
    .layoutWeight(1)
  }
}
