/**
 * EntryAbility - 浮光应用入口
 * 全屏沉浸式设置 + 分布式流转能力
 */
import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0002;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 处理多端流转过来的数据
    if (launchParam.launchReason === AbilityConstant.LaunchReason.CONTINUATION) {
      hilog.info(DOMAIN, TAG, 'Launched by continuation');
      if (want.parameters && want.parameters['continuationData']) {
        const dataStr = want.parameters['continuationData'] as string;
        hilog.info(DOMAIN, TAG, `Continuation data: ${dataStr}`);
        // TODO: 根据流转数据恢复界面状态
      }
    }

    try {
      // 设置深色模式以适配沉浸式界面
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
    } catch (err) {
      hilog.error(DOMAIN, TAG, `Failed to set colorMode: ${JSON.stringify(err)}`);
    }
    hilog.info(DOMAIN, TAG, 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageCreate');

    // 加载主页面
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, `Failed to load content: ${JSON.stringify(err)}`);
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading content');
    });

    // 设置全屏沉浸式
    const mainWindow = windowStage.getMainWindow();
    mainWindow.then((win: window.Window) => {
      // 隐藏状态栏和导航栏
      win.setWindowLayoutFullScreen(true).then(() => {
        hilog.info(DOMAIN, TAG, 'Set full screen mode');
      }).catch((err: Error) => {
        hilog.error(DOMAIN, TAG, `Set full screen failed: ${err.message}`);
      });

      // 设置状态栏透明
      win.setWindowSystemBarProperties({
        statusBarColor: '#00000000',
        navigationBarColor: '#00000000',
        statusBarContentColor: '#FFFFFF'
      }).catch((err: Error) => {
        hilog.error(DOMAIN, TAG, `Set system bar failed: ${err.message}`);
      });

      // 沉浸式状态栏
      win.setSpecificSystemBarEnabled('status', false).catch((err: Error) => {
        hilog.error(DOMAIN, TAG, `Hide status bar failed: ${err.message}`);
      });
    }).catch((err: Error) => {
      hilog.error(DOMAIN, TAG, `Get main window failed: ${err.message}`);
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, TAG, 'onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, TAG, 'onForeground');
  }

  onBackground(): void {
    hilog.info(DOMAIN, TAG, 'onBackground');
  }

  // ============================
  // 分布式流转回调
  // ============================

  /**
   * 流转开始准备
   * 在此处保存需要流转的卡片数据
   */
  onContinue(wantParam: Record<string, Object>): AbilityConstant.OnContinueResult {
    hilog.info(DOMAIN, TAG, 'onContinue');

    // 将当前卡片数据打包到 wantParam 中
    try {
      wantParam['continuationData'] = JSON.stringify({
        type: 'floating_light_card',
        timestamp: Date.now()
      });
      return AbilityConstant.OnContinueResult.AGREE;
    } catch (e) {
      hilog.error(DOMAIN, TAG, `onContinue failed: ${JSON.stringify(e)}`);
      return AbilityConstant.OnContinueResult.REJECT;
    }
  }
}
