/**
 * 主框架（A008）—— 底部 5 Tab 导航：首页 / 动态 / 发布(中央) / 消息 / 我的。
 * 承载各 Tab 子页内容。
 */
import { ROUTES } from '../shared/constants/Routes';
import { AppStore } from '../shared/store/AppStore';
import { HomeContent } from './home/HomeContent';
import { FeedContent } from './feed/FeedContent';
import { MessageContent } from './message/MessageContent';
import { ProfileContent } from './profile/ProfileContent';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';

type TabKey = 'home' | 'feed' | 'message' | 'mine';

@Entry
@Component
struct MainTab {
  @State tab: TabKey = 'home';
  @State unread: number = 3;
  @StorageLink('themeVersion') themeVersion: number = 0;

  @Builder
  TabItem(icon: string, label: string, key: TabKey) {
    Column({ space: 4 }) {
      Icon({ name: icon, iconSize: 24, tint: this.tab === key ? TINT.BRAND_TERRACOTTA : TINT.TEXT_STONE })
      Text(label)
        .fontSize($r('app.float.font_label'))
        .fontColor(this.tab === key ? $r('app.color.brand_terracotta') : $r('app.color.text_stone'))
    }
    .width('20%')
    .alignItems(HorizontalAlign.Center)
    .onClick(() => this.tab = key)
  }

  build() {
    Column() {
      // 内容区 —— layoutWeight(1) 占满底部导航以上的剩余空间，避免与导航同列叠加溢出
      Column() {
        if (this.tab === 'home') {
          HomeContent()
        } else if (this.tab === 'feed') {
          FeedContent({ onOpen: (id: string) => this.getUIContext().getRouter().pushUrl({ url: ROUTES.lostDetail, params: { id } }) })
        } else if (this.tab === 'message') {
          MessageContent({ onOpen: (peerId: string, name: string) => {
            if (peerId) {
              this.getUIContext().getRouter().pushUrl({ url: ROUTES.chat, params: { peerId, name } });
            }
          } })
        } else {
          ProfileContent({ onNavigate: (r: string) => this.getUIContext().getRouter().pushUrl({ url: r }) })
        }
      }
      .width('100%')
      .layoutWeight(1)

      // 底部导航
      Row() {
        this.TabItem('home', '首页', 'home')
        this.TabItem('list', '动态', 'feed')
        // 中央发布
        Column() {
          Icon({ name: 'plus', iconSize: 24, tint: TINT.BG_IVORY })
        }
        .width(48).height(48)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('app.color.brand_terracotta'))
        .borderRadius(24)
        .shadow({ radius: 12, color: '#00000019', offsetY: 4 })
        .onClick(() => this.getUIContext().getRouter().pushUrl({ url: ROUTES.publishLost }))
        this.TabItem('bell', '消息', 'message')
        this.TabItem('user', '我的', 'mine')
      }
      .width('100%')
      .height(60)
      .padding({ bottom: 8 })
      .backgroundColor($r('app.color.bg_ivory'))
      .border({ width: { top: 1 }, color: $r('app.color.border_cream') })
      .justifyContent(FlexAlign.SpaceAround)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
