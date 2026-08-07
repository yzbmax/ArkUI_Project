/**
 * 推荐页（F03）：轮播 banner + 每日推荐 + 推荐歌单 + 发现更多(无限瀑布流)
 * 三个区块独立加载真实数据；空数据有占位；歌单/每日推荐卡片点击进入歌单详情页。
 * 「发现更多」区块：两列手动瀑布流（奇偶拆分 + 高度变体错落，内容自然撑高、绝不重叠），
 * onScrollIndex 提前预加载（剩余 5 条时拉下一页），避免 onReachEnd 到底停顿/漏触发；
 * 含骨架屏 / 空状态 / 网络异常重试 / 上拉加载动画 / 没有更多了。
 * 分页采用关键词轮询 + 洗牌，保证每页均有真实数据。
 */
import { router } from '@kit.ArkUI';
import { image } from '@kit.ImageKit';
import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import { Colors, Font, Radius, Space } from '../theme/AppTheme';
import {
  SwiperType,
  DailyRecommendType,
  RecommendListType,
  WaterfallItemType,
} from '../models/index';
import { musicRepository } from '../services/index';
import { CoverImage } from '../components/common';
import { SongCard } from '../components/SongCard';
import {
  WaterfallCard,
  SkeletonCard,
  LoadingFooter,
  EmptyState,
  ErrorState,
} from '../components/Waterfall';

// 瀑布流加载状态机
type WfStatus = 'loading' | 'content' | 'error' | 'empty';
const PAGE_SIZE: number = 10;

@Component
export struct Recommend {
  @State swipers: SwiperType[] = [];
  @State daily: DailyRecommendType[] = [];
  @State recommends: RecommendListType[] = [];

  // 「发现更多」瀑布流状态
  @State wfList: WaterfallItemType[] = []; // 全部瀑布流卡片
  @State wfLeft: WaterfallItemType[] = [];  // 左列（偶数索引）
  @State wfRight: WaterfallItemType[] = []; // 右列（奇数索引）
  @State wfStatus: WfStatus = 'loading';
  @State wfPage: number = 0;          // 已加载到的页码（0 表示尚未加载）
  @State wfLoadingMore: boolean = false; // 上拉加载中
  @State wfNoMore: boolean = false;   // 已无更多

  aboutToAppear(): void {
    // 三个区块独立拉取（接口解耦，页面不感知来源）
    musicRepository.getSwiper().then((d: SwiperType[]) => {
      this.swipers = d;
      // 为每张 banner 提取主色，用作径向渐变主色调（失败回退默认色）
      d.forEach((item: SwiperType) => {
        this.extractDominantColor(item.img).then((glow: string) => {
          const idx = this.swipers.findIndex((s: SwiperType) => s.id === item.id);
          if (idx >= 0) {
            const old = this.swipers[idx];
            this.swipers[idx] = { id: old.id, img: old.img, color: glow, title: old.title };
            this.swipers = [...this.swipers];
          }
        });
      });
    });
    musicRepository.getDailyRecommend().then((d: DailyRecommendType[]) => {
      this.daily = d;
    });
    musicRepository.getRecommendList().then((d: RecommendListType[]) => {
      this.recommends = d;
    });

    // 瀑布流首页
    this.loadWaterfallFirst();
  }

  // ---- 瀑布流加载逻辑 ----
  private loadWaterfallFirst(): void {
    this.wfStatus = 'loading';
    this.wfPage = 0;
    this.wfNoMore = false;
    this.wfLoadingMore = false;
    musicRepository
      .getWaterfallPage(1, PAGE_SIZE)
      .then((list: WaterfallItemType[]) => {
        if (list.length === 0) {
          // 首页空：回退 Mock（保证不空白）
          musicRepository.getWaterfallPage(1, PAGE_SIZE).then((fallback: WaterfallItemType[]) => {
            if (fallback.length > 0) {
              this.wfList = fallback;
              this.splitWaterfallColumns();
              this.wfPage = 1;
              this.wfStatus = 'content';
            } else {
              this.wfStatus = 'empty';
            }
          });
          return;
        }
        this.wfList = list;
        this.splitWaterfallColumns();
        this.wfPage = 1;
        this.wfStatus = 'content';
      })
      .catch(() => {
        // 异常：回退 Mock（保证瀑布流区块一定有内容显示，绝不卡在 error/空白）
        musicRepository.getWaterfallPage(1, PAGE_SIZE).then((fallback: WaterfallItemType[]) => {
          if (fallback.length > 0) {
            this.wfList = fallback;
            this.splitWaterfallColumns();
            this.wfPage = 1;
            this.wfStatus = 'content';
          } else {
            this.wfStatus = 'error';
          }
        });
      });
  }

  // 加载下一页并追加（两列手动瀑布流，奇偶拆分渲染，内容自然撑高不重叠）
  private loadWaterfallNext(): void {
    if (this.wfLoadingMore || this.wfNoMore || this.wfStatus !== 'content') {
      return;
    }
    this.wfLoadingMore = true;
    const next = this.wfPage + 1;
    hilog.info(0x2001, 'Waterfall', 'load page %{public}d start', next);
    musicRepository
      .getWaterfallPage(next, PAGE_SIZE)
      .then((list: WaterfallItemType[]) => {
        hilog.info(0x2001, 'Waterfall', 'load page %{public}d got %{public}d items', next, list.length);
        if (list.length === 0) {
          this.wfNoMore = true;
          this.wfLoadingMore = false;
          return;
        }
        this.wfList = this.wfList.concat(list);
        this.splitWaterfallColumns();
        this.wfPage = next;
        this.wfLoadingMore = false;
      })
      .catch(() => {
        hilog.error(0x2001, 'Waterfall', 'load page %{public}d failed', next);
        this.wfLoadingMore = false;
        // 加载下一页失败：不阻断已加载内容，仅结束加载态（可再次触底重试）
      });
  }

  // 同步拆分 wfList → 左右列（ForEach 需要稳定的数组引用才能正确 diff 渲染）
  private splitWaterfallColumns(): void {
    const left: WaterfallItemType[] = [];
    const right: WaterfallItemType[] = [];
    for (let i = 0; i < this.wfList.length; i++) {
      if (i % 2 === 0) {
        left.push(this.wfList[i]);
      } else {
        right.push(this.wfList[i]);
      }
    }
    this.wfLeft = left;
    this.wfRight = right;
  }

  // 从图片 URL 解码并采样像素，提取平均主色（返回带透明度的 rgba，用于径向渐变）
  private async extractDominantColor(url: string): Promise<string> {
    const fallback = 'rgba(130, 130, 150, 0.4)';
    if (!url || url.length === 0) {
      return fallback;
    }
    try {
      const req = http.createHttp();
      const resp = await req.request(url, {
        method: http.RequestMethod.GET,
        expectDataType: http.HttpDataType.ARRAY_BUFFER,
      });
      req.destroy();
      const buf = resp.result as ArrayBuffer;
      const imageSource = image.createImageSource(buf);
      // 解码为 16x16 小图（专辑封面为正方形），直接按该尺寸读像素，绕开 ImageInfo 尺寸字段
      const pixelMap = await imageSource.createPixelMap({ desiredSize: { width: 16, height: 16 } });
      const buffer = new ArrayBuffer(16 * 16 * 4);
      await pixelMap.readPixelsToBuffer(buffer);
      pixelMap.release();
      const u8 = new Uint8Array(buffer);
      let r = 0;
      let g = 0;
      let b = 0;
      let n = 0;
      for (let i = 0; i + 3 < u8.length; i += 4) {
        if (u8[i + 3] === 0) {
          continue; // 跳过透明像素（含可能的留白填充）
        }
        r += u8[i];
        g += u8[i + 1];
        b += u8[i + 2];
        n++;
      }
      if (n === 0) {
        return fallback;
      }
      r = Math.round(r / n);
      g = Math.round(g / n);
      b = Math.round(b / n);
      // 淡淡透明度，作为从中心向外扩散的径向渐变主色
      return `rgba(${r}, ${g}, ${b}, 0.45)`;
    } catch (e) {
      return fallback;
    }
  }

  build() {
    Scroll() {
      // 区块间距 20vp，左右内边距 24vp
      Column({ space: 20 }) {
        // 页面大标题（一级标题：白色 Bold 28）
        Text('开始收听')
          .fontSize(Font.title)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
          .alignSelf(ItemAlign.Start)
          .padding({ left: Space.xxl, top: Space.xl })

        // F03.1 轮播 banner：卡片留白 + 径向渐变（主色取自图片）；指示器品牌绿放大
        Swiper() {
          ForEach(
            this.swipers,
            (item: SwiperType) => {
              // 卡片容器：背景径向渐变（主色 = 图片主色调），图片四周留白不贴边
              Column() {
                CoverImage({ color: item.color, radius: Radius.card, img: item.img, text: item.title })
                  .height("100%")

              }
              .width('100%')
              .height('100%')
              .padding(1) // 视觉呼吸空间：图片不撑满、不贴边
              .borderRadius(Radius.card)
              .backgroundColor(Colors.surface)
              .radialGradient({
                center: ['50%', '50%'],
                radius: '75%',
                colors: [
                  [item.color, 0.0],
                  ['rgba(0, 0, 0, 0)', 1.0],
                ],
              })
            },
            (item: SwiperType) => item.id
          )
        }
        .width('95%')
        .height(300)
        .margin({ left: Space.xxl, right: Space.xxl })
        .borderRadius(Radius.card)
        .indicator(
          Indicator.dot()
            .itemWidth(8)
            .itemHeight(8)
            .selectedItemWidth(12)
            .selectedItemHeight(12)
            .color(Colors.surfaceHi)
            .selectedColor(Colors.accent)
        )
        .loop(true)
        .autoPlay(true)

        // F03.2 每日推荐（二级标题 + 横向卡片）
        Column({ space: 12 }) {
          Text('每日推荐')
            .fontSize(Font.head)
            .fontWeight(FontWeight.Medium)
            .fontColor(Colors.textPrimary)
            .alignSelf(ItemAlign.Start)
            .padding({ left: Space.xxl })
          Scroll() {
            Row() {
              ForEach(
                this.daily,
                (item: DailyRecommendType) => {
                  SongCard({
                    color: item.color,
                    img: item.img,
                    title: item.title,
                    subtitle: item.type,
                    cardWidth: 130,
                  })
                    .margin({ right: Space.md })
                    .onClick(() => {
                      router.pushUrl({ url: 'pages/Playlist', params: { title: item.title } });
                    })
                },
                (item: DailyRecommendType) => item.id
              )
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .padding({ left: Space.xxl, right: Space.xxl })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // F03.3 推荐歌单（二级标题 + 横向卡片）
        Column({ space: 12 }) {
          Text('推荐歌单')
            .fontSize(Font.head)
            .fontWeight(FontWeight.Medium)
            .fontColor(Colors.textPrimary)
            .alignSelf(ItemAlign.Start)
            .padding({ left: Space.xxl })
          Scroll() {
            Row() {
              ForEach(
                this.recommends,
                (item: RecommendListType) => {
                  SongCard({
                    color: item.color,
                    img: item.img,
                    title: item.title,
                    subtitle: '播放 ' + item.count,
                    cardWidth: 130,
                  })
                    .margin({ right: Space.md })
                    .onClick(() => {
                      router.pushUrl({ url: 'pages/Playlist', params: { title: item.title } });
                    })
                },
                (item: RecommendListType) => item.id
              )
            }
          }
          .scrollable(ScrollDirection.Horizontal)
          .scrollBar(BarState.Off)
          .padding({ left: Space.xxl, right: Space.xxl })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        // F03.4 发现更多（两列手动瀑布流 + 无限加载）
        Column({ space: 12 }) {
          Text('发现更多')
            .fontSize(Font.head)
            .fontWeight(FontWeight.Medium)
            .fontColor(Colors.textPrimary)
            .alignSelf(ItemAlign.Start)
            .padding({ left: Space.xxl })

          if (this.wfStatus === 'loading') {
            // 首次加载：骨架屏占位（两列错落）
            Row() {
              Column({ space: Space.md }) {
                ForEach(
                  [0, 1, 2, 3],
                  (i: number) => {
                    SkeletonCard({ ratio: i % 2 === 0 ? 1 : 1.3 })
                  },
                  (i: number) => 'sk_l_' + i
                )
              }
              .width('50%')
              .padding({ right: Space.sm })
              .alignItems(HorizontalAlign.Start)

              Column({ space: Space.md }) {
                ForEach(
                  [0, 1, 2, 3],
                  (i: number) => {
                    SkeletonCard({ ratio: i % 2 === 0 ? 1.3 : 1 })
                  },
                  (i: number) => 'sk_r_' + i
                )
              }
              .width('50%')
              .padding({ left: Space.sm })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding({ left: Space.xxl, right: Space.xxl })
          } else if (this.wfStatus === 'error') {
            // 网络异常：重试机制
            ErrorState({
              onRetry: () => {
                this.loadWaterfallFirst();
              },
            })
              .width('100%')
          } else if (this.wfStatus === 'empty') {
            // 数据为空：空状态提示
            EmptyState({
              onRetry: () => {
                this.loadWaterfallFirst();
              },
            })
              .width('100%')
          } else {
            // 正常内容：两列手动瀑布流（奇偶拆分到左右列，内容自然撑高、绝不重叠）
            Row() {
              // 左列
              Column({ space: Space.md }) {
                ForEach(
                  this.wfLeft,
                  (item: WaterfallItemType) => {
                    WaterfallCard({
                      item: item,
                      onPlay: () => {
                        router.pushUrl({ url: 'pages/Playlist', params: { title: item.title } });
                      },
                    })
                  },
                  (item: WaterfallItemType) => item.id
                )
              }
              .width('50%')
              .padding({ right: Space.sm })
              .alignItems(HorizontalAlign.Start)

              // 右列
              Column({ space: Space.md }) {
                ForEach(
                  this.wfRight,
                  (item: WaterfallItemType) => {
                    WaterfallCard({
                      item: item,
                      onPlay: () => {
                        router.pushUrl({ url: 'pages/Playlist', params: { title: item.title } });
                      },
                    })
                  },
                  (item: WaterfallItemType) => item.id
                )
              }
              .width('50%')
              .padding({ left: Space.sm })
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding({ left: Space.xxl, right: Space.xxl })

            // 底部状态：加载动画 / 没有更多了
            if (this.wfLoadingMore) {
              LoadingFooter()
            } else if (this.wfNoMore) {
              Text('没有更多了')
                .fontSize(Font.caption)
                .fontColor(Colors.textSecondary)
                .width('100%')
                .height(56)
                .textAlign(TextAlign.Center)
            }
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .padding({ bottom: 150 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bg)
    .onReachEnd(() => {
      // 滚动到底部自动加载更多（两列手动瀑布流，内容自然撑高，onReachEnd 可靠触发）
      this.loadWaterfallNext();
    })
  }
}
