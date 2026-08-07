import { DesignRadius } from '../constants/DesignTokens';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * SkeletonList.ets
 * 骨架屏：列表加载占位（卡片 + 灰块 + 呼吸闪烁动画）
 * 数据加载期间展示，避免白屏闪烁
 */
@Component
export struct SkeletonList {
  @Prop count: number = 3;
  @State pulse: boolean = false;

  private indices(): Array<number> {
    const list: Array<number> = [];
    for (let i = 0; i < this.count; i++) {
      list.push(i);
    }
    return list;
  }

  aboutToAppear(): void {
    this.pulse = false;
    setTimeout(() => {
      this.pulse = true;
    }, 100);
  }

  @Builder
  skeletonCard() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        // 图标占位
        Row()
          .width(44)
          .height(44)
          .borderRadius(DesignRadius.MD)
          .backgroundColor(ThemeManager.surface())
        Column({ space: 8 }) {
          // 标题占位
          Row()
            .width('72%')
            .height(14)
            .borderRadius(7)
            .backgroundColor(ThemeManager.surface())
          // 副标题占位
          Row()
            .width('45%')
            .height(11)
            .borderRadius(6)
            .backgroundColor(ThemeManager.surface())
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        // 右侧价格占位
        Column({ space: 6 }) {
          Row()
            .width(70)
            .height(16)
            .borderRadius(8)
            .backgroundColor(ThemeManager.surface())
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')

      Row()
        .width('100%')
        .height(10)
        .borderRadius(5)
        .backgroundColor(ThemeManager.surface())
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeManager.card())
    .borderRadius(DesignRadius.LG)
    .opacity(this.pulse ? 0.55 : 1)
    .animation({ duration: 700, curve: 'ease-in-out' })
  }

  build() {
    Column({ space: 12 }) {
      ForEach(this.indices(), () => {
        this.skeletonCard()
      }, (i: number) => `${i}`)
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 8 })
  }
}
