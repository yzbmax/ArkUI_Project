/**
 * ActivityPage —— 活动列表（P01 / P06 / P09）
 * ForEach 渲染 activities: ActivityInfo[]；卡片含标题/时间/地点/海报占位/状态标签；
 * 点击进入详情（P09 分区）。
 */
import { Colors, Font, Space, Radius } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { GlassNavBar } from '../components/GlassNavBar';
import { activities } from '../mock/MockData';
import { ActivityInfo } from '../model/Models';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct ActivityPage {
  @State list: ActivityInfo[] = activities;

  // 点击进入详情，传 activityId（P09）
  private openDetail(a: ActivityInfo): void {
    try {
      router.pushUrl({ url: 'pages/ActivityDetailPage', params: { activityId: a.id } });
    } catch (e) {
      // 页面跳转失败：忽略
    }
  }

  build() {
    Column() {
      GlassNavBar({ title: '活动', showBack: true, onBack: () => { try { router.back(); } catch (e) {} } });

      Scroll() {
        Column({ space: Space.md }) {
          ForEach(this.list, (a: ActivityInfo) => {
            AppCard({ dark: false, withShadow: true, pad: Space.md, onTap: () => this.openDetail(a) }) {
              Column({ space: Space.sm }) {
                // 海报占位（深底色块 + emoji）
                Row() {
                  Text('🎫')
                    .fontSize(28);
                }
                .width('100%')
                .height(96)
                .borderRadius(Radius.card)
                .backgroundColor(Colors.darkSurface)
                .justifyContent(FlexAlign.Center)
                .alignItems(VerticalAlign.Center);

                Row() {
                  Text(a.title)
                    .fontSize(Font.cardTitle.size)
                    .fontWeight(Font.cardTitle.weight)
                    .fontColor(Colors.textDark);
                  Blank();
                  Text(a.status === 'open' ? '报名中' : '已结束')
                    .fontSize(Font.caption.size)
                    .fontColor(a.status === 'open' ? Colors.blue : Colors.textTertiary);
                }
                .width('100%');

                Text(`时间：${a.time}`)
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textSecondary);
                Text(`地点：${a.location}`)
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textSecondary);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start);
            }
          }, (a: ActivityInfo) => a.id);
        }
        .width('100%')
        .padding({ left: Space.lg, right: Space.lg, top: Space.lg, bottom: Space.xl });
      }
      .layoutWeight(1)
      .width('100%');
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bgLight);
  }
}
