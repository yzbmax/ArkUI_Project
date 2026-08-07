import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { getRepo } from '../repository/DataRepository';
import { ToastUtil } from '../components/Toast';
import { RouterUtil } from '../utils/RouterUtil';
import { DateUtil } from '../utils/DateUtil';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * BackupRestorePage.ets
 * 备份与恢复页：本地备份 / 恢复 / 清空数据
 */
@Entry
@Component
export struct BackupRestorePage {
  @StorageProp('theme.isDark') isDark: boolean = false;
  @State backupList: Array<string> = [];
  @State backingUp: boolean = false;
  resetDialogController: CustomDialogController | null = null;

  aboutToAppear(): void {
    // 模拟历史备份记录
    this.backupList = [
      `备份 ${DateUtil.formatDate(Date.now() - 2 * 24 * 3600 * 1000)} · ${getRepo().products.length} 件商品`,
      `备份 ${DateUtil.formatDate(Date.now() - 9 * 24 * 3600 * 1000)} · 8 件商品`,
      `备份 ${DateUtil.formatDate(Date.now() - 20 * 24 * 3600 * 1000)} · 5 件商品`,
    ];
  }

  private doBackup(): void {
    this.backingUp = true;
    setTimeout(() => {
      this.backingUp = false;
      this.backupList.unshift(`备份 ${DateUtil.formatDate(Date.now())} · ${getRepo().products.length} 件商品`);
      ToastUtil.show('本地备份完成');
    }, 1200);
  }

  private doRestore(): void {
    ToastUtil.show('已恢复到最近一次备份');
  }

  private doReset(): void {
    this.resetDialogController = new CustomDialogController({
      builder: ConfirmDialog({
        title: '清空所有数据',
        content: '将删除所有商品、价格记录与提醒规则，且不可恢复。确定继续吗？',
        confirmText: '清空',
        danger: true,
        onConfirm: () => {
          getRepo().clearNotifications();
          ToastUtil.show('数据已清空（演示）');
        },
      }),
      alignment: DialogAlignment.Center,
      customStyle: true,
    });
    if (this.resetDialogController !== null) {
      this.resetDialogController.open();
    }
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor(ThemeManager.textPrimary())
          .width(36)
          .onClick(() => RouterUtil.back())
        Text('备份与恢复')
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
          // ===== 说明 =====
          Column({ space: DesignSpacing.SM }) {
            Text('💾 本地备份')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H2)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
            Text('备份会保存全部商品、价格记录与提醒规则，存储于应用本地沙箱。')
              .fontSize(DesignTypography.SIZE_BODY_SM)
              .fontColor(ThemeManager.textSecondary())
              .lineHeight(22)
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 操作按钮 =====
          Column({ space: DesignSpacing.MD }) {
            Button() {
              Row({ space: DesignSpacing.SM }) {
                if (this.backingUp) {
                  LoadingProgress()
                    .width(18)
                    .height(18)
                    .color(Color.White)
                } else {
                  Text('📦')
                    .fontSize(18)
                }
                Text(this.backingUp ? '备份中…' : '立即备份')
                  .fontSize(DesignTypography.SIZE_BODY)
                  .fontColor(Color.White)
              }
            }
            .width('100%')
            .height(48)
            .backgroundColor(ThemeManager.accent())
            .borderRadius(DesignRadius.MD)
            .onClick(() => this.doBackup())

            Button('从备份恢复')
              .width('100%')
              .height(48)
              .fontSize(DesignTypography.SIZE_BODY)
              .fontColor(ThemeManager.textPrimary())
              .backgroundColor(ThemeManager.surface())
              .borderRadius(DesignRadius.MD)
              .onClick(() => this.doRestore())
          }
          .width('100%')

          // ===== 备份历史 =====
          Column({ space: DesignSpacing.MD }) {
            Text('备份历史')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')
            Column({ space: DesignSpacing.SM }) {
              ForEach(this.backupList, (item: string) => {
                Row() {
                  Text('🗂️')
                    .fontSize(18)
                  Text(item)
                    .fontSize(DesignTypography.SIZE_BODY_SM)
                    .fontColor(ThemeManager.textPrimary())
                    .layoutWeight(1)
                    .padding({ left: DesignSpacing.MD })
                  Text('恢复')
                    .fontSize(DesignTypography.SIZE_LABEL)
                    .fontColor(ThemeManager.accent())
                    .onClick(() => this.doRestore())
                }
                .width('100%')
                .padding(DesignSpacing.MD)
                .backgroundColor(ThemeManager.card())
                .borderRadius(DesignRadius.MD)
              }, (item: string) => item)
            }
            .width('100%')
          }
          .width('100%')

          // ===== 危险区 =====
          Column({ space: DesignSpacing.MD }) {
            Text('危险区')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.rise())
              .width('100%')
            Button('清空所有数据')
              .width('100%')
              .height(48)
              .fontSize(DesignTypography.SIZE_BODY)
              .fontColor(ThemeManager.rise())
              .backgroundColor(ThemeManager.card())
              .borderRadius(DesignRadius.MD)
              .onClick(() => this.doReset())
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
