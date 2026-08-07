/**
 * 线索管理（失主）—— 我收到的线索，可标记有效/无效。
 */
import { ApiRepo, ClueItem } from '../shared/api/ApiRepo';
import { AppButton, BtnVariant, EmptyState } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';

@Entry
@Component
struct ClueReview {
  @State clues: ClueItem[] = [];

  aboutToAppear(): void {
    this.load();
  }

  private async load(): Promise<void> {
    try {
      this.clues = await ApiRepo.fetchReceivedClues();
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  private async doHandle(id: string, helpful: boolean): Promise<void> {
    try {
      await ApiRepo.handleClue(id, helpful);
      Toast.show(helpful ? '已标记有效' : '已标记无效');
      // 乐观更新：本地立即改状态，再拉取确认
      this.clues = this.clues.map((c: ClueItem) => {
        if (c.id === id) {
          const nc: ClueItem = {
            id: c.id, postId: c.postId, postTitle: c.postTitle,
            provider: c.provider, content: c.content, helpful: helpful, time: c.time
          };
          return nc;
        }
        return c;
      });
      await this.load();
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('线索管理').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      if (this.clues.length === 0) {
        EmptyState({ icon: 'search_bag', title: '暂无线索', desc: '别人提供你寻物动态的线索时会显示在这里' })
      } else {
        Scroll() {
          Column({ space: 8 }) {
            ForEach(this.clues, (c: ClueItem) => {
              Column({ space: 8 }) {
                Text('线索 · ' + c.postTitle).fontSize($r('app.float.font_body')).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_near_black'))
                Text('提供者：' + c.provider).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_olive'))
                Text(c.content).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
                Row({ space: 12 }) {
                  Text(c.helpful ? '已标记有效' : '待处理').fontSize($r('app.float.font_body_small'))
                    .fontColor(c.helpful ? $r('app.color.status_resolved') : $r('app.color.text_stone'))
                  Row({ space: 8 }) {
                    AppButton({ text: '无效', variant: BtnVariant.SECONDARY, onTap: () => this.doHandle(c.id, false) })
                    AppButton({ text: '有效', onTap: () => this.doHandle(c.id, true) })
                  }
                }
                .width('100%').justifyContent(FlexAlign.SpaceBetween).alignItems(VerticalAlign.Center)
              }
              .width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
              .alignItems(HorizontalAlign.Start)
            }, (c: ClueItem) => c.id)
          }.padding(16)
        }.layoutWeight(1)
      }
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
