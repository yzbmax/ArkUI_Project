/**
 * CoursePage —— 课程列表（P01 / P06 / P09）
 * ForEach 渲染 courses: CourseInfo[]；卡片含名称/教师/时间/地点/学分；
 * 点击卡片 router.pushUrl 传 courseId 进入详情（P09 分区）。
 */
import { Colors, Font, Space } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { GlassNavBar } from '../components/GlassNavBar';
import { courses } from '../mock/MockData';
import { CourseInfo } from '../model/Models';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct CoursePage {
  @State list: CourseInfo[] = courses;

  // 点击进入详情，传 courseId（P09）
  private openDetail(c: CourseInfo): void {
    try {
      router.pushUrl({ url: 'pages/CourseDetailPage', params: { courseId: c.id } });
    } catch (e) {
      // 页面跳转失败：忽略
    }
  }

  build() {
    Column() {
      GlassNavBar({ title: '课程', showBack: true, onBack: () => { try { router.back(); } catch (e) {} } });

      Scroll() {
        Column({ space: Space.md }) {
          ForEach(this.list, (c: CourseInfo) => {
            AppCard({ dark: false, withShadow: true, pad: Space.md, onTap: () => this.openDetail(c) }) {
              Column({ space: Space.xs }) {
                Row() {
                  Text(c.name)
                    .fontSize(Font.cardTitle.size)
                    .fontWeight(Font.cardTitle.weight)
                    .fontColor(Colors.textDark);
                  Blank();
                  Text(`${c.credit} 学分`)
                    .fontSize(Font.caption.size)
                    .fontColor(Colors.linkBlue);
                }
                .width('100%');

                Text(`教师：${c.teacher}`)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textSecondary);
                Text(`时间：${c.time}`)
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textSecondary);
                Text(`地点：${c.location}`)
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textSecondary);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start);
            }
          }, (c: CourseInfo) => c.id);
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
