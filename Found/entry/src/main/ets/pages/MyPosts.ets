/**
 * 我的发布（C602）—— 按状态分组（待审核/进行中/已完结/已关闭）；关闭二次确认。
 */
import { ApiRepo } from '../shared/api/ApiRepo';
import { Post } from '../shared/mock/Models';
import { PostStatus, STATUS_LABEL, STATUS_COLOR } from '../shared/constants/Constants';
import { StatusTag, AppButton, BtnVariant } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';

/** 状态分组。ArkTS 要求对象字面量对应显式声明的类/接口。 */
interface PostGroup {
  key: PostStatus;
  list: Post[];
}

@Entry
@Component
struct MyPosts {
  @State groups: PostGroup[] = [];
  @State closeId: string = '';

  aboutToAppear(): void {
    this.loadGroups();
  }

  private async loadGroups(): Promise<void> {
    try {
      const g: PostGroup[] = [];
      g.push({ key: PostStatus.PENDING, list: await ApiRepo.myPosts('pending') });
      g.push({ key: PostStatus.PROCESSING, list: await ApiRepo.myPosts('processing') });
      g.push({ key: PostStatus.RESOLVED, list: await ApiRepo.myPosts('resolved') });
      g.push({ key: PostStatus.CLOSED, list: await ApiRepo.myPosts('closed') });
      this.groups = g;
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('我的发布').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 20 }) {
          ForEach(this.groups, (g: PostGroup) => {
            Column({ space: 8 }) {
              Text(STATUS_LABEL.get(g.key) ?? g.key).fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black'))
              ForEach(g.list, (p: Post) => {
                Row({ space: 12 }) {
                  Image(p.images[0] ?? $r('app.media.background')).width(56).height(56).objectFit(ImageFit.Cover).borderRadius($r('app.float.radius_generous'))
                  Column({ space: 4 }) {
                    Text(p.title).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black')).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                    Row({ space: 8 }) {
                      StatusTag({
                        label: STATUS_LABEL.get(p.status) ?? p.status,
                        color: STATUS_COLOR.get(p.status) ?? $r('app.color.status_closed')
                      })
                      if (p.status === PostStatus.PENDING && p.rejectReason) {
                        Text('驳回：' + p.rejectReason).fontSize($r('app.float.font_caption')).fontColor($r('app.color.status_error')).onClick(() => {
                          // 复制驳回理由
                        })
                      }
                    }
                  }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                  if (p.status === PostStatus.PROCESSING || p.status === PostStatus.PENDING) {
                    Text('关闭').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.status_error'))
                      .onClick(() => { this.closeId = p.id; })
                  }
                }
                .width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
                .alignItems(VerticalAlign.Center)
              }, (p: Post) => p.id)
            }.alignItems(HorizontalAlign.Start)
          })
        }.padding(16)
      }.layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
    .bindSheet(this.closeId !== '', this.buildConfirm(), {})
  }

  @Builder
  buildConfirm() {
    Column({ space: 16 }) {
      Text('确认关闭该动态？').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      Text('关闭后他人将无法看到，可在重新发布时再次提交审核。').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
      Row({ space: 12 }) {
        AppButton({ text: '取消', variant: BtnVariant.SECONDARY, onTap: () => this.closeId = '' })
        AppButton({ text: '关闭', variant: BtnVariant.DANGER, onTap: () => {
          this.doClose();
        } })
      }.width('100%')
    }.padding(24).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
  }

  private async doClose(): Promise<void> {
    try {
      await ApiRepo.closePost(this.closeId);
      this.closeId = '';
      Toast.show('已关闭');
      await this.loadGroups();
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }
}
