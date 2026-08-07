import { router } from '@kit.ArkUI';
import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { getRepo } from '../repository/DataRepository';
import { Product } from '../model/Product';
import { AlertRule, AlertType } from '../model/AlertRule';
import { PriceUtil } from '../utils/PriceUtil';
import { DateUtil } from '../utils/DateUtil';
import { ToastUtil } from '../components/Toast';
import { TagBadge } from '../components/TagBadge';
import { RouterUtil } from '../utils/RouterUtil';
import { ConfirmDialog } from '../components/ConfirmDialog';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * AlertSettingPage.ets
 * 提醒设置页：新建提醒规则（三种类型）+ 已有规则管理
 */
@Entry
@Component
export struct AlertSettingPage {
  @StorageProp('theme.isDark') isDark: boolean = false;
  @State productId: string = '';
  @State productName: string = '';
  @State ruleType: number = AlertType.TARGET_PRICE;
  @State thresholdInput: string = '';
  @State refreshKey: number = 0;
  removeDialogController: CustomDialogController | null = null;
  @State pendingRemoveId: string = '';

  aboutToAppear(): void {
    const params = router.getParams() as Record<string, Object>;
    if (params !== undefined && params['productId'] !== undefined) {
      this.productId = params['productId'] as string;
    }
    if (params !== undefined && params['productName'] !== undefined) {
      this.productName = params['productName'] as string;
    }
  }

  private product(): Product {
    const p = getRepo().getProduct(this.productId);
    return p !== undefined ? p : new Product();
  }

  private rules(): Array<AlertRule> {
    return getRepo().alertRules.filter((r) => r.productId === this.productId);
  }

  private thresholdHint(): string {
    const p = this.product();
    if (this.ruleType === AlertType.TARGET_PRICE) {
      return `当前价 ${PriceUtil.format(p.currentPrice)}，建议目标价 ${PriceUtil.format(Math.round(p.currentPrice * 0.9))}`;
    } else if (this.ruleType === AlertType.DROP_PERCENT) {
      return '当价格降幅达到该百分比时提醒（如 10 表示降 10%）';
    }
    return '当价格低于历史最低价时提醒';
  }

  private saveRule(): void {
    const threshold = parseFloat(this.thresholdInput);
    if (isNaN(threshold) || (this.ruleType !== AlertType.BELOW_LOWEST && threshold <= 0)) {
      ToastUtil.show('请输入有效阈值');
      return;
    }
    const rule = new AlertRule();
    rule.id = `r_${Date.now()}`;
    rule.productId = this.productId;
    rule.productName = this.productName;
    rule.type = this.ruleType;
    rule.threshold = threshold;
    rule.isActive = true;
    getRepo().addAlertRule(rule);
    ToastUtil.show('提醒规则已创建');
    this.thresholdInput = '';
    this.refreshKey++;
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor(ThemeManager.textPrimary())
          .width(36)
          .onClick(() => RouterUtil.back())
        Column({ space: 2 }) {
          Text('提醒设置')
            .fontFamily(DesignTypography.FONT_SERIF)
            .fontSize(DesignTypography.SIZE_TITLE)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.textPrimary())
          Text(this.productName)
            .fontSize(DesignTypography.SIZE_LABEL)
            .fontColor(ThemeManager.textTertiary())
            .maxLines(1)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .padding({ left: DesignSpacing.SM })
        Blank().width(36)
      }
      .width('100%')
      .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.MD, bottom: DesignSpacing.MD })

      Scroll() {
        Column({ space: DesignSpacing.XL }) {
          // ===== 新建规则 =====
          Column({ space: DesignSpacing.LG }) {
            Text('新建提醒规则')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H3)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
              .width('100%')

            // 类型选择
            Row({ space: DesignSpacing.SM }) {
              this.typeChip('目标价格', AlertType.TARGET_PRICE)
              this.typeChip('降幅 %', AlertType.DROP_PERCENT)
              this.typeChip('低于历史最低', AlertType.BELOW_LOWEST)
            }
            .width('100%')

            Text(this.thresholdHint())
              .fontSize(DesignTypography.SIZE_LABEL)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')

            TextInput({
              placeholder: this.ruleType === AlertType.DROP_PERCENT ? '输入降幅百分比' : '输入金额（元）',
            })
              .type(InputType.Number)
              .width('100%')
              .height(46)
              .backgroundColor(ThemeManager.bg())
              .placeholderColor(ThemeManager.textTertiary())
              .fontColor(ThemeManager.textPrimary())
              .borderRadius(DesignRadius.MD)
              .onChange((v: string) => {
                this.thresholdInput = v;
              })

            Button('创建提醒')
              .width('100%')
              .height(46)
              .fontSize(DesignTypography.SIZE_BODY)
              .fontColor(Color.White)
              .backgroundColor(ThemeManager.accent())
              .borderRadius(DesignRadius.MD)
              .onClick(() => this.saveRule())
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 已有规则 =====
          Row() {
            Text('已有规则')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H3)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
            Blank()
            Text(`${this.rules().length} 条`)
              .fontSize(DesignTypography.SIZE_CAPTION)
              .fontColor(ThemeManager.textTertiary())
          }
          .width('100%')
          .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })

          Column({ space: DesignSpacing.MD }) {
            if (this.rules().length === 0) {
              Text('还没有规则，创建第一条吧')
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textTertiary())
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(DesignSpacing.XL)
            } else {
              ForEach(this.rules(), (r: AlertRule) => {
                Row({ space: DesignSpacing.MD }) {
                  Column({ space: 6 }) {
                    Row({ space: DesignSpacing.SM }) {
                      TagBadge({
                        text: r.type === AlertType.TARGET_PRICE ? `目标价 ${PriceUtil.format(r.threshold)}` :
                          r.type === AlertType.DROP_PERCENT ? `降幅 ${r.threshold}%` : '低于历史最低',
                        color: ThemeManager.accent(),
                        small: true,
                      })
                      Text(r.isActive ? '生效中' : '已停用')
                        .fontSize(DesignTypography.SIZE_LABEL)
                        .fontColor(r.isActive ? ThemeManager.ok() : ThemeManager.textTertiary())
                    }
                    Text(`创建于 ${DateUtil.formatDateTime(r.createdAt)}`)
                      .fontSize(DesignTypography.SIZE_LABEL)
                      .fontColor(ThemeManager.textTertiary())
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  Toggle({ type: ToggleType.Switch, isOn: r.isActive })
                    .selectedColor(ThemeManager.accent())
                    .onChange(() => {
                      getRepo().toggleAlertRule(r.id);
                      this.refreshKey++;
                    })
                  Text('🗑')
                    .fontSize(18)
                    .opacity(0.7)
                    .onClick(() => {
                      this.pendingRemoveId = r.id;
                      this.removeDialogController = new CustomDialogController({
                        builder: ConfirmDialog({
                          title: '删除规则',
                          content: '确定删除这条提醒规则吗？',
                          confirmText: '删除',
                          danger: true,
                          onConfirm: () => {
                            getRepo().removeAlertRule(this.pendingRemoveId);
                            this.refreshKey++;
                          },
                        }),
                        alignment: DialogAlignment.Center,
                        customStyle: true,
                      });
                      if (this.removeDialogController !== null) {
                        this.removeDialogController.open();
                      }
                    })
                }
                .width('100%')
                .padding(DesignSpacing.MD)
                .backgroundColor(ThemeManager.card())
                .borderRadius(DesignRadius.MD)
              }, (r: AlertRule) => r.id)
            }
          }
          .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })

          Blank().height(40)
        }
        .width('100%')
        .padding({ top: DesignSpacing.MD })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.bg())
  }

  @Builder
  typeChip(label: string, type: number) {
    Text(label)
      .fontSize(DesignTypography.SIZE_BODY_SM)
      .fontColor(this.ruleType === type ? ThemeManager.card() : ThemeManager.textSecondary())
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.ruleType === type ? ThemeManager.textPrimary() : ThemeManager.surface())
      .borderRadius(DesignRadius.XL)
      .onClick(() => {
        this.ruleType = type;
        this.thresholdInput = '';
      })
  }
}
