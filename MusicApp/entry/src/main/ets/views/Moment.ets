/**
 * 动态页（F05）：互动广场
 * 每条动态含头像 / 内容 / 内嵌歌曲卡片 / 评论·点赞·分享计数（Badge）。
 * 内嵌歌曲卡片可点击播放。
 */
import { router } from '@kit.ArkUI';
import { Colors, Font, Radius, Space } from '../theme/AppTheme';
import { MomentListType, SongItemType } from '../models/index';
import { musicRepository } from '../services/index';
import { AVPlayerManager } from '../utils/AVPlayerManager';
import { CoverImage, IconSlot } from '../components/common';

@Component
export struct Moment {
  @State moments: MomentListType[] = [];

  aboutToAppear(): void {
    musicRepository.getMomentList().then((d: MomentListType[]) => {
      this.moments = d;
    });
  }

  // 点击内嵌歌曲：单曲播放并进入播放页
  private playSong(song: SongItemType): void {
    AVPlayerManager.getInstance().singPlay(song, [song]);
    router.pushUrl({ url: 'pages/Play' });
  }

  build() {
    Scroll() {
      Column() {
        Text('动态')
          .fontSize(Font.title)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
          .alignSelf(ItemAlign.Start)
          .padding({ top: Space.xl, bottom: Space.md })

        ForEach(
          this.moments,
          (m: MomentListType) => {
            Column() {
              // 头部：头像 + 昵称
              Row() {
                // 头像占位（预留真实头像资源位置）
                Column() {
                  Text(m.author.charAt(0))
                    .fontSize(Font.body)
                    .fontColor(Colors.textPrimary)
                    .fontWeight(FontWeight.Bold)
                }
                .width(40)
                .height(40)
                .justifyContent(FlexAlign.Center)
                .backgroundColor(m.avatarColor)
                .borderRadius(Radius.circle)

                Text(m.author)
                  .margin({ left: Space.sm })
                  .fontSize(Font.caption)
                  .fontColor(Colors.textPrimary)
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')

              // 正文
              Text(m.content)
                .margin({ top: Space.sm })
                .width('100%')
                .fontSize(Font.caption)
                .fontColor(Colors.textSecondary)

              // 内嵌歌曲卡片（可点击播放）
              Row() {
                CoverImage({ color: m.song.color, radius: Radius.card, img: m.song.img })
                  .width(48)
                  .height(48)
                Column() {
                  Text(m.song.title)
                    .fontSize(Font.caption)
                    .fontColor(Colors.textPrimary)
                    .fontWeight(FontWeight.Bold)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                  Text(m.song.artist)
                    .margin({ top: 4 })
                    .fontSize(Font.small)
                    .fontColor(Colors.textSecondary)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)
                .margin({ left: Space.sm })
                // 播放图标：接入 player_play
                IconSlot({ iconSize: 36, icon: $r('app.media.player_play'), label: '播放', bg: Colors.surfaceMid, fg: Colors.textPrimary })
                  .onClick(() => {
                    this.playSong(m.song);
                  })
              }
              .width('100%')
              .padding(Space.sm)
              .backgroundColor(Colors.surface)
              .borderRadius(Radius.card)
              .margin({ top: Space.sm })

              // 计数（赞 / 评 / 分享）
              Row() {
                Text('赞 ' + m.like).fontSize(Font.small).fontColor(Colors.textSecondary)
                Text('评 ' + m.comment).margin({ left: Space.lg }).fontSize(Font.small).fontColor(Colors.textSecondary)
                Text('分享 ' + m.share).margin({ left: Space.lg }).fontSize(Font.small).fontColor(Colors.textSecondary)
              }
              .width('100%')
              .margin({ top: Space.sm })
            }
            .width('100%')
            .padding(Space.md)
            .backgroundColor(Colors.surface)
            .borderRadius(Radius.card)
            .margin({ bottom: Space.md })
          },
          (m: MomentListType) => m.id
        )
      }
      .width('100%')
      .padding({ left: Space.xxl, right: Space.xxl, bottom: 150 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bg)
  }
}
