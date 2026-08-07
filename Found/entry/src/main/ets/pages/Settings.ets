/**
 * 设置页（C605）—— 消息开关、隐私、深浅主题（含淡入淡出切换动画）、清缓存、关于、退出登录。
 */
import { ROUTES } from '../shared/constants/Routes';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { AppStore } from '../shared/store/AppStore';
import { AppButton, BtnVariant } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';

@Entry
@Component
struct Settings {
  @State msgPush: boolean = true;
  @State nearPush: boolean = true;
  @State showDept: boolean = true;
  @State strangerChat: boolean = false;
  @StorageLink('isDark') isDark: boolean = false;
  @StorageLink('themeVersion') themeVersion: number = 0;
  @State showLogout: boolean = false;
  private lastToggleAt: number = 0;
  @State overlayOpacity: number = 0;
  @State showOverlay: boolean = false;

  @Builder
  SwitchRow(label: string, value: boolean, onChange: (v: boolean) => void) {
    Row({ space: 12 }) {
      Text(label).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black')).layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: value })
        .selectedColor($r('app.color.brand_terracotta'))
        .onChange((v) => onChange(v))
    }.width('100%').padding(16).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
  }

  @Builder
  EntryRow(label: string, icon: string, onClick: () => void) {
    Row({ space: 12 }) {
      Icon({ name: icon, iconSize: 20, tint: TINT.TEXT_CHARCOAL })
      Text(label).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black')).layoutWeight(1)
      Icon({ name: 'arrow_left', iconSize: 16, tint: TINT.TEXT_STONE }).rotate({ angle: 180 })
    }
    .width('100%').padding(16).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
    .alignItems(VerticalAlign.Center)
    .onClick(onClick)
  }

  build() {
    Stack() {
      Column() {
        Row({ space: 8 }) {
          Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
          Text('设置').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
        }
        .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
        .alignItems(VerticalAlign.Center)

        Scroll() {
          Column({ space: 16 }) {
            Text('消息通知').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_olive'))
            Column({ space: 8 }) {
              this.SwitchRow('系统消息推送', this.msgPush, (v) => this.msgPush = v)
              this.SwitchRow('附近动态推送', this.nearPush, (v) => this.nearPush = v)
            }
            Text('隐私').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_olive'))
            Column({ space: 8 }) {
              this.SwitchRow('展示院系信息', this.showDept, (v) => this.showDept = v)
              this.SwitchRow('允许陌生人私信', this.strangerChat, (v) => this.strangerChat = v)
            }
            Text('外观').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_olive'))
            this.SwitchRow(this.isDark ? '深色模式' : '浅色模式', this.isDark, (v) => {
              this.doThemeToggle(v);
            })
            Text('其他').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_olive'))
            Column({ space: 8 }) {
              this.EntryRow('清除缓存', 'settings_2', () => Toast.show('缓存已清除'))
              this.EntryRow('关于我们', 'info_circle', () => Toast.show('校园失物招领 v1.0'))
            }
            AppButton({ text: '退出登录', variant: BtnVariant.DANGER, full: true, onTap: () => this.showLogout = true })
          }.padding(16)
        }.layoutWeight(1)
      }
      .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
      .bindSheet(this.showLogout, this.buildLogout(), {})

      // 主题切换遮罩：先淡入盖满 → 切换颜色模式 → 淡出露出新主题
      if (this.showOverlay) {
        Column()
          .width('100%').height('100%')
          .backgroundColor('#141413')
          .opacity(this.overlayOpacity)
          .zIndex(10)
          .hitTestBehavior(HitTestMode.Block)
      }
    }
    .width('100%').height('100%')
  }

  /** 深色/浅色切换：淡入淡出动画 + 应用全局颜色模式 */
  private doThemeToggle(v: boolean): void {
    // ArkUI Toggle 受控组件会在状态同步时自发重复回调 onChange（约几百毫秒后弹回相反值）。
    // 用时间戳守卫忽略切换后 800ms 内的重复回调；正常人手动切换远慢于此，不受影响。
    const now = Date.now();
    if (now - this.lastToggleAt < 800) {
      return;
    }
    this.lastToggleAt = now;
    // 立即同步 Toggle 绑定值
    this.isDark = v;
    this.showOverlay = true;
    this.overlayOpacity = 0;
    this.getUIContext().animateTo({ duration: 130, curve: Curve.EaseIn }, () => {
      this.overlayOpacity = 1;
    });
    setTimeout(() => {
      // 持久化用户选择
      AppStore.setDark(v);
      // 用当前页 UIContext 取 ApplicationContext 应用颜色模式（触发 dark 资源生效）
      try {
        const host = this.getUIContext().getHostContext();
        if (host) {
          host.getApplicationContext().setColorMode(v
            ? ConfigurationConstant.ColorMode.COLOR_MODE_DARK
            : ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
        }
      } catch (e) {
        Toast.show('主题切换失败：' + (e as Error).message);
      }
      Toast.show(v ? '已切换深色模式' : '已切换浅色模式');
      this.getUIContext().animateTo({ duration: 260, curve: Curve.EaseOut }, () => {
        this.overlayOpacity = 0;
      });
      setTimeout(() => {
        this.showOverlay = false;
        this.overlayOpacity = 0;
      }, 320);
    }, 170);
  }

  @Builder
  buildLogout() {
    Column({ space: 16 }) {
      Text('确认退出登录？').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      Row({ space: 12 }) {
        AppButton({ text: '取消', variant: BtnVariant.SECONDARY, onTap: () => this.showLogout = false })
        AppButton({ text: '退出', variant: BtnVariant.DANGER, onTap: () => {
          AppStore.logout();
          this.showLogout = false;
          this.getUIContext().getRouter().replaceUrl({ url: ROUTES.login });
        } })
      }.width('100%')
    }.padding(24).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
  }
}
