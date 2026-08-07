/**
 * 瀑布流相关通用组件（推荐页「发现更多」区块）
 *  - WaterfallCard：瀑布流卡片（封面 + 标题 + 作者 + 播放量），封面按 ratio 错落
 *  - SkeletonCard：骨架屏占位（首次加载）
 *  - LoadingFooter：底部上拉加载动画
 *  - EmptyState：数据为空提示
 *  - ErrorState：网络异常重试
 * 图片懒加载：ArkUI 的 Image 网络图默认按需解码加载，配合占位色/骨架即懒加载体验。
 */
import { Colors, Font, Radius, Space, Shadow } from '../theme/AppTheme';
import { WaterfallItemType } from '../models/index';
import { CoverImage } from './common';
// ImageFit 为 ArkUI 内置全局枚举，直接引用无需 import

/** 瀑布流卡片（风格与 SongCard 统一：正方形封面 + 左对齐文字 + 卡片柔光） */
@Component
export struct WaterfallCard {
  @Prop item: WaterfallItemType;
  @Prop cardWidth: number = 160;
  onPlay: () => void = () => {};

  build() {
    Column() {
      // 封面：正方形（与 SongCard 一致），Contain 完整显示不被裁切
      CoverImage({
        color: this.item.color,
        radius: Radius.card,
        img: this.item.img,
        text: this.item.title,
        fit: ImageFit.Contain,
      })
        .width('100%')
        .aspectRatio(1)
        .borderRadius(Radius.card)
        .backgroundColor(Colors.surfaceMid)

      // 文字区：与 SongCard 对齐（标题 16 Medium 白 + 副标题 14 灰）
      Column({ space: 4 }) {
        Text(this.item.title)
          .fontSize(Font.body)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.textPrimary)
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text(this.item.artist)
          .fontSize(Font.caption)
          .fontWeight(FontWeight.Regular)
          .fontColor(Colors.textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Text('播放 ' + this.item.count)
          .fontSize(Font.small)
          .fontColor(Colors.textSecondary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
          .margin({ top: 2 })
      }
      .width('100%')
      .padding({ left: Space.xs, right: Space.xs, top: Space.sm, bottom: Space.sm })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Space.sm)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Colors.surface)
    .borderRadius(Radius.card)
    .shadow(Shadow.card)
    .onClick(() => {
      this.onPlay();
    })
  }
}

/** 骨架屏卡片占位（首次加载，样式与 WaterfallCard 一致） */
@Component
export struct SkeletonCard {
  @Prop cardWidth: number = 160;
  @Prop ratio: number = 1;

  build() {
    Column() {
      Column()
        .width('100%')
        .aspectRatio(1)
        .borderRadius(Radius.card)
        .backgroundColor(Colors.surfaceMid)
        .opacity(0.6)
      Column({ space: 6 }) {
        Column().width('80%').height(12).borderRadius(Radius.pill).backgroundColor(Colors.surfaceMid)
        Column().width('60%').height(10).borderRadius(Radius.pill).backgroundColor(Colors.surfaceMid)
      }
      .width('100%')
      .padding({ left: Space.xs, right: Space.xs, top: Space.sm, bottom: Space.sm })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .padding(Space.sm)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(Colors.surface)
    .borderRadius(Radius.card)
    .shadow(Shadow.card)
  }
}

/** 底部上拉加载动画 */
@Component
export struct LoadingFooter {
  build() {
    Row() {
      LoadingProgress()
        .width(20)
        .height(20)
        .color(Colors.accent)
        .margin({ right: Space.sm })
      Text('加载中...')
        .fontSize(Font.caption)
        .fontColor(Colors.textSecondary)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)
  }
}

/** 数据为空状态 */
@Component
export struct EmptyState {
  onRetry: () => void = () => {};

  build() {
    Column({ space: Space.md }) {
      Column()
        .width(64)
        .height(64)
        .borderRadius(Radius.circle)
        .backgroundColor(Colors.surfaceMid)
      Text('暂无内容')
        .fontSize(Font.head)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.textPrimary)
      Text('还没有可推荐的内容，换个关键词试试')
        .fontSize(Font.caption)
        .fontColor(Colors.textSecondary)
      Button('重新加载')
        .fontSize(Font.caption)
        .fontColor(Colors.bg)
        .backgroundColor(Colors.accent)
        .borderRadius(Radius.pill)
        .height(36)
        .onClick(() => {
          this.onRetry();
        })
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
    .alignItems(HorizontalAlign.Center)
  }
}

/** 网络异常重试 */
@Component
export struct ErrorState {
  onRetry: () => void = () => {};

  build() {
    Column({ space: Space.md }) {
      Column()
        .width(64)
        .height(64)
        .borderRadius(Radius.circle)
        .backgroundColor(Colors.negative)
        .opacity(0.85)
      Text('加载失败')
        .fontSize(Font.head)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.textPrimary)
      Text('网络异常，请检查网络后重试')
        .fontSize(Font.caption)
        .fontColor(Colors.textSecondary)
      Button('点击重试')
        .fontSize(Font.caption)
        .fontColor(Colors.bg)
        .backgroundColor(Colors.accent)
        .borderRadius(Radius.pill)
        .height(36)
        .onClick(() => {
          this.onRetry();
        })
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
    .alignItems(HorizontalAlign.Center)
  }
}
