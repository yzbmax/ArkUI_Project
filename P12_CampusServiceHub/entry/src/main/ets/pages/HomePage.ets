/**
 * HomePage —— 首页（P01 / P02 / P11）
 * 深色用户摘要卡 + 今日主线卡 + 功能入口网格（ForEach 渲染 FunctionEntry[]）。
 * 阶段 2：仅 LoginPage/HomePage 已交付，未建模块点击给 toast 提示（后续阶段将可真实跳转）。
 */
import { Colors, Font, Space, UI } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { GlassNavBar } from '../components/GlassNavBar';
import { mockUser, functionEntries } from '../mock/MockData';
import { FunctionEntry } from '../model/Models';
import { promptAction, router } from '@kit.ArkUI';

const BUILT_PAGES: string[] = ['LoginPage', 'HomePage', 'CoursePage', 'ActivityPage', 'DiscussionPage', 'ServicePage', 'HealthPage', 'ProfilePage']; // 已交付页面

@Entry
@Component
struct HomePage {
  @State entries: FunctionEntry[] = functionEntries;

  // 功能入口跳转（P11 模块聚合）
  private handleEntry(entry: FunctionEntry): void {
    if (BUILT_PAGES.includes(entry.route)) {
      try {
        router.pushUrl({ url: `pages/${entry.route}` });
      } catch (e) {
        // 页面跳转失败：忽略（模块将在后续阶段开放）
      }
    } else {
      try {
        promptAction.showToast({ message: `「${entry.title}」模块将在后续阶段开放` });
      } catch (e) {
        // 忽略提示失败
      }
    }
  }

  build() {
    Column() {
      GlassNavBar({ title: '首页' });

      Scroll() {
        Column({ space: Space.lg }) {
          // 用户摘要卡（深色，P02）
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
                Text('晚上好，今天也要元气满满 🌟')
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.whiteTertiary);
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);
            }
            .width('100%')
          }

          // 今日主线卡（浅色，P02）
          AppCard({ dark: false, withShadow: true, pad: Space.md }) {
            Row({ space: Space.sm }) {
              Text('📌')
                .fontSize(Font.cardTitle.size);
              Column({ space: Space.xs }) {
                Text('今日主线')
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textSecondary);
                Text(`今日 ${mockUser.courseCount} 门课 · ${mockUser.activityCount} 场活动`)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);
              }
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1);
            }
            .width('100%')
          }

          // 区块标题
          Text('服务入口')
            .fontSize(Font.cardTitle.size)
            .fontWeight(Font.cardTitle.weight)
            .fontColor(Colors.textDark)
            .alignSelf(ItemAlign.Start)
            .padding({ left: Space.xs });

          // 功能入口网格（2–3 列，ForEach，P06 / P11）
          GridRow({ columns: 3, gutter: Space.md }) {
            ForEach(this.entries, (e: FunctionEntry) => {
              GridCol({ span: 1 }) {
                AppCard({ dark: false, withShadow: true, pad: Space.md, onTap: () => this.handleEntry(e) }) {
                  Column({ space: Space.xs }) {
                    Text(e.icon)
                      .fontSize(28);
                    Text(e.title)
                      .fontSize(Font.caption.size)
                      .fontColor(Colors.textDark);
                  }
                  .width('100%')
                  .alignItems(HorizontalAlign.Center);
                }
              }
            }, (e: FunctionEntry) => e.id);
          }
          .width('100%')
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
