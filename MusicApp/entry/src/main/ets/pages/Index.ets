/**
 * 主页框架（F02）
 * 底部 4 个 Tab（推荐 / 发现 / 动态 / 我的），自定义 TabBar 切换视图，
 * 底部常驻 Mini-Bar 全局播放条。激活态绿色高亮。
 */
import { Colors } from '../theme/AppTheme';
import { TabType } from '../models/index';
import { TabBar } from '../components/TabBar';
import { MiniBar } from '../components/MiniBar';
import { Recommend } from '../views/Recommend';
import { Find } from '../views/Find';
import { Moment } from '../views/Moment';
import { Mine } from '../views/Mine';

@Entry
@Component
struct Index {
  @State activeIndex: number = 0;
  private tabs: TabType[] = [
    { text: '推荐', name: 'recommend', icon: $r('app.media.home') },
    { text: '发现', name: 'find', icon: $r('app.media.search') },
    { text: '动态', name: 'moment', icon: $r('app.media.message_circle') },
    { text: '我的', name: 'mine', icon: $r('app.media.user') },
  ];

  build() {
    // 用 Stack 让底部条浮在内容之上：内容可滚动到半透明条后方透出
    Stack({ alignContent: Alignment.Bottom }) {
      // 内容区：铺满全屏，滚到浮层条后方可见
      Column() {
        if (this.activeIndex === 0) {
          Recommend()
        } else if (this.activeIndex === 1) {
          Find()
        } else if (this.activeIndex === 2) {
          Moment()
        } else {
          Mine()
        }
      }
      .width('100%')
      .height('100%')

      // 底部浮层：迷你播放条 + TabBar（半透明磨砂，内容可透出）
      Column() {
        // 全局迷你播放条（F10）
        MiniBar()

        // 底部自定义 TabBar（F02）
        TabBar({
          activeIndex: this.activeIndex,
          tabs: this.tabs,
          onTabClick: (index: number) => {
            this.activeIndex = index;
          },
        })
      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bg)
    .padding({ top: 10 })
  }
}
