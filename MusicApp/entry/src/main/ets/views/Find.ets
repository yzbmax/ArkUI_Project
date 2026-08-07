/**
 * 发现页（F04）：猜你喜欢歌曲列表 + 真实搜索
 * 点击歌曲 → 调用播放器并跳转播放页；搜索框回车调用 iTunes 真实搜索。
 */
import { router } from '@kit.ArkUI';
import { Colors, Font, Radius, Space } from '../theme/AppTheme';
import { SongItemType } from '../models/index';
import { musicRepository } from '../services/index';
import { AVPlayerManager } from '../utils/AVPlayerManager';
import { SongItemRow } from '../components/SongItemRow';
import { IconSlot } from '../components/common';

@Component
export struct Find {
  @State songs: SongItemType[] = [];
  @State keyword: string = '';

  aboutToAppear(): void {
    // 默认加载一批真实歌曲（iTunes 默认关键词）
    this.loadDefault();
  }

  // 默认内容（真实数据源的默认关键词）
  private loadDefault(): void {
    musicRepository.getSongList().then((d: SongItemType[]) => {
      this.songs = d;
    });
  }

  // 搜索：调用真实数据源（iTunes Search）
  private doSearch(): void {
    const kw = this.keyword.trim();
    if (kw.length === 0) {
      this.loadDefault();
      return;
    }
    musicRepository.searchSongs(kw).then((d: SongItemType[]) => {
      this.songs = d;
    });
  }

  // 点击播放：单曲播放并进入播放页
  private playSong(song: SongItemType): void {
    AVPlayerManager.getInstance().singPlay(song, this.songs);
    router.pushUrl({ url: 'pages/Play' });
  }

  build() {
    Scroll() {
      Column() {
        // 页面大标题（一级标题：白色 Bold 28）
        Text('发现')
          .fontSize(Font.title)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
          .alignSelf(ItemAlign.Start)
          .padding({ top: Space.xl, bottom: Space.md })

        // 搜索框（#121212 底 + 12vp 圆角；图标与文字左对齐）
        Row() {
          IconSlot({ iconSize: 20, icon: $r('app.media.search'), label: '', bg: Colors.transparent })
          TextInput({ placeholder: '搜索歌曲、歌手...', text: this.keyword })
            .layoutWeight(1)
            .backgroundColor(Colors.transparent)
            .placeholderColor(Colors.textSecondary)
            .fontColor(Colors.textPrimary)
            .fontSize(Font.body)
            .margin({ left: Space.sm })
            .onChange((v: string) => {
              this.keyword = v;
            })
            .onSubmit(() => {
              this.doSearch();
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .padding({ left: Space.md, right: Space.md, top: Space.sm, bottom: Space.sm })
        .backgroundColor(Colors.surface) // 深灰 #121212
        .borderRadius(Radius.card)       // 统一 12vp 圆角
        .margin({ bottom: Space.xl })

        // 歌曲列表（行内 SongItemRow 自带整行点击 / 正方形封面 / 分割线）
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
      }
      .width('100%')
      .padding({ left: Space.xxl, right: Space.xxl, bottom: 150 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bg)
  }
}
