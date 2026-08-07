import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * ConfirmDialog.ets
 * 暖色调确认弹窗（标题 + 内容 + 取消/确认）
 */
@CustomDialog
export struct ConfirmDialog {
  controller: CustomDialogController;
  @Prop title: string = '确认操作';
  @Prop content: string = '';
  @Prop confirmText: string = '确定';
  @Prop cancelText: string = '取消';
  @Prop danger: boolean = false;
  onConfirm: () => void = () => {};

  build() {
    Column({ space: DesignSpacing.LG }) {
      Text(this.title)
        .fontFamily(DesignTypography.FONT_SERIF)
        .fontSize(DesignTypography.SIZE_TITLE)
        .fontWeight(FontWeight.Medium)
        .fontColor(ThemeManager.textPrimary())
        .textAlign(TextAlign.Center)
        .width('100%')

      Text(this.content)
        .fontSize(DesignTypography.SIZE_BODY_SM)
        .fontColor(ThemeManager.textSecondary())
        .textAlign(TextAlign.Center)
        .width('100%')

      Row({ space: DesignSpacing.MD }) {
        Button(this.cancelText)
          .layoutWeight(1)
          .fontSize(DesignTypography.SIZE_BODY)
          .fontColor(ThemeManager.textPrimary())
          .backgroundColor(ThemeManager.surface())
          .borderRadius(DesignRadius.MD)
          .height(44)
          .onClick(() => {
            this.controller.close();
          })
        Button(this.confirmText)
          .layoutWeight(1)
          .fontSize(DesignTypography.SIZE_BODY)
          .fontColor(Color.White)
          .backgroundColor(this.danger ? ThemeManager.rise() : ThemeManager.accent())
          .borderRadius(DesignRadius.MD)
          .height(44)
          .onClick(() => {
            this.onConfirm();
            this.controller.close();
          })
      }
      .width('100%')
    }
    .padding(DesignSpacing.XL)
    .backgroundColor(ThemeManager.card())
    .borderRadius(DesignRadius.LG)
  }
}
