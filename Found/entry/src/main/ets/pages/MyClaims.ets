/**
 * 我的认领/线索（C603）—— 认领记录（待审核/已同意/已拒绝/已取消）、线索记录（有效/无效/待处理）。
 * 数据来自后端 ApiRepo.fetchMyClaims / fetchMyClues。
 */
import { ApiRepo } from '../shared/api/ApiRepo';
import { ClaimRecord, ClueRecord } from '../shared/mock/Models';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { EmptyState } from '../common/components/UI';
import { Toast } from '../common/utils/Toast';

type Sub = 'claim' | 'clue';

const SUBS: Sub[] = ['claim', 'clue'];

/** ArkTS 不支持内联对象字面量查表，改 Map。 */
const CLAIM_LABEL: Map<string, string> = new Map<string, string>([
  ['pending', '待审核'],
  ['agreed', '已同意'],
  ['rejected', '已拒绝'],
  ['cancelled', '已取消']
]);

const CLUE_LABEL: Map<string, string> = new Map<string, string>([
  ['valid', '有效'],
  ['invalid', '无效'],
  ['pending', '待处理']
]);

@Entry
@Component
struct MyClaims {
  @State sub: Sub = 'claim';
  @State claims: ClaimRecord[] = [];
  @State clues: ClueRecord[] = [];

  aboutToAppear(): void {
    this.load();
  }

  private async load(): Promise<void> {
    try {
      this.claims = await ApiRepo.fetchMyClaims();
      this.clues = await ApiRepo.fetchMyClues();
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  private claimLabel(s: string): string {
    return CLAIM_LABEL.get(s) ?? s;
  }
  private clueLabel(s: string): string {
    return CLUE_LABEL.get(s) ?? s;
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('我的认领 / 线索').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      Row({ space: 20 }) {
        ForEach(SUBS, (s: Sub) => {
          Column({ space: 4 }) {
            Text(s === 'claim' ? '认领记录' : '线索记录')
              .fontSize($r('app.float.font_subtitle'))
              .fontColor(this.sub === s ? $r('app.color.brand_terracotta') : $r('app.color.text_stone'))
              .fontWeight(this.sub === s ? FontWeight.Bold : FontWeight.Normal)
            if (this.sub === s) {
              Row().width(20).height(3).backgroundColor($r('app.color.brand_terracotta')).borderRadius(2)
            }
          }.onClick(() => this.sub = s)
        })
      }.width('100%').padding({ left: 16, bottom: 8 })

      Scroll() {
        Column({ space: 8 }) {
          if (this.sub === 'claim') {
            if (this.claims.length === 0) {
              EmptyState({ icon: 'hand_stop', title: '暂无认领记录', desc: '去动态页发起认领吧' })
            } else {
              ForEach(this.claims, (c: ClaimRecord) => {
                Row({ space: 12 }) {
                  Column({ space: 4 }) {
                    Text(c.postTitle).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
                    Text(c.desc).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone')).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(c.time).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
                  }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                  Text(this.claimLabel(c.status)).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
                }.width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
              }, (c: ClaimRecord) => c.id)
            }
          } else {
            if (this.clues.length === 0) {
              EmptyState({ icon: 'search_bag', title: '暂无线索记录', desc: '去动态页提供线索吧' })
            } else {
              ForEach(this.clues, (c: ClueRecord) => {
                Row({ space: 12 }) {
                  Column({ space: 4 }) {
                    Text(c.postTitle).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
                    Text(c.desc).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone')).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(c.time).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
                  }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                  Text(this.clueLabel(c.status)).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
                }.width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
              }, (c: ClueRecord) => c.id)
            }
          }
        }.padding(16)
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
