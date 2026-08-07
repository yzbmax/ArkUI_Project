/**
 * Toast 工具（DESIGN.md 5.7）—— 深底圆角，底部居中 2s。
 */
import { promptAction } from '@kit.ArkUI';

export class Toast {
  static show(msg: string): void {
    try {
      promptAction.showToast({ message: msg, duration: 2000, bottom: 80 });
    } catch (e) {
      // 弹窗失败时忽略
    }
  }
}
