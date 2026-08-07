/**
 * 个人主页（C601）—— 资料 + 信用徽章 + 统计 + 动态列表（失物/寻物 Tab）。
 */
import { ROUTES } from '../../shared/constants/Routes';
import { AppStore } from '../../shared/store/AppStore';
import { ApiRepo } from '../../shared/api/ApiRepo';
import { Post } from '../../shared/mock/Models';
import { PostType, ROLE_NAMES } from '../../shared/constants/Constants';
import { CreditBadge, AvatarPlaceholder, EmptyState } from '../../common/components/UI';
import { Icon } from '../../common/components/Icon';
import { hexToTint, TINT } from '../../common/components/tint';
import { PostCard } from '../../common/components/PostCard';
import { IMG_PREFIX } from '../../shared/api/HttpClient';
import { Toast } from '../../common/utils/Toast';

type ProfileTab = 'lost' | 'found';

@Component
export struct ProfileContent {
  @State tab: ProfileTab = 'lost';
  @State posts: Post[] = [];
  onNavigate: (r: string) => void = () => {};

  aboutToAppear(): void {
    this.refresh();
  }

  private async refresh(): Promise<void> {
    try {
      this.posts = await ApiRepo.myPosts(undefined, this.tab === 'lost' ? PostType.LOST : PostType.FOUND);
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  /** 当前用户头像相对路径（无则空串） */
  private userAvatar(): string {
    const a: ResourceStr = AppStore.user?.avatar ?? '';
    return (typeof a === 'string') ? (a as string) : '';
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          // 资料头部
          Row({ space: 12 }) {
            if (this.userAvatar() !== '') {
              Image(IMG_PREFIX + this.userAvatar()).width(64).height(64).borderRadius(32).objectFit(ImageFit.Cover)
                .border({ width: 1, color: $r('app.color.border_cream') })
            } else {
              AvatarPlaceholder({ iconSize: 64 })
            }
            Column({ space: 4 }) {
              Row({ space: 8 }) {
                Text(AppStore.user?.nickname || '我').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
                CreditBadge({ level: AppStore.user?.creditLevel || 1 })
              }
              .alignItems(VerticalAlign.Center)
              Text((ROLE_NAMES.get(AppStore.user?.role ?? 'student') ?? '') + ' · ' + (AppStore.user?.campus || '中心校区'))
                .fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
            }.layoutWeight(1).alignItems(HorizontalAlign.Start)
            Icon({ name: 'pencil', iconSize: 20, tint: TINT.TEXT_STONE })
              .onClick(() => this.onNavigate(ROUTES.editProfile))
          }
          .width('100%').padding(16)
          .alignItems(VerticalAlign.Center)

          // 统计
          Row({ space: 8 }) {
            this.Stat('发布', '12')
            this.Stat('帮助', '8')
            this.Stat('获赞', '56')
            this.Stat('信用', (AppStore.user?.creditScore || 0).toString())
          }
          .width('100%').padding({ left: 16, right: 16 })

          // 功能入口
          Column({ space: 4 }) {
            this.Entry('我的发布', 'list', ROUTES.myPosts)
            this.Entry('认领审核', 'hand_stop', ROUTES.claimReview)
            this.Entry('线索管理', 'search_bag', ROUTES.clueReview)
            this.Entry('我的认领/线索', 'hand_stop', ROUTES.myClaims)
            this.Entry('收藏与足迹', 'bookmark', ROUTES.favorites)
            this.Entry('信用积分', 'gift', ROUTES.credit)
            this.Entry('设置', 'settings_2', ROUTES.settings)
            if (AppStore.user?.role === 'admin') {
              this.Entry('管理后台', 'settings_2', ROUTES.admin)
            }
          }
          .width('100%').padding({ left: 16, right: 16 })

          // 动态 Tab
          Row({ space: 20 }) {
            ForEach(['lost', 'found'] as ProfileTab[], (t: ProfileTab) => {
              Column({ space: 4 }) {
                Text(t === 'lost' ? '我的失物' : '我的寻物')
                  .fontSize($r('app.float.font_subtitle'))
                  .fontColor(this.tab === t ? $r('app.color.brand_terracotta') : $r('app.color.text_stone'))
                  .fontWeight(this.tab === t ? FontWeight.Bold : FontWeight.Normal)
                if (this.tab === t) {
                  Row().width(20).height(3).backgroundColor($r('app.color.brand_terracotta')).borderRadius(2)
                }
              }.onClick(() => { this.tab = t; this.refresh(); })
            })
          }
          .width('100%').padding({ left: 16, bottom: 4 })

          if (this.posts.length > 0) {
            ForEach(this.posts, (p: Post) => {
              PostCard({ post: p, onTap: (id) => this.getUIContext().getRouter().pushUrl({ url: ROUTES.lostDetail, params: { id } }) })
                .margin({ left: 16, right: 16 })
            }, (p: Post) => p.id)
          } else {
            EmptyState({ icon: 'search_bag', title: this.tab === 'lost' ? '还没有失物动态' : '还没有寻物动态', desc: '发布的第一条动态会显示在这里' })
          }
        }
        .padding({ bottom: 88 })
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }

  @Builder
  Stat(label: string, value: string) {
    Column({ space: 2 }) {
      Text(value).fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold).fontColor($r('app.color.brand_terracotta'))
      Text(label).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
    }.layoutWeight(1).padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
  }

  @Builder
  Entry(label: string, icon: string, url: string) {
    Row({ space: 12 }) {
      Icon({ name: icon, iconSize: 20, tint: TINT.TEXT_CHARCOAL })
      Text(label).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black')).layoutWeight(1)
      Icon({ name: 'arrow_left', iconSize: 16, tint: TINT.TEXT_STONE }).rotate({ angle: 180 })
    }
    .width('100%').padding(16).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
    .alignItems(VerticalAlign.Center)
    .onClick(() => this.onNavigate(url))
  }
}
