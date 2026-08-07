import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { DesignTypography } from '../constants/DesignTokens';
import { MotionDuration, MotionCurve } from '../constants/MotionTokens';
import { ThemeManager } from '../utils/ThemeManager';
import { DashboardPage } from './DashboardPage';
import { DiscoverPage } from './DiscoverPage';
import { AlertPage } from './AlertPage';
import { ProfilePage } from './ProfilePage';

/**
 * Index.ets
 * 主框架：底部 TabBar 导航（看板 / 发现 / 提醒 / 我的）
 * - 主题初始化与系统深色检测
 * - Tab 切换淡入过渡动画
 */
@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @StorageProp('theme.isDark') isDark: boolean = false;

  private tabs: string[] = ['看板', '发现', '提醒', '我的'];
  private icons: string[] = ['🏠', '🔍', '🔔', '👤'];

  aboutToAppear(): void {
    ThemeManager.init();
    // 读取系统深色配置（跟随系统模式需要）
    try {
      const ctx = getContext(this) as common.UIAbilityContext;
      const mode: number | undefined = ctx.config.colorMode;
      const dark: boolean = mode !== undefined && mode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      ThemeManager.setSystemDark(dark);
    } catch (e) {
      console.error('Index detect system theme error: ' + JSON.stringify(e));
    }
  }

  onPageShow(): void {
    // 从设置页返回后同步系统主题
    try {
      const ctx = getContext(this) as common.UIAbilityContext;
      const mode: number | undefined = ctx.config.colorMode;
      const dark: boolean = mode !== undefined && mode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      ThemeManager.setSystemDark(dark);
    } catch (e) {
      console.error('Index refresh system theme error: ' + JSON.stringify(e));
    }
  }

  @Builder
  tabContent() {
    Stack() {
      if (this.currentTab === 0) {
        DashboardPage()
          .transition(TransitionEffect.OPACITY.animation({
            duration: MotionDuration.BASE,
            curve: MotionCurve.EASE_OUT,
          }))
      } else if (this.currentTab === 1) {
        DiscoverPage()
          .transition(TransitionEffect.OPACITY.animation({
            duration: MotionDuration.BASE,
            curve: MotionCurve.EASE_OUT,
          }))
      } else if (this.currentTab === 2) {
        AlertPage()
          .transition(TransitionEffect.OPACITY.animation({
            duration: MotionDuration.BASE,
            curve: MotionCurve.EASE_OUT,
          }))
      } else {
        ProfilePage()
          .transition(TransitionEffect.OPACITY.animation({
            duration: MotionDuration.BASE,
            curve: MotionCurve.EASE_OUT,
          }))
      }
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Stack() {
      Column() {
        this.tabContent()
      }
      .width('100%')
      .height('100%')

      // 底部导航
      Row() {
        ForEach(this.tabs, (item: string, index: number) => {
          Column({ space: 2 }) {
            Text(this.icons[index])
              .fontSize(20)
              .opacity(this.currentTab === index ? 1 : 0.55)
              .scale({ x: this.currentTab === index ? 1 : 0.9, y: this.currentTab === index ? 1 : 0.9 })
              .animation({ duration: MotionDuration.FAST, curve: MotionCurve.EASE_SPRING })
            Text(item)
              .fontSize(DesignTypography.SIZE_LABEL)
              .fontColor(this.currentTab === index ? ThemeManager.accent() : ThemeManager.textTertiary())
              .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Normal)
          }
          .layoutWeight(1)
          .height(56)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            if (this.currentTab !== index) {
              this.currentTab = index;
            }
          })
        }, (item: string) => item)
      }
      .width('100%')
      .height(64)
      .backgroundColor(ThemeManager.card())
      .border({ width: { top: 1 }, color: ThemeManager.border() })
      .alignItems(VerticalAlign.Top)
      .position({ x: 0, y: '88%' })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.bg())
  }
}
