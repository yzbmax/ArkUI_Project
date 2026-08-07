/**
 * 管理端（C701 框架 + C702 审核 + C703 用户 + C704 举报）—— 管理员入口，Tab 切换。
 */
import { ApiRepo } from '../shared/api/ApiRepo';
import { Post, ReportItem } from '../shared/mock/Models';
import { UserProfile } from '../shared/store/AppStore';
import { ROLE_NAMES } from '../shared/constants/Constants';
import { AppButton, BtnVariant, AvatarPlaceholder } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';

type AdminTab = 'audit' | 'user' | 'report';

/** ArkTS 不支持内联对象字面量当查表用（arkts-no-untyped-obj-literals），统一改 Map。 */
const ADMIN_TABS: AdminTab[] = ['audit', 'user', 'report'];

const ADMIN_TAB_LABEL: Map<string, string> = new Map<string, string>([
  ['audit', '信息审核'],
  ['user', '用户管理'],
  ['report', '举报处理']
]);

const REPORT_STATUS_LABEL: Map<string, string> = new Map<string, string>([
  ['pending', '待处理'],
  ['dismissed', '已驳回'],
  ['warned', '已警告'],
  ['deleted', '已删除'],
  ['frozen', '已冻结']
]);

@Entry
@Component
struct Admin {
  @State tab: AdminTab = 'audit';
  @State audit: Post[] = [];
  @State reports: ReportItem[] = [];
  @State users: UserProfile[] = [];

  aboutToAppear(): void {
    this.load();
  }

  private async load(): Promise<void> {
    try {
      this.audit = await ApiRepo.fetchAudits();
      this.reports = await ApiRepo.fetchReports();
      this.users = await ApiRepo.fetchUsers();
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  private async doApprove(id: string): Promise<void> {
    try {
      await ApiRepo.approveAudit(id);
      this.audit = this.audit.filter((x: Post) => x.id !== id);
      Toast.show('已通过');
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  private async doReject(id: string): Promise<void> {
    try {
      await ApiRepo.rejectAudit(id, '信息不完整，请补充后重新提交');
      this.audit = this.audit.filter((x: Post) => x.id !== id);
      Toast.show('已驳回');
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  private async doHandleReport(id: string): Promise<void> {
    try {
      await ApiRepo.handleReport(id, 'warned', '已警告');
      Toast.show('已处理：警告');
      this.reports = await ApiRepo.fetchReports();
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('管理后台').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      Row({ space: 20 }) {
        ForEach(ADMIN_TABS, (t: AdminTab) => {
          Column({ space: 4 }) {
            Text(ADMIN_TAB_LABEL.get(t) ?? t)
              .fontSize($r('app.float.font_subtitle'))
              .fontColor(this.tab === t ? $r('app.color.brand_terracotta') : $r('app.color.text_stone'))
              .fontWeight(this.tab === t ? FontWeight.Bold : FontWeight.Normal)
            if (this.tab === t) {
              Row().width(20).height(3).backgroundColor($r('app.color.brand_terracotta')).borderRadius(2)
            }
          }.onClick(() => this.tab = t)
        })
      }.width('100%').padding({ left: 16, bottom: 8 })

      Scroll() {
        Column({ space: 8 }) {
          if (this.tab === 'audit') {
            ForEach(this.audit, (p: Post) => {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(p.title).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
                  Text('自动审核命中：' + (p.urgent ? '加急标记' : '无')).fontSize($r('app.float.font_caption')).fontColor($r('app.color.status_pending'))
                  Text('提交于 ' + p.time).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Row({ space: 8 }) {
                  AppButton({ text: '驳回', variant: BtnVariant.SECONDARY, onTap: () => { this.doReject(p.id); } })
                  AppButton({ text: '通过', onTap: () => { this.doApprove(p.id); } })
                }
              }
              .width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
              .alignItems(VerticalAlign.Center)
            }, (p: Post) => p.id)
          } else if (this.tab === 'user') {
            ForEach(this.users, (u: UserProfile) => {
              Row({ space: 12 }) {
                AvatarPlaceholder({ iconSize: 36 })
                Column({ space: 4 }) {
                  Text(u.nickname).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
                  Text((ROLE_NAMES.get(u.role) ?? u.role) + ' · ' + u.campus).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Text('正常').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.status_resolved'))
                Icon({ name: 'settings_2', iconSize: 18, tint: TINT.TEXT_STONE }).onClick(() => Toast.show('冻结/解冻（待接入）'))
              }
              .width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
              .alignItems(VerticalAlign.Center)
            }, (u: UserProfile) => u.id)
          } else {
            ForEach(this.reports, (r: ReportItem) => {
              Row({ space: 12 }) {
                Column({ space: 4 }) {
                  Text(r.target).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
                  Text('原因：' + r.reason).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
                  Text(r.time).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Text(REPORT_STATUS_LABEL.get(r.status) ?? r.status)
                  .fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
                Icon({ name: 'dots', iconSize: 18, tint: TINT.TEXT_STONE })
                  .onClick(() => { this.doHandleReport(r.id); })
              }
              .width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
              .alignItems(VerticalAlign.Center)
            }, (r: ReportItem) => r.id)
          }
        }.padding(16)
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
