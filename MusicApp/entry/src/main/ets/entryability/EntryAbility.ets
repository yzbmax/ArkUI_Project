import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { SAFE_TOP, SAFE_BOTTOM } from '../contants/index';
import { AVSessionManager } from '../utils/AVSessionManager';

const DOMAIN = 0x0000;

/**
 * 应用入口 Ability（P2 改造）
 * 职责：沉浸式状态栏 + 计算安全区域写入 AppStorage + 启动 Start 页。
 */
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      // 跟随系统深浅色（本项目固定暗色，不强制切换）
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'EntryAbility', 'Ability onCreate');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // 1) 沉浸式：内容全屏铺满，状态栏/导航栏叠加在内容之上
    try {
      const win = windowStage.getMainWindowSync();
      win.setWindowLayoutFullScreen(true);
      // 状态栏文字设为浅色（暗色背景适配）
      win.setWindowSystemBarProperties({ statusBarContentColor: '#ffffff' });
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'Failed to set full screen. Cause: %{public}s', JSON.stringify(err));
    }

    // 2) 计算安全区域高度，写入 AppStorage 供页面避让
    try {
      const win = windowStage.getMainWindowSync();
      const area = win.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      AppStorage.setOrCreate(SAFE_TOP, area.topRect.height);
      AppStorage.setOrCreate(SAFE_BOTTOM, area.bottomRect.height);
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'Failed to compute safe area. Cause: %{public}s', JSON.stringify(err));
    }

    // 3) 初始化媒体会话（锁屏 / 控制中心），需在 UIAbilityContext 就绪后
    try {
      AVSessionManager.getInstance().init(this.context);
    } catch (err) {
      hilog.error(DOMAIN, 'EntryAbility', 'AVSession init failed: %{public}s', JSON.stringify(err));
    }

    // 4) 启动页（Start 经 replaceUrl 跳 Index，不可返回）
    windowStage.loadContent('pages/Start', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'EntryAbility', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'EntryAbility', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // 主窗口销毁，释放 UI 相关资源
    hilog.info(DOMAIN, 'EntryAbility', 'Ability onWindowStageDestroy');
  }
}
