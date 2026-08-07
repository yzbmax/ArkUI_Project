/**
 * 歌曲行（列表用）
 * 封面 + 标题 + 歌手 + 播放按钮（预留图标位置）。
 * 点击播放按钮触发 onPlay 回调（由父视图调用播放器并跳转）。
 */
import { Colors, Font, Radius, Space } from '../theme/AppTheme';
import { CoverImage, IconSlot } from './common';

@Component
export struct SongItemRow {
  @Prop color: string = Colors.surfaceMid;
  @Prop title: string = '';
  @Prop artist: string = '';
  @Prop img?: string; // 真实封面 URL（网络图片）
  onPlay: () => void = () => {}; // 播放回调

  build() {
    Row() {
      // 封面：正方形，8vp 圆角
      CoverImage({ color: this.color, radius: Radius.cover, img: this.img })
        .width(48)
        .height(48)

      // 中间文字：歌名（白 Medium 16）在上、歌手（浅灰 14）在下，左对齐
      Column() {
        Text(this.title)
          .fontSize(Font.body)
          .fontColor(Colors.textPrimary)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.artist)
          .margin({ top: 2 })
          .fontSize(Font.caption)
          .fontColor(Colors.textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .margin({ left: Space.md })

      // 播放按钮：小号白色图标 + 放大点击热区（整行可点，按钮仅作视觉）
      IconSlot({ iconSize: 32, icon: $r('app.media.player_play'), label: '', bg: Colors.transparent, fg: Colors.textPrimary })
        .padding(Space.sm)
    }
    .width('100%')
    .alignItems(VerticalAlign.Center)
    .padding({ top: Space.sm, bottom: Space.sm })
    .border({ width: { bottom: 0.5 }, color: Colors.surfaceMid, style: BorderStyle.Solid }) // 行间细分隔线
    .onClick(() => {
      this.onPlay(); // 整行支持点击播放
    })
  }
}
