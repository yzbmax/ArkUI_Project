/**
 * 歌单详情页（F03 衍生）
 * 由推荐页的歌单/每日推荐卡片点击进入，传入 title 作为 iTunes 搜索词拉取真实歌曲列表。
 * 点击歌曲或「播放全部」进入播放页（复用全局播放器）。
 */
import { router } from '@kit.ArkUI';
import { Colors, Font, Radius, Space } from '../theme/AppTheme';
import { SongItemType } from '../models/index';
import { musicRepository } from '../services/index';
import { AVPlayerManager } from '../utils/AVPlayerManager';
import { SongItemRow } from '../components/SongItemRow';
import { CoverImage, IconSlot } from '../components/common';

// 跳转参数
interface PlaylistParams {
  title: string;
}

@Entry
@Component
export struct Playlist {
  @State title: string = '歌单';
  @State songs: SongItemType[] = [];
  @State cover: string = '';
  @State loading: boolean = true;

  aboutToAppear(): void {
    const params = router.getParams() as PlaylistParams;
    this.title = params.title ? params.title : '歌单';
    musicRepository.searchSongs(this.title).then((d: SongItemType[]) => {
      this.songs = d;
      if (d.length > 0) {
        this.cover = d[0].img;
      }
      this.loading = false;
    });
  }

  // 点击播放：单曲播放并进入播放页
  private playSong(song: SongItemType): void {
    AVPlayerManager.getInstance().singPlay(song, this.songs);
    try {
      router.pushUrl({ url: 'pages/Play' });
    } catch (e) {
      // 忽略跳转异常（如页面已销毁）
    }
  }

  // 播放全部
  private playAll(): void {
    if (this.songs.length === 0) {
      return;
    }
    this.playSong(this.songs[0]);
  }

  build() {
    Column() {
      // 顶部栏：返回 + 标题
      Row() {
        IconSlot({ iconSize: 28, icon: $r('app.media.arrow_left'), label: '', bg: Colors.transparent })
          .onClick(() => {
            router.back();
          })
        Text(this.title)
          .fontSize(Font.head)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
          .layoutWeight(1)
          .margin({ left: Space.md })
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .width('100%')
      .padding({ left: Space.lg, right: Space.lg, top: Space.lg, bottom: Space.md })

      // 头部：封面 + 歌单信息
      Row() {
        if (this.cover.length > 0) {
          CoverImage({ color: Colors.surfaceMid, radius: Radius.card, img: this.cover })
            .width(110)
            .height(110)
        } else {
          CoverImage({ color: Colors.surfaceMid, radius: Radius.card, text: this.title.length > 0 ? this.title.charAt(0) : '' })
            .width(110)
            .height(110)
        }
        Column() {
          Text(this.title)
            .fontSize(Font.title)
            .fontWeight(FontWeight.Bold)
            .fontColor(Colors.textPrimary)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.songs.length + ' 首')
            .fontSize(Font.caption)
            .fontColor(Colors.textSecondary)
            .margin({ top: Space.sm })
          Row() {
            IconSlot({ iconSize: 18, icon: $r('app.media.player_play'), label: '', bg: Colors.transparent })
            Text('播放全部')
              .fontSize(Font.caption)
              .fontColor(Colors.textPrimary)
              .margin({ left: Space.sm })
          }
          .padding({ left: Space.md, right: Space.md, top: Space.sm, bottom: Space.sm })
          .backgroundColor(Colors.surfaceMid)
          .borderRadius(Radius.pill)
          .margin({ top: Space.md })
          .onClick(() => {
            this.playAll();
          })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .height(110)
        .margin({ left: Space.lg })
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .padding({ left: Space.lg, right: Space.lg })

      // 歌曲列表
      Scroll() {
        Column() {
          ForEach(
            this.songs,
            (item: SongItemType) => {
              SongItemRow({
                color: item.color,
                img: item.img,
                title: item.title,
                artist: item.artist,
                onPlay: () => {
                  this.playSong(item);
                },
              })
            },
            (item: SongItemType) => item.id
          )
          if (this.songs.length === 0 && !this.loading) {
            Text('暂无歌曲')
              .fontSize(Font.caption)
              .fontColor(Colors.textSecondary)
              .alignSelf(ItemAlign.Center)
              .margin({ top: Space.xl })
          }
        }
        .width('100%')
        .padding({ left: Space.lg, right: Space.lg, bottom: Space.xl })
      }
      .layoutWeight(1)
      .width('100%')
      .backgroundColor(Colors.bg)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bg)
  }
}
