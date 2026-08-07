/**
 * 认领审核（发布者）—— 我收到的认领申请，可通过/驳回。
 */
import { ApiRepo, ClaimItem } from '../shared/api/ApiRepo';
import { AppButton, BtnVariant, EmptyState } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';

const CLAIM_STATUS: Map<string, string> = new Map<string, string>([
  ['pending', '待审核'],
  ['approved', '已通过'],
  ['rejected', '已驳回'],
  ['cancelled', '已取消']
]);

@Entry
@Component
struct ClaimReview {
  @State claims: ClaimItem[] = [];

  aboutToAppear(): void {
    this.load();
  }

  private async load(): Promise<void> {
    try {
      const all = await ApiRepo.fetchReceivedClaims();
      // 只显示待审核的；已处理的从列表消失
      this.claims = all.filter((c: ClaimItem) => c.status === 'pending');
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  private async doHandle(id: string, status: string): Promise<void> {
    try {
      await ApiRepo.handleClaim(id, status);
      Toast.show(status === 'approved' ? '已通过' : '已驳回');
      // 乐观更新：立即从待审核列表移除
      this.claims = this.claims.filter((c: ClaimItem) => c.id !== id);
      // 重新拉取确认
      await this.load();
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('认领审核').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      if (this.claims.length === 0) {
        EmptyState({ icon: 'hand_stop', title: '暂无认领申请', desc: '别人申请认领你的物品时会显示在这里' })
      } else {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.claims, (c: ClaimItem) => {
              Column({ space: 8 }) {
                Text('认领 · ' + c.postTitle).fontSize($r('app.float.font_body')).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_near_black'))
                Text('申请人：' + c.claimant).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_olive'))
                Text(c.desc).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
                if (c.verifyAnswer) {
                  Text('验证回答：' + c.verifyAnswer).fontSize($r('app.float.font_caption')).fontColor($r('app.color.status_pending'))
                }
                Row({ space: 12 }) {
                  Text(CLAIM_STATUS.get(c.status) ?? c.status).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
                  if (c.status === 'pending') {
                    Row({ space: 8 }) {
                      AppButton({ text: '驳回', variant: BtnVariant.SECONDARY, onTap: () => this.doHandle(c.id, 'rejected') })
                      AppButton({ text: '通过', onTap: () => this.doHandle(c.id, 'approved') })
                    }
                  }
                }
                .width('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
              }
              .width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
              .alignItems(HorizontalAlign.Start)
            }, (c: ClaimItem) => c.id)
          }.padding(16)
        }.layoutWeight(1)
      }
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
