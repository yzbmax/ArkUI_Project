/**
 * 歌曲卡片（横向滚动用）
 * 封面（CoverImage 占位）+ 标题 + 副标题（类型 / 播放量等）。
 */
import { Colors, Font, Radius, Space, Shadow } from '../theme/AppTheme';
import { CoverImage } from './common';

@Component
export struct SongCard {
  @Prop color: string = Colors.surfaceMid;
  @Prop title: string = '';
  @Prop subtitle: string = '';
  @Prop img?: string; // 真实封面 URL（网络图片）
  @Prop cardRadius: number = Radius.card;
  @Prop cardWidth: number = 120;

  build() {
    Column() {
      // 封面：正方形
      CoverImage({ color: this.color, radius: this.cardRadius, img: this.img })
        .width('100%')
        .aspectRatio(1)

      // 标题：白色 Medium 16，左对齐，超长省略
      Text(this.title)
        .width('100%')
        .margin({ top: Space.sm })
        .fontSize(Font.body)
        .fontColor(Colors.textPrimary)
        .fontWeight(FontWeight.Medium)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })

      // 副标题：浅灰 Regular 14，左对齐，超长省略
      Text(this.subtitle)
        .width('100%')
        .margin({ top: 2 })
        .fontSize(Font.caption)
        .fontColor(Colors.textSecondary)
        .fontWeight(FontWeight.Regular)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .width(this.cardWidth)
    .padding(Space.sm)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Colors.surface) // #121212 卡片底
    .borderRadius(Radius.card)       // 统一 12vp 圆角
    .shadow(Shadow.card)             // 细微柔光阴影
  }
}
