/**
 * 全局迷你播放条（F10）
 * 首页底部浮层，任意 Tab 可见；与全局播放态（AppStorage SONG_KEY）同步。
 * 仅当后台有歌曲载入时才显示；无音乐时整条隐藏。
 * 点击整条展开播放页；点击播放/暂停键切换播放状态（按钮带轻微透明度）。
 */
import { router } from '@kit.ArkUI';
import { Colors, Font, Radius, Shadow } from '../theme/AppTheme';
import { PlayState } from '../models/index';
import { SONG_KEY } from '../contants/index';
import { AVPlayerManager } from '../utils/AVPlayerManager';
import { CoverImage, IconSlot } from './common';

@Component
export struct MiniBar {
  @StorageLink(SONG_KEY) playState: PlayState = new PlayState();

  build() {
    // 仅当后台有歌曲载入时才显示迷你条；无音乐时整条隐藏，内容铺满底部
    if (this.playState.title.length > 0) {
      Row() {
        // 封面（预留真实图片位置由 CoverImage 内部处理）
        CoverImage({ color: this.playState.color, radius: Radius.card, img: this.playState.img })
          .width(40)
          .height(40)

        // 歌名 + 歌手
        Column() {
          Text(this.playState.title)
            .fontSize(Font.caption)
            .fontColor(Colors.textPrimary)
            .fontWeight(FontWeight.Bold)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.playState.artist)
            .fontSize(Font.small)
            .fontColor(Colors.textSecondary)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        .margin({ left: 12, right: 12 })

        // 播放 / 暂停：按播放态切换图标（按钮带轻微透明度）
        IconSlot({
          iconSize: 40,
          icon: this.playState.isPlay ? $r('app.media.player_pause') : $r('app.media.player_play'),
          label: this.playState.isPlay ? '暂停' : '播放',
          bg: Colors.accent,
          fg: Colors.bg,
        })
          .opacity(0.85) // 略微透明，露出后方内容
          .onClick(() => {
            AVPlayerManager.getInstance().toggle();
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 12, right: 12 })
      .margin({ bottom: 5 })
      .backgroundColor('rgba(18, 18, 18, 0.55)') // 半透明 + 磨砂，可见后方内容
      .backdropBlur(20)
      .shadow(Shadow.card) // 卡片抬升阴影
      .onClick(() => {
        // 展开播放页
        router.pushUrl({ url: 'pages/Play' });
      })
    }
  }
}
