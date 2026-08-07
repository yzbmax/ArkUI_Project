import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { ToastUtil } from '../components/Toast';
import { RouterUtil } from '../utils/RouterUtil';
import { SettingItem } from '../components/SettingItem';
import { ThemeMode } from '../constants/AppConstants';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * AppearanceSettingPage.ets
 * 外观设置页：主题模式（浅色/深色/跟随系统）/ 价格显示偏好 / 文字大小
 * - 主题切换即时生效（ThemeManager + AppStorage 广播）
 */
@Entry
@Component
export struct AppearanceSettingPage {
  @State themeIndex: number = ThemeMode.SYSTEM; // 0=浅色 1=深色 2=跟随系统
  @State pricePrecision: boolean = false;
  @State bigFont: boolean = false;
  @StorageProp('theme.isDark') isDark: boolean = false;

  private themes: string[] = ['浅色（默认）', '深色', '跟随系统'];

  aboutToAppear(): void {
    this.themeIndex = ThemeManager.currentMode();
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor(ThemeManager.textPrimary())
          .width(36)
          .onClick(() => RouterUtil.back())
        Text('外观设置')
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
          // ===== 主题 =====
          Column({ space: DesignSpacing.MD }) {
            Text('主题')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')
            Column({ space: DesignSpacing.SM }) {
              ForEach(this.themes, (theme: string, index: number) => {
                Row() {
                  Text(theme)
                    .fontSize(DesignTypography.SIZE_BODY)
                    .fontColor(this.themeIndex === index ? ThemeManager.accent() : ThemeManager.textPrimary())
                  Blank()
                  if (this.themeIndex === index) {
                    Text('●')
                      .fontSize(12)
                      .fontColor(ThemeManager.accent())
                  }
                }
                .width('100%')
                .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: 14, bottom: 14 })
                .backgroundColor(ThemeManager.card())
                .borderRadius(DesignRadius.MD)
                .onClick(() => {
                  this.themeIndex = index;
                  ThemeManager.setMode(index);
                  ToastUtil.show(`已切换为${theme}`);
                })
              }, (theme: string) => theme)
            }
            .width('100%')
          }
          .width('100%')

          // ===== 显示偏好 =====
          Column({ space: DesignSpacing.MD }) {
            Text('显示偏好')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')
            SettingItem({
              icon: '💴',
              title: '价格显示两位小数',
              subtitle: '如 ¥1,234.00',
              showSwitch: true,
              switchValue: this.pricePrecision,
              onSwitchChange: (v: boolean) => {
                this.pricePrecision = v;
              },
            })
            SettingItem({
              icon: '🔠',
              title: '大字体模式',
              subtitle: '放大正文与价格字号',
              showSwitch: true,
              switchValue: this.bigFont,
              onSwitchChange: (v: boolean) => {
                this.bigFont = v;
              },
            })
          }
          .width('100%')

          // ===== 预览 =====
          Column({ space: DesignSpacing.SM }) {
            Text('预览')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')
            Column({ space: DesignSpacing.SM }) {
              Text('价格示例')
                .fontSize(DesignTypography.SIZE_LABEL)
                .fontColor(ThemeManager.textTertiary())
                .width('100%')
              Text(this.pricePrecision ? '¥1,299.00' : '¥1,299')
                .fontFamily(DesignTypography.FONT_MONO)
                .fontSize(this.bigFont ? 32 : 26)
                .fontWeight(FontWeight.Medium)
                .fontColor(ThemeManager.accent())
                .width('100%')
              Text('Apple AirPods Pro 3')
                .fontSize(this.bigFont ? 18 : 15)
                .fontColor(ThemeManager.textPrimary())
                .width('100%')
            }
            .width('100%')
            .padding(DesignSpacing.LG)
            .backgroundColor(ThemeManager.card())
            .borderRadius(DesignRadius.LG)
          }
          .width('100%')

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
