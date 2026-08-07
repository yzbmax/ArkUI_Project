import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { ToastUtil } from '../components/Toast';
import { RouterUtil } from '../utils/RouterUtil';
import { SettingItem } from '../components/SettingItem';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * NotificationSettingPage.ets
 * 通知设置页：开关 / 声音 / 震动 / 每日简报 / 免打扰时段
 */
@Entry
@Component
export struct NotificationSettingPage {
  @StorageProp('theme.isDark') isDark: boolean = false;
  @State notifyEnabled: boolean = true;
  @State soundEnabled: boolean = true;
  @State vibrateEnabled: boolean = true;
  @State reportEnabled: boolean = true;
  @State dndEnabled: boolean = false;

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor(ThemeManager.textPrimary())
          .width(36)
          .onClick(() => RouterUtil.back())
        Text('通知设置')
          .fontFamily(DesignTypography.FONT_SERIF)
          .fontSize(DesignTypography.SIZE_TITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeManager.textPrimary())
        Blank()
        Blank().width(36)
      }
      .width('100%')
      .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.MD, bottom: DesignSpacing.MD })

      Scroll() {
        Column({ space: DesignSpacing.XL }) {
          // ===== 基础 =====
          Column({ space: DesignSpacing.MD }) {
            Text('通知')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')
            SettingItem({
              icon: '🔔',
              title: '启用降价提醒',
              subtitle: '商品降价时发送通知',
              showSwitch: true,
              switchValue: this.notifyEnabled,
              onSwitchChange: (v: boolean) => {
                this.notifyEnabled = v;
              },
            })
            SettingItem({
              icon: '🔊',
              title: '提醒声音',
              subtitle: '通知时播放提示音',
              showSwitch: true,
              switchValue: this.soundEnabled,
              onSwitchChange: (v: boolean) => {
                this.soundEnabled = v;
              },
            })
            SettingItem({
              icon: '📳',
              title: '震动',
              subtitle: '通知时震动',
              showSwitch: true,
              switchValue: this.vibrateEnabled,
              onSwitchChange: (v: boolean) => {
                this.vibrateEnabled = v;
              },
            })
          }
          .width('100%')

          // ===== 简报 =====
          Column({ space: DesignSpacing.MD }) {
            Text('每日简报')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')
            SettingItem({
              icon: '📰',
              title: '每日价格简报',
              subtitle: '每天 8:00 汇总价格变动',
              showSwitch: true,
              switchValue: this.reportEnabled,
              onSwitchChange: (v: boolean) => {
                this.reportEnabled = v;
              },
            })
            SettingItem({
              icon: '🕗',
              title: '简报时间',
              rightText: '08:00',
              showArrow: true,
              onClickItem: () => {
                ToastUtil.show('简报时间暂仅支持 08:00');
              },
            })
          }
          .width('100%')

          // ===== 免打扰 =====
          Column({ space: DesignSpacing.MD }) {
            Text('免打扰')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')
            SettingItem({
              icon: '🌙',
              title: '免打扰模式',
              subtitle: '23:00 - 07:00 静音',
              showSwitch: true,
              switchValue: this.dndEnabled,
              onSwitchChange: (v: boolean) => {
                this.dndEnabled = v;
              },
            })
          }
          .width('100%')

          // ===== 测试按钮 =====
          Button('发送测试通知')
            .width('100%')
            .height(46)
            .fontSize(DesignTypography.SIZE_BODY)
            .fontColor(ThemeManager.textPrimary())
            .backgroundColor(ThemeManager.surface())
            .borderRadius(DesignRadius.MD)
            .onClick(() => {
              if (!this.notifyEnabled) {
                ToastUtil.show('通知已关闭，请先开启');
                return;
              }
              ToastUtil.show('🔔 测试通知已发送');
            })

          Blank().height(40)
        }
        .width('100%')
        .padding({ top: DesignSpacing.MD, left: DesignSpacing.LG, right: DesignSpacing.LG })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.bg())
  }
}
