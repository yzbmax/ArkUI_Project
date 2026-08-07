/**
 * 动态详情（C302）+ 评论互动（C303）+ 点赞（C304）+ 认领入口（C305）。
 * 前端 Mock 实现，数据来自 MockRepo。
 */
import { ROUTES } from '../shared/constants/Routes';
import { ApiRepo } from '../shared/api/ApiRepo';
import { Post, Comment } from '../shared/mock/Models';
import { STATUS_LABEL, STATUS_COLOR, PostType } from '../shared/constants/Constants';
import { StatusTag, CreditBadge, AppButton, BtnVariant, AvatarPlaceholder } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';
import { AppStore } from '../shared/store/AppStore';

/** 路由参数。ArkTS 不支持 Record 作为断言目标类型。 */
interface RouteParams {
  id?: string;
}

const REPORT_REASONS: string[] = ['虚假信息', '冒领行为', '骚扰信息', '不良内容', '其他'];
const REPORT_CODES: string[] = ['fake', 'fraud', 'harass', 'inappropriate', 'other'];

@Entry
@Component
struct PostDetail {
  @State post: Post | null = null;
  @State comment: string = '';
  @State replyToName: string = '';
  @State replyToUserId: string = '';
  @State replyParentId: string = '';
  @State showPreview: boolean = false;
  @State previewImg: string = '';
  @State showReport: boolean = false;

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as RouteParams;
    const id: string = params?.id ?? '';
    ApiRepo.getPost(id).then((p: Post) => {
      this.post = p;
      // 记录浏览足迹（P19）
      AppStore.addFootprint(p.id);
    }).catch((e: Error) => {
      Toast.show(e.message);
    });
  }

  /** 进入回复模式：点击顶层评论 parentId=自身；点击楼中楼回复仍挂在顶层下 */
  private startReply(name: string, uid: string, parentId: string): void {
    this.replyToName = name;
    this.replyToUserId = uid;
    this.replyParentId = parentId;
  }

  private cancelReply(): void {
    this.replyToName = '';
    this.replyToUserId = '';
    this.replyParentId = '';
  }

  private async doLike(): Promise<void> {
    const id = this.post?.id ?? '';
    if (!id) {
      return;
    }
    try {
      const p = await ApiRepo.toggleLike(id);
      this.post = p;
      Toast.show(p.liked ? '已点赞' : '已取消');
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  private async doCollect(): Promise<void> {
    const id = this.post?.id ?? '';
    if (!id) {
      return;
    }
    try {
      const p = await ApiRepo.toggleCollect(id);
      this.post = p;
      Toast.show(p.collected ? '已收藏' : '已取消收藏');
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  @Builder
  CommentItem(c: Comment, isReply: boolean, parentId: string) {
    Row({ space: 8 }) {
      AvatarPlaceholder({ iconSize: 28 })
      Column({ space: 4 }) {
        Row({ space: 6 }) {
          Text(c.author).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_charcoal'))
          if (c.replyTo) {
            Text('回复 ' + c.replyTo).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
          }
        }
        Text(c.content).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
        Text(c.time).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
      }
      .layoutWeight(1).alignItems(HorizontalAlign.Start)
    }
    .width('100%').padding(isReply ? { left: 36, top: 8 } : { top: 8 })
    .onClick(() => { this.startReply(c.author, c.userId, isReply ? parentId : c.id); })
  }

  build() {
    if (!this.post) {
      Column().width('100%').height('100%')
    } else {
    Column() {
      // 顶部栏
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK })
          .onClick(() => this.getUIContext().getRouter().back())
        Text('详情').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
        Icon({ name: 'dots', iconSize: 20, tint: TINT.TEXT_STONE })
          .onClick(() => this.showReport = true)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 12 }) {
          // 发布者
          Row({ space: 8 }) {
            AvatarPlaceholder({ iconSize: 36 })
            if (!this.post!.anonymous) {
              Row({ space: 8 }) {
                Text(this.post!.author).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
                CreditBadge({ level: this.post!.creditLevel })
              }.alignItems(VerticalAlign.Center)
            } else {
              Text('匿名用户').fontSize($r('app.float.font_body')).fontColor($r('app.color.text_stone'))
            }
            Row({ space: 6 }) {
              if (this.post!.urgent) {
                Text('急').fontSize($r('app.float.font_label')).fontColor($r('app.color.text_on_brand'))
                  .backgroundColor($r('app.color.status_urgent')).padding({ left: 6, right: 6, top: 2, bottom: 2 }).borderRadius(4)
              }
              StatusTag({
                label: STATUS_LABEL.get(this.post!.status) ?? this.post!.status,
                color: STATUS_COLOR.get(this.post!.status) ?? $r('app.color.status_closed')
              })
            }
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .alignItems(VerticalAlign.Center)

          Text(this.post!.title).fontSize($r('app.float.font_h1')).fontFamily('Noto Serif SC').fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_near_black'))

          Text(this.post!.desc).fontSize($r('app.float.font_body'))
            .fontColor($r('app.color.text_olive')).lineHeight('26vp')

          // 图片（点击查看大图）
          if (this.post!.images.length > 0) {
            Grid() {
              ForEach(this.post!.images, (img: ResourceStr) => {
                GridItem() {
                  Image(img).width('100%').height(120).objectFit(ImageFit.Cover).borderRadius($r('app.float.radius_feature'))
                    .onClick(() => { this.previewImg = img.toString(); this.showPreview = true; })
                }
              }, (img: ResourceStr) => img.toString())
            }
            .columnsTemplate('1fr 1fr 1fr').rowsGap(8).columnsGap(8).width('100%')
          }

          // 地点 + 分类
          Row({ space: 12 }) {
            Row({ space: 4 }) {
              Icon({ name: 'map_pin', iconSize: 14, tint: TINT.TEXT_STONE })
              Text(this.post!.location).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
            }
            .alignItems(VerticalAlign.Center)
            StatusTag({ label: this.post!.categoryName, color: $r('app.color.text_charcoal') })
            if (this.post!.reward) {
              StatusTag({ label: '悬赏 ' + this.post!.reward, color: $r('app.color.status_reward') })
            }
          }
          .alignItems(VerticalAlign.Center)

          // 验证问题
          if (this.post!.verifyQuestion) {
            Row({ space: 8 }) {
              Icon({ name: 'info_circle', iconSize: 16, tint: TINT.STATUS_PENDING })
              Text('验证问题：' + this.post!.verifyQuestion).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_olive'))
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)
          }

          // 评论区
          Text('评论 (' + this.post!.comments + ')').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black'))
          ForEach(this.post!.commentList, (c: Comment) => {
            Column({ space: 4 }) {
              this.CommentItem(c, false, '')
              ForEach(c.replies, (r: Comment) => {
                this.CommentItem(r, true, c.id)
              }, (r: Comment) => r.id)
            }.alignItems(HorizontalAlign.Start)
          }, (c: Comment) => c.id)

          // 回复对象提示
          if (this.replyToName !== '') {
            Row({ space: 8 }) {
              Text('回复 @' + this.replyToName).fontSize($r('app.float.font_caption')).fontColor($r('app.color.brand_terracotta'))
              Icon({ name: 'x', iconSize: 14, tint: TINT.TEXT_STONE }).onClick(() => { this.cancelReply(); })
            }
            .width('100%').alignItems(VerticalAlign.Center)
          }

          // 评论输入
          Row({ space: 8 }) {
            TextInput({ placeholder: this.replyToName !== '' ? '回复 @' + this.replyToName + '...' : '写下你的评论...', text: this.comment })
              .onChange((v) => this.comment = v)
              .layoutWeight(1)
              .height(40)
              .backgroundColor($r('app.color.bg_ivory'))
              .borderRadius($r('app.float.radius_generous'))
            Button('发送')
              .height(40)
              .backgroundColor($r('app.color.brand_terracotta'))
              .fontColor($r('app.color.text_on_brand'))
              .fontSize($r('app.float.font_body_small'))
              .borderRadius($r('app.float.radius_generous'))
              .onClick(() => { this.doComment(); })
          }
          .width('100%')
        }
        .padding(16)
      }
      .layoutWeight(1)

      // 底部操作栏
      Row({ space: 16 }) {
        Row({ space: 4 }) {
          Icon({ name: 'heart', iconSize: 20, tint: this.post!.liked ? TINT.BRAND_TERRACOTTA : TINT.TEXT_STONE })
            .onClick(() => { this.doLike(); })
          Text(this.post!.likes.toString()).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
        }
        .alignItems(VerticalAlign.Center)
        Icon({ name: 'bookmark', iconSize: 20, tint: this.post!.collected ? TINT.BRAND_TERRACOTTA : TINT.TEXT_STONE })
          .onClick(() => { this.doCollect(); })
        if (this.post!.status === 'processing') {
          AppButton({
            text: this.post!.type === PostType.LOST ? '认领' : '提供线索',
            onTap: () => {
              const url = this.post!.type === PostType.LOST ? ROUTES.claim : ROUTES.clue;
              this.getUIContext().getRouter().pushUrl({ url: url, params: { postId: this.post!.id } });
            }
          })
        }
      }
      .width('100%').padding(16).backgroundColor($r('app.color.bg_ivory')).border({ width: { top: 1 }, color: $r('app.color.border_cream') })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
    .bindContentCover(this.showPreview, this.previewBuilder(), {})
    .bindSheet(this.showReport, this.reportSheet(), { height: 340 })
  }
  }

  private async doComment(): Promise<void> {
    const id = this.post?.id ?? '';
    if (!id) {
      return;
    }
    if (!this.comment.trim()) {
      Toast.show('请输入评论内容');
      return;
    }
    try {
      const isReply: boolean = this.replyParentId !== '';
      await ApiRepo.addComment(id, this.comment.trim(), this.replyParentId, this.replyToUserId);
      this.comment = '';
      this.cancelReply();
      const p = await ApiRepo.getPost(id);
      this.post = p;
      Toast.show(isReply ? '回复成功' : '评论成功');
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  private async doReport(label: string): Promise<void> {
    const id = this.post?.id ?? '';
    if (!id) {
      return;
    }
    const idx = REPORT_REASONS.indexOf(label);
    const code = REPORT_CODES[Math.max(0, idx)];
    this.showReport = false;
    try {
      await ApiRepo.reportPost(id, code, label);
      Toast.show('举报已提交，管理员将尽快处理');
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  @Builder
  reportSheet() {
    Column({ space: 12 }) {
      Text('举报动态').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      ForEach(REPORT_REASONS, (r: string) => {
        Row() {
          Text(r).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
        }
        .width('100%').padding(14).backgroundColor($r('app.color.bg_sand')).borderRadius($r('app.float.radius_feature'))
        .onClick(() => { this.doReport(r); })
      })
      AppButton({ text: '取消', variant: BtnVariant.SECONDARY, full: true, onTap: () => this.showReport = false })
    }.padding(24).width('100%')
  }

  /** 图片大图预览：全屏黑底 + 大图 + 点击任意处关闭 */
  @Builder
  previewBuilder() {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.previewImg)
        .width('100%').height('100%')
        .objectFit(ImageFit.Contain)
        .onClick(() => { this.showPreview = false; })
      Icon({ name: 'x', iconSize: 20, tint: TINT.WHITE })
        .position({ x: '90%', y: '6%' })
        .padding(8)
        .backgroundColor('#66000000')
        .borderRadius(20)
        .onClick(() => { this.showPreview = false; })
    }
    .width('100%').height('100%')
    .backgroundColor('#000000')
  }
}
