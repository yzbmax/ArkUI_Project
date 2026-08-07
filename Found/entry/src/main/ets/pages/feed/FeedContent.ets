/**
 * 动态流（C202）—— 卡片流、下拉刷新、上拉加载分页、状态标签、筛选排序入口。
 */
import { ROUTES } from '../../shared/constants/Routes';
import { ApiRepo, PostQuery } from '../../shared/api/ApiRepo';
import { Post } from '../../shared/mock/Models';
import { PostCard } from '../../common/components/PostCard';
import { Icon } from '../../common/components/Icon';
import { hexToTint, TINT } from '../../common/components/tint';
import { Toast } from '../../common/utils/Toast';
interface FeedFilter {
  category?: string;
  urgentOnly?: boolean;
}

@Component
export struct FeedContent {
  @State page: number = 1;
  @State pageSize: number = 8;
  @State hasMore: boolean = true;
  @State loading: boolean = false;
  @State list: Post[] = [];
  @State filter: FeedFilter = {};
  onOpen?: (id: string) => void = () => {};

  aboutToAppear(): void {
    this.loadMore();
  }

  private async loadMore(): Promise<void> {
    if (this.loading || !this.hasMore) {
      return;
    }
    this.loading = true;
    try {
      const r = await ApiRepo.getPosts(this.toQuery(), this.page, this.pageSize);
      this.list = this.list.concat(r.list);
      this.hasMore = r.hasMore;
      this.page = r.page + 1;
    } catch (e) {
      Toast.show((e as Error).message);
    } finally {
      this.loading = false;
    }
  }

  private toQuery(): PostQuery {
    const q: PostQuery = {};
    if (this.filter.category) {
      q.category = this.filter.category;
    }
    if (this.filter.urgentOnly) {
      q.urgent = true;
    }
    return q;
  }

  build() {
    Column() {
      Row({ space: 12 }) {
        Text('动态').fontSize($r('app.float.font_h1')).fontFamily('Noto Serif SC').fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_near_black'))
        Row({ space: 4 }) {
          Icon({ name: 'filter', iconSize: 16, tint: TINT.TEXT_STONE })
          Text('筛选').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .alignItems(VerticalAlign.Center)
        .backgroundColor($r('app.color.bg_ivory'))
        .borderRadius($r('app.float.radius_generous'))
        .onClick(() => this.getUIContext().getRouter().pushUrl({ url: ROUTES.category }))
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .justifyContent(FlexAlign.SpaceBetween)

      Refresh({ refreshing: $$this.loading }) {
        List({ space: 12 }) {
          ForEach(this.list, (p: Post) => {
            ListItem() {
              PostCard({
                post: p,
                onTap: (id) => this.onOpen?.(id),
                onClaim: (id) => this.onOpen?.(id)
              })
            }
            .padding({ left: 16, right: 16 })
          }, (p: Post) => p.id)

          if (this.hasMore) {
            ListItem() {
              Text('加载中...').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
                .width('100%').textAlign(TextAlign.Center).padding(16)
            }
          }
        }
        .layoutWeight(1)
        .onReachEnd(() => this.loadMore())
      }
      .onRefreshing(() => {
        this.page = 1;
        this.list = [];
        this.hasMore = true;
        this.loadMore();
      })
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
