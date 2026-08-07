/**
 * 收藏与足迹（P19）—— 收藏列表（后端） + 浏览历史（本地 AppStore）。
 */
import { ROUTES } from '../shared/constants/Routes';
import { ApiRepo } from '../shared/api/ApiRepo';
import { Post } from '../shared/mock/Models';
import { AppStore } from '../shared/store/AppStore';
import { PostCard } from '../common/components/PostCard';
import { EmptyState } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';

type FTab = 'collect' | 'footprint';

@Entry
@Component
struct Favorites {
  @State tab: FTab = 'collect';
  @State collects: Post[] = [];
  @State footprints: Post[] = [];

  onPageShow(): void {
    this.load();
  }

  private async load(): Promise<void> {
    try {
      this.collects = await ApiRepo.fetchMyCollects();
      const list: Post[] = [];
      for (const id of AppStore.footprint) {
        try {
          const p = await ApiRepo.getPost(id);
          list.push(p);
        } catch (e) {
          // 帖子可能已删除，跳过
        }
      }
      this.footprints = list;
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  private clearFootprint(): void {
    AppStore.clearFootprint();
    this.footprints = [];
    Toast.show('已清空足迹');
  }

  /** 当前 Tab 的帖子列表 */
  private currentList(): Post[] {
    return this.tab === 'collect' ? this.collects : this.footprints;
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('收藏与足迹').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
        if (this.tab === 'footprint' && this.footprints.length > 0) {
          Text('清空').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
            .onClick(() => this.clearFootprint())
        }
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      Row({ space: 20 }) {
        ForEach(['collect', 'footprint'] as FTab[], (t: FTab) => {
          Column({ space: 4 }) {
            Text(t === 'collect' ? '我的收藏' : '浏览足迹')
              .fontSize($r('app.float.font_subtitle'))
              .fontColor(this.tab === t ? $r('app.color.brand_terracotta') : $r('app.color.text_stone'))
              .fontWeight(this.tab === t ? FontWeight.Bold : FontWeight.Normal)
            if (this.tab === t) {
              Row().width(20).height(3).backgroundColor($r('app.color.brand_terracotta')).borderRadius(2)
            }
          }.onClick(() => this.tab = t)
        })
      }.width('100%').padding({ left: 16, bottom: 4 })

      Scroll() {
        Column({ space: 8 }) {
          if (this.currentList().length > 0) {
            ForEach(this.currentList(), (p: Post) => {
              PostCard({ post: p, onTap: (id) => this.getUIContext().getRouter().pushUrl({ url: ROUTES.lostDetail, params: { id } }) })
            }, (p: Post) => p.id)
          } else {
            EmptyState({
              icon: 'bookmark',
              title: this.tab === 'collect' ? '暂无收藏' : '暂无足迹',
              desc: this.tab === 'collect' ? '详情页点收藏就会出现在这里' : '看过的动态会记录在这里'
            })
          }
        }
        .padding({ left: 16, right: 16, bottom: 88 })
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
