/**
 * 认领页（P12）—— 认领申请表单：认领说明 + 验证问题作答。
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
struct ClaimForm {
  @State post: Post | null = null;
  @State desc: string = '';
  @State answer: string = '';
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
        Text('认领物品').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
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
                Text('发布者：' + this.post.author).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            }
            .width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
            .alignItems(VerticalAlign.Center)
          }

          Column({ space: 6 }) {
            Text('认领说明*').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black')).alignSelf(ItemAlign.Start)
            TextInput({ placeholder: '描述物品特征以证明是你的（≥20字）', text: this.desc })
              .onChange((v) => this.desc = v)
              .height(100).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
          }.alignItems(HorizontalAlign.Start)

          // 验证问题（发布者设置了才显示）
          if (this.post && this.post.verifyQuestion) {
            Column({ space: 6 }) {
              Text('验证问题*').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black')).alignSelf(ItemAlign.Start)
              Text(this.post.verifyQuestion).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_olive')).alignSelf(ItemAlign.Start)
              TextInput({ placeholder: '回答发布者设置的问题', text: this.answer })
                .onChange((v) => this.answer = v)
                .height(48).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
            }.alignItems(HorizontalAlign.Start)
          }

          AppButton({ text: '提交认领申请', full: true, loading: this.submitting, onTap: () => this.submit() })
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
    if (this.desc.trim().length < 20) {
      Toast.show('认领说明至少 20 字');
      return;
    }
    if (this.post!.verifyQuestion && !this.answer.trim()) {
      Toast.show('请回答验证问题');
      return;
    }
    this.submitting = true;
    try {
      await ApiRepo.submitClaim(id, this.desc.trim(), this.answer.trim());
      Toast.show('认领申请已提交');
      this.getUIContext().getRouter().back();
    } catch (e) {
      Toast.show((e as Error).message);
    } finally {
      this.submitting = false;
    }
  }
}
