/**
 * 首页内容（C201）—— 搜索栏、Banner、2×2 快捷入口、4 Tab 切换。默认"最新发布"。
 */
import { ROUTES } from '../../shared/constants/Routes';
import { ApiRepo, PostQuery } from '../../shared/api/ApiRepo';
import { Post } from '../../shared/mock/Models';
import { PostCard } from '../../common/components/PostCard';
import { EmptyState } from '../../common/components/UI';
import { Icon } from '../../common/components/Icon';
import { hexToTint, TINT } from '../../common/components/tint';
import { PostType } from '../../shared/constants/Constants';
import { Toast } from '../../common/utils/Toast';
import { IMG_PREFIX } from '../../shared/api/HttpClient';
type HomeTab = 'latest' | 'lost' | 'found' | 'near';

/** 轮播图条目：图片相对路径 + 标语 */
interface BannerItem {
  image: string;
  text: string;
}
const BANNERS: BannerItem[] = [
  { image: '/static/images/banners/banner1.jpg', text: '失物招领公告' },
  { image: '/static/images/banners/banner2.jpg', text: '校园互助公约' },
  { image: '/static/images/banners/banner3.jpg', text: '找回率突破 85%' }
];

@Component
export struct HomeContent {
  @State tab: HomeTab = 'latest';
  @State bannerIdx: number = 0;
  @State list: Post[] = [];

  aboutToAppear(): void {
    this.refresh();
  }

  private async refresh(): Promise<void> {
    try {
      const r = await ApiRepo.getPosts(this.query());
      this.list = r.list;
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  private query(): PostQuery {
    if (this.tab === 'lost') {
      return { type: PostType.LOST };
    }
    if (this.tab === 'found') {
      return { type: PostType.FOUND };
    }
    if (this.tab === 'near') {
      return { sort: 'urgent' };
    }
    return {};
  }

  private tabName(t: HomeTab): string {
    if (t === 'latest') return '最新发布';
    if (t === 'lost') return '失物';
    if (t === 'found') return '寻物';
    return '附近';
  }

  @Builder
  QuickEntry(icon: string, label: string, url: string) {
    Column({ space: 6 }) {
      Icon({ name: icon, iconSize: 32, tint: TINT.BRAND_TERRACOTTA })
      Text(label).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_charcoal'))
    }
    .width('45%')
    .padding(16)
    .backgroundColor($r('app.color.bg_ivory'))
    .borderRadius($r('app.float.radius_feature'))
    .border({ width: 1, color: $r('app.color.border_cream') })
    .shadow({ radius: 12, color: '#26000000', offsetY: 4 })
    .alignItems(HorizontalAlign.Center)
    .onClick(() => this.getUIContext().getRouter().pushUrl({ url }))
  }

  build() {
    Column() {
      // 搜索栏
      Row({ space: 8 }) {
        Icon({ name: 'zoom', iconSize: 18, tint: TINT.TEXT_STONE })
        Text('搜索失物 / 寻物').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
      }
      .width('100%').height(40).padding({ left: 16 })
      .alignItems(VerticalAlign.Center)
      .backgroundColor($r('app.color.bg_ivory'))
      .borderRadius($r('app.float.radius_generous'))
      .onClick(() => this.getUIContext().getRouter().pushUrl({ url: ROUTES.search }))
      .margin({ top: 12, bottom: 12 })

      Scroll() {
        Column({ space: 12 }) {
          // Banner（主题图片 + 主题色遮罩 + 标语）
          Swiper() {
            ForEach(BANNERS, (b: BannerItem) => {
              Stack({ alignContent: Alignment.Center }) {
                Image(IMG_PREFIX + b.image)
                  .width('100%').height('100%')
                  .objectFit(ImageFit.Cover)
                // 主题色半透明遮罩，保证文字可读、风格统一
                Row().width('100%').height('100%').backgroundColor('#A6C96442')
                Text(b.text)
                  .fontSize($r('app.float.font_h2'))
                  .fontColor($r('app.color.text_on_brand'))
                  .fontWeight(FontWeight.Bold)
                  .padding(20)
              }
              .width('100%').height(140)
              .borderRadius($r('app.float.radius_hero'))
              .clip(true)
              .shadow({ radius: 12, color: '#26000000', offsetY: 4 })
            })
          }
          .height(140)
          .autoPlay(true)
          .interval(5000)
          .indicator(new DotIndicator()
            .bottom(10)
            .itemWidth(8)
            .itemHeight(8)
            .selectedItemWidth(18)
            .color('#59FFFFFF')
            .selectedColor($r('app.color.text_on_brand')))

          // 快捷入口 2x2
          Row({ space: 12 }) {
            this.QuickEntry('box', '发布失物', ROUTES.publishLost)
            this.QuickEntry('search_bag', '发布寻物', ROUTES.publishFound)
          }
          Row({ space: 12 }) {
            this.QuickEntry('scan', '扫一扫', ROUTES.publishLost)
            this.QuickEntry('sparkles_2', '智能匹配', ROUTES.match)
          }

          // 4 Tab
          Row({ space: 20 }) {
            ForEach(['latest', 'lost', 'found', 'near'] as HomeTab[], (t: HomeTab) => {
              Column({ space: 4 }) {
                Text(this.tabName(t))
                  .fontSize($r('app.float.font_subtitle'))
                  .fontColor(this.tab === t ? $r('app.color.brand_terracotta') : $r('app.color.text_stone'))
                  .fontWeight(this.tab === t ? FontWeight.Bold : FontWeight.Normal)
                if (this.tab === t) {
                  Row().width(20).height(3).backgroundColor($r('app.color.brand_terracotta')).borderRadius(2)
                }
              }
              .onClick(() => { this.tab = t; this.refresh(); })
            })
          }
          .width('100%')
          .margin({ top: 4 })

          // 列表
          if (this.list.length > 0) {
            ForEach(this.list, (p: Post) => {
              PostCard({
                post: p,
                onTap: (id) => this.getUIContext().getRouter().pushUrl({ url: ROUTES.lostDetail, params: { id } }),
                onClaim: (id) => this.getUIContext().getRouter().pushUrl({ url: ROUTES.lostDetail, params: { id } })
              })
            }, (p: Post) => p.id)
          } else {
            EmptyState({ icon: 'search_bag', title: '暂无动态', desc: '成为第一个发布的人吧' })
          }
        }
        .padding({ left: 16, right: 16, bottom: 88 })
      }
      .layoutWeight(1)
      .scrollable(ScrollDirection.Vertical)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
