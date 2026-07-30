/**
 * ProfilePage —— 我的（P01 / P02）
 * 深色个人信息卡 + 数据卡 + 入口列表卡（健康/设置/讨论），点击跳转。
 */
import { Colors, Font, Space, UI } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { GlassNavBar } from '../components/GlassNavBar';
import { mockUser } from '../mock/MockData';
import { router } from '@kit.ArkUI';

interface ProfileEntry {
  id: string;
  title: string;
  icon: string;
  route: string;
}

@Entry
@Component
struct ProfilePage {
  private entries: ProfileEntry[] = [
    { id: 'h', title: '健康', icon: '❤️', route: 'HealthPage' },
    { id: 's', title: '设置', icon: '⚙️', route: 'SettingsPage' },
    { id: 'd', title: '讨论', icon: '💬', route: 'DiscussionPage' },
  ];

  private go(route: string): void {
    try {
      router.pushUrl({ url: 'pages/' + route });
    } catch (e) {
      // 页面跳转失败：忽略
    }
  }

  build() {
    Column() {
      GlassNavBar({ title: '我的', showBack: true, onBack: () => { try { router.back(); } catch (e) {} } });

      Scroll() {
        Column({ space: Space.lg }) {
          // 个人信息卡（深色，P02）
          AppCard({ dark: true, withShadow: true, pad: Space.lg }) {
            Row({ space: Space.md }) {
              Column() {
                Text(mockUser.name.charAt(0))
                  .fontSize(Font.cardTitle.size)
                  .fontWeight(Font.cardTitle.weight)
                  .fontColor(Colors.white);
              }
              .width(UI.avatarSize)
              .height(UI.avatarSize)
              .borderRadius(UI.avatarRadius)
              .backgroundColor(Colors.blue)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center);

              Column({ space: Space.xs }) {
                Text(mockUser.name)
                  .fontSize(Font.cardTitle.size)
                  .fontWeight(Font.cardTitle.weight)
                  .fontColor(Colors.white);
                Text(`学号 ${mockUser.studentNo}`)
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.whiteSecondary);
                Text(mockUser.college)
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.whiteTertiary);
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);
            }
            .width('100%');
          }

          // 数据卡
          AppCard({ dark: false, withShadow: true, pad: Space.md }) {
            Row() {
              Column({ space: Space.xs }) {
                Text(`${mockUser.courseCount}`)
                  .fontSize(Font.cardTitle.size)
                  .fontWeight(Font.cardTitle.weight)
                  .fontColor(Colors.textDark);
                Text('课程')
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textSecondary);
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1);
              Column({ space: Space.xs }) {
                Text(`${mockUser.activityCount}`)
                  .fontSize(Font.cardTitle.size)
                  .fontWeight(Font.cardTitle.weight)
                  .fontColor(Colors.textDark);
                Text('活动')
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textSecondary);
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1);
              Column({ space: Space.xs }) {
                Text(`${mockUser.orderCount}`)
                  .fontSize(Font.cardTitle.size)
                  .fontWeight(Font.cardTitle.weight)
                  .fontColor(Colors.textDark);
                Text('订单')
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textSecondary);
              }
              .alignItems(HorizontalAlign.Center)
              .layoutWeight(1);
            }
            .width('100%');
          }

          // 入口列表卡
          AppCard({ dark: false, withShadow: true, pad: 0 }) {
            Column() {
              ForEach(this.entries, (e: ProfileEntry) => {
                Row({ space: Space.sm }) {
                  Text(e.icon)
                    .fontSize(20);
                  Text(e.title)
                    .fontSize(Font.body.size)
                    .fontColor(Colors.textDark);
                  Blank();
                  Text('›')
                    .fontSize(Font.cardTitle.size)
                    .fontColor(Colors.textTertiary);
                }
                .width('100%')
                .padding({ left: Space.md, right: Space.md, top: Space.md, bottom: Space.md })
                .onClick(() => {
                  this.go(e.route);
                });
              }, (e: ProfileEntry) => e.id);
            }
            .width('100%');
          }
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
