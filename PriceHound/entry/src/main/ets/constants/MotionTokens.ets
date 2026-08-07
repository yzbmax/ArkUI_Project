/**
 * MotionTokens.ets
 * 动效系统 Token：时长 / 曲线 / 位移，统一页面与组件动效语言
 * 遵循 DESIGN.md：克制的位移、柔和的缓动
 */

export class MotionDuration {
  static readonly FAST: number = 150;
  static readonly BASE: number = 250;
  static readonly SLOW: number = 350;
  static readonly STAGGER: number = 60;
}

export class MotionCurve {
  /** 标准进出手势：先快后慢 */
  static readonly EASE_OUT: string = 'cubic-bezier(0.25, 0.1, 0.25, 1)';
  /** 弹性柔和：入场轻微回弹 */
  static readonly EASE_SPRING: string = 'cubic-bezier(0.34, 1.3, 0.64, 1)';
  /** 页面转场：经典 ease-out */
  static readonly PAGE_IN: string = 'cubic-bezier(0.25, 0.1, 0.25, 1)';
  static readonly PAGE_OUT: string = 'cubic-bezier(0.42, 0, 0.58, 1)';
}

export class MotionDistance {
  /** 页面级水平位移 */
  static readonly PAGE: number = 56;
  /** 列表项垂直位移 */
  static readonly ITEM: number = 24;
  /** 弹层垂直位移 */
  static readonly SHEET: number = 120;
}
