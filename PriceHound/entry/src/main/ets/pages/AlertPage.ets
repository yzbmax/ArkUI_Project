import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { AppNotification } from '../model/AppNotification';
import { AlertRule } from '../model/AlertRule';
import { PriceUtil } from '../utils/PriceUtil';
import { DateUtil } from '../utils/DateUtil';
import { EmptyState } from '../components/EmptyState';
import { TagBadge } from '../components/TagBadge';
import { RouterUtil } from '../utils/RouterUtil';
import { AlertViewModel } from '../viewmodel/AlertViewModel';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * AlertPage.ets
 * 提醒页：未读通知列表 + 提醒规则入口（可切换标签）
 */
@Component
export struct AlertPage {
  @State tab: number = 0; // 0=通知 1=规则
  @State refreshKey: number = 0;
  @StorageProp('theme.isDark') isDark: boolean = false;

  aboutToAppear(): void {
    this.refreshKey++;
  }

  private unreadCount(): number {
    return AlertViewModel.unreadCount();
  }

  private activeRules(): number {
    return AlertViewModel.activeCount();
  }

  @Builder
  tabBar() {
    Row() {
      Column({ space: 2 }) {
        Text('通知')
          .fontSize(DesignTypography.SIZE_BODY)
          .fontWeight(this.tab === 0 ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(this.tab === 0 ? ThemeManager.textPrimary() : ThemeManager.textTertiary())
        if (this.unreadCount() > 0) {
          Text(`${this.unreadCount()} 条未读`)
            .fontSize(DesignTypography.SIZE_LABEL)
            .fontColor(ThemeManager.accent())
        }
      }
      .layoutWeight(1)
      .onClick(() => {
        this.tab = 0;
      })
      Column({ space: 2 }) {
        Text('规则')
          .fontSize(DesignTypography.SIZE_BODY)
          .fontWeight(this.tab === 1 ? FontWeight.Medium : FontWeight.Normal)
          .fontColor(this.tab === 1 ? ThemeManager.textPrimary() : ThemeManager.textTertiary())
        if (this.activeRules() > 0) {
          Text(`${this.activeRules()} 条生效`)
            .fontSize(DesignTypography.SIZE_LABEL)
            .fontColor(ThemeManager.ok())
        }
      }
      .layoutWeight(1)
      .onClick(() => {
        this.tab = 1;
      })
    }
    .width('100%')
    .height(56)
    .backgroundColor(ThemeManager.card())
    .borderRadius(DesignRadius.MD)
    .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.LG, bottom: DesignSpacing.LG })
  }

  @Builder
  notificationList() {
    Column({ space: DesignSpacing.MD }) {
      Row() {
        Text('全部标为已读')
          .fontSize(DesignTypography.SIZE_CAPTION)
          .fontColor(ThemeManager.accent())
          .onClick(() => {
            AlertViewModel.markAllRead();
            this.refreshKey++;
          })
        Blank()
        Text('清空')
          .fontSize(DesignTypography.SIZE_CAPTION)
          .fontColor(ThemeManager.textTertiary())
          .onClick(() => {
            AlertViewModel.clearAll();
            this.refreshKey++;
          })
      }
      .width('100%')

      if (AlertViewModel.notifications().length === 0) {
        EmptyState({
          icon: '🔔',
          title: '暂无通知',
          subtitle: '设置提醒规则后，降价消息会出现在这里',
        })
      } else {
        ForEach(AlertViewModel.notifications(), (n: AppNotification) => {
          Row({ space: DesignSpacing.MD }) {
            Text(n.isRead ? '○' : '●')
              .fontSize(10)
              .fontColor(n.isRead ? ThemeManager.surface() : ThemeManager.accent())
              .margin({ top: 6 })
            Column({ space: 6 }) {
              Row({ space: DesignSpacing.SM }) {
                Text(n.title)
                  .fontSize(DesignTypography.SIZE_BODY_SM)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeManager.textPrimary())
                Blank()
                Text(DateUtil.relativeTime(n.time))
                  .fontSize(DesignTypography.SIZE_LABEL)
                  .fontColor(ThemeManager.textTertiary())
              }
              .width('100%')
              Text(n.content)
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textSecondary())
                .maxLines(2)
                .lineHeight(20)
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
          }
          .width('100%')
          .padding(DesignSpacing.MD)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.MD)
          .opacity(n.isRead ? 0.65 : 1)
          .onClick(() => {
            AlertViewModel.markRead(n.id);
            this.refreshKey++;
            if (n.productId.length > 0) {
              RouterUtil.toProductDetail(n.productId);
            }
          })
        }, (n: AppNotification) => n.id)
      }
    }
    .width('100%')
    .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
  }

  @Builder
  ruleList() {
    Column({ space: DesignSpacing.MD }) {
      if (AlertViewModel.allRules().length === 0) {
        EmptyState({
          icon: '🎯',
          title: '还没有提醒规则',
          subtitle: '从商品详情页添加目标价格提醒',
        })
      } else {
        ForEach(AlertViewModel.allRules(), (r: AlertRule) => {
          Row({ space: DesignSpacing.MD }) {
            Column({ space: 6 }) {
              Text(r.productName)
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textPrimary())
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Row({ space: DesignSpacing.SM }) {
                TagBadge({
                  text: r.type === 0 ? `目标价 ${PriceUtil.format(r.threshold)}` :
                    r.type === 1 ? `降幅 ${r.threshold}%` : '低于历史最低',
                  small: true,
                })
                Text(DateUtil.formatDateTime(r.createdAt))
                  .fontSize(DesignTypography.SIZE_LABEL)
                  .fontColor(ThemeManager.textTertiary())
              }
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start)
            Toggle({ type: ToggleType.Switch, isOn: r.isActive })
              .selectedColor(ThemeManager.accent())
              .onChange(() => {
                AlertViewModel.toggleRule(r.id);
                this.refreshKey++;
              })
          }
          .width('100%')
          .padding(DesignSpacing.MD)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.MD)
          .onClick(() => {
            RouterUtil.toAlertSetting(r.productId, r.productName);
          })
        }, (r: AlertRule) => r.id)
      }
    }
    .width('100%')
    .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
  }

  build() {
    Column() {
      Row() {
        Column({ space: 2 }) {
          Text('提醒')
            .fontFamily(DesignTypography.FONT_SERIF)
            .fontSize(DesignTypography.SIZE_H1)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeManager.textPrimary())
          Text('降价第一时间知道')
            .fontSize(DesignTypography.SIZE_LABEL)
            .fontColor(ThemeManager.textTertiary())
        }
        .alignItems(HorizontalAlign.Start)
        Blank()
      }
      .width('100%')
      .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.LG, bottom: DesignSpacing.MD })

      this.tabBar()

      Scroll() {
        Column({ space: DesignSpacing.XL }) {
          if (this.tab === 0) {
            this.notificationList()
          } else {
            this.ruleList()
          }
          Blank().height(72)
        }
        .width('100%')
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
      .margin({ top: DesignSpacing.MD })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.bg())
  }
}
