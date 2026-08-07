import { promptAction } from '@kit.ArkUI';

/**
 * Toast.ets
 * 轻量提示封装（基于系统 promptAction）
 */
export class ToastUtil {
  static show(message: string): void {
    try {
      promptAction.showToast({
        message: message,
        duration: 2000,
      });
    } catch (e) {
      console.error('ToastUtil.show error: ' + JSON.stringify(e));
    }
  }
}
