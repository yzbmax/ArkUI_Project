/**
 * 动态卡片组件（DESIGN.md 5.2）—— 失物 / 寻物通用。
 */
import { Post } from '../../shared/mock/Models';
import { STATUS_LABEL, STATUS_COLOR, PostType } from '../../shared/constants/Constants';
import { StatusTag, CreditBadge, AvatarPlaceholder } from './UI';
import { Icon } from './Icon';
import { hexToTint, TINT } from './tint';

@Component
export struct PostCard {
  @Prop post: Post;
  onTap: (id: string) => void = () => {};
  onClaim: (id: string) => void = () => {};
  @State showPreview: boolean = false;

  build() {
    Column() {
      // 头部：发布者 + 状态 + 时间
      Row() {
        Row({ space: 8 }) {
          AvatarPlaceholder({ iconSize: 32 })
          if (!this.post.anonymous) {
            Row({ space: 6 }) {
              Text(this.post.author).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_near_black'))
              CreditBadge({ level: this.post.creditLevel })
            }.alignItems(VerticalAlign.Center)
          } else {
            Text('匿名用户').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
          }
        }
        .alignItems(VerticalAlign.Center)
        Row({ space: 8 }) {
          if (this.post.urgent) {
            Text('急')
              .fontSize($r('app.float.font_label'))
              .fontColor($r('app.color.text_on_brand'))
              .backgroundColor($r('app.color.status_urgent'))
              .padding({ left: 6, right: 6, top: 2, bottom: 2 })
              .borderRadius($r('app.float.radius_sharp'))
          }
          StatusTag({
            label: STATUS_LABEL.get(this.post.status) ?? this.post.status,
            color: STATUS_COLOR.get(this.post.status) ?? $r('app.color.status_closed')
          })
        }
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      // 标题
      Text(this.post.title)
        .fontSize($r('app.float.font_h2'))
        .fontFamily('Noto Serif SC')
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_near_black'))
        .width('100%')
        .margin({ top: 8, bottom: 4 })
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 描述（两行截断）
      Text(this.post.desc)
        .fontSize($r('app.float.font_body'))
        .fontColor($r('app.color.text_olive'))
        .width('100%')
        .lineHeight('26vp')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .margin({ bottom: 8 })

      // 首图（点击查看大图）
      if (this.post.images.length > 0) {
        Image(this.post.images[0])
          .width('100%')
          .height(160)
          .objectFit(ImageFit.Cover)
          .borderRadius($r('app.float.radius_feature'))
          .margin({ bottom: 8 })
          .onClick(() => { this.showPreview = true; })
      }

      // 地点 + 分类
      Row({ space: 12 }) {
        Row({ space: 4 }) {
          Icon({ name: 'map_pin', iconSize: 14, tint: TINT.TEXT_STONE })
          Text(this.post.location).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
        }
        .alignItems(VerticalAlign.Center)
        StatusTag({ label: this.post.categoryName, color: $r('app.color.text_charcoal') })
        if (this.post.reward) {
          StatusTag({ label: '悬赏 ' + this.post.reward, color: $r('app.color.status_reward') })
        }
      }
      .width('100%')
      .margin({ bottom: 10 })
      .alignItems(VerticalAlign.Center)

      // 互动栏 + 主按钮
      Row() {
        Row({ space: 16 }) {
          Row({ space: 4 }) {
            Icon({ name: 'chat_bubble', iconSize: 16, tint: TINT.TEXT_STONE })
            Text(this.post.comments.toString()).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
          }
          .alignItems(VerticalAlign.Center)
          Row({ space: 4 }) {
            Icon({ name: 'heart', iconSize: 16, tint: this.post.liked ? TINT.BRAND_TERRACOTTA : TINT.TEXT_STONE })
            Text(this.post.likes.toString()).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
          }
          .alignItems(VerticalAlign.Center)
        }
        .alignItems(VerticalAlign.Center)
        if (this.post.status === 'processing' || this.post.status === 'pending') {
          Button(this.post.type === PostType.LOST ? '认领' : '提供线索')
            .height(32)
            .backgroundColor($r('app.color.brand_terracotta'))
            .fontColor($r('app.color.text_on_brand'))
            .fontSize($r('app.float.font_body_small'))
            .borderRadius($r('app.float.radius_generous'))
            .onClick(() => this.onClaim(this.post.id))
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .backgroundColor($r('app.color.bg_ivory'))
    .borderRadius($r('app.float.radius_feature'))
    .border({ width: 1, color: $r('app.color.border_cream') })
    .shadow({ radius: 12, color: '#26000000', offsetY: 4 })
    .onClick(() => this.onTap(this.post.id))
    .bindContentCover(this.showPreview, this.previewBuilder(), {})
  }

  /** 图片大图预览：全屏黑底 + 大图 + 点击任意处关闭 */
  @Builder
  previewBuilder() {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.post.images[0])
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
