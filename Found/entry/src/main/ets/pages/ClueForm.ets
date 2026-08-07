/**
 * 提供线索页（P13）—— 线索提供表单。
 */
import { ApiRepo } from '../shared/api/ApiRepo';
import { Post } from '../shared/mock/Models';
import { AppButton } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';

interface RouteParams {
  postId?: string;
}

@Entry
@Component
struct ClueForm {
  @State post: Post | null = null;
  @State content: string = '';
  @State submitting: boolean = false;

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as RouteParams;
    const id: string = params?.postId ?? '';
    if (id) {
      ApiRepo.getPost(id).then((p: Post) => {
        this.post = p;
      }).catch((e: Error) => Toast.show(e.message));
    }
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('提供线索').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          // 物品信息
          if (this.post) {
            Row({ space: 12 }) {
              if (this.post.images.length > 0) {
                Image(this.post.images[0]).width(64).height(64).objectFit(ImageFit.Cover).borderRadius($r('app.float.radius_generous'))
              }
              Column({ space: 4 }) {
                Text(this.post.title).fontSize($r('app.float.font_body')).fontWeight(FontWeight.Bold).fontColor($r('app.color.text_near_black'))
                Text('失主：' + this.post.author).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }
            .width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
            .alignItems(VerticalAlign.Center)
          }

          Column({ space: 6 }) {
            Text('线索描述*').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black')).alignSelf(ItemAlign.Start)
            TextInput({ placeholder: '在哪里看到/捡到的、当前状态等（≥10字）', text: this.content })
              .onChange((v) => this.content = v)
              .height(120).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
          }.alignItems(HorizontalAlign.Start)

          AppButton({ text: '提交线索', full: true, loading: this.submitting, onTap: () => this.submit() })
        }.padding(16)
      }.layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }

  private async submit(): Promise<void> {
    const id = this.post?.id ?? '';
    if (!id) {
      Toast.show('物品信息加载中，请稍候');
      return;
    }
    if (this.content.trim().length < 10) {
      Toast.show('线索描述至少 10 字');
      return;
    }
    this.submitting = true;
    try {
      await ApiRepo.submitClue(id, this.content.trim());
      Toast.show('线索已提交');
      this.getUIContext().getRouter().back();
    } catch (e) {
      Toast.show((e as Error).message);
    } finally {
      this.submitting = false;
    }
  }
}
