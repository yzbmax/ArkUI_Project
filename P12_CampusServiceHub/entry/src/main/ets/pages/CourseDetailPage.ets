/**
 * CourseDetailPage —— 课程详情（P09 分区）
 * 接收 params.courseId，从 Mock 数组查找课程；展示简介/大纲/教师；
 * 顶部返回按钮（router.back()）。
 */
import { Colors, Font, Space, Radius } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { GlassNavBar } from '../components/GlassNavBar';
import { courses } from '../mock/MockData';
import { CourseInfo } from '../model/Models';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct CourseDetailPage {
  @State courseId: string = '';
  @State course: CourseInfo | null = null;

  aboutToAppear(): void {
    try {
      const params = router.getParams() as Record<string, Object>;
      this.courseId = params['courseId'] as string;
    } catch (e) {
      // 忽略参数读取失败
    }
    this.course = courses.find((c: CourseInfo) => c.id === this.courseId) ?? null;
  }

  build() {
    Column() {
      GlassNavBar({
        title: this.course ? this.course.name : '课程详情',
        showBack: true,
        onBack: () => {
          try {
            router.back();
          } catch (e) {
            // 忽略返回失败
          }
        }
      });

      Scroll() {
        Column({ space: Space.md }) {
          if (this.course) {
            // 授课信息卡
            AppCard({ dark: false, withShadow: true, pad: Space.md }) {
              Column({ space: Space.xs }) {
                Text('授课信息')
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textTertiary);
                Text(`教师：${this.course.teacher}`)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);
                Text(`时间：${this.course.time}`)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);
                Text(`地点：${this.course.location}`)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);
                Text(`学分：${this.course.credit}`)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start);
            }

            // 课程简介卡
            AppCard({ dark: false, withShadow: true, pad: Space.md }) {
              Column({ space: Space.xs }) {
                Text('课程简介')
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textTertiary);
                Text(this.course.desc)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start);
            }

            // 课程大纲卡
            AppCard({ dark: false, withShadow: true, pad: Space.md }) {
              Column({ space: Space.sm }) {
                Text('课程大纲')
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textTertiary);
                ForEach(this.course.outline, (_o: string, idx: number) => {
                  Row({ space: Space.sm }) {
                    Text(`${idx + 1}`)
                      .fontSize(Font.caption.size)
                      .fontColor(Colors.white)
                      .width(20)
                      .height(20)
                      .borderRadius(Radius.cardSmall)
                      .backgroundColor(Colors.blue)
                      .textAlign(TextAlign.Center);
                    Text(_o)
                      .fontSize(Font.body.size)
                      .fontColor(Colors.textDark);
                  }
                  .width('100%')
                  .alignItems(VerticalAlign.Center);
                }, (_o: string, idx: number) => 'outline_' + idx);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start);
            }
          } else {
            Text('未找到课程信息')
              .fontSize(Font.body.size)
              .fontColor(Colors.textTertiary)
              .padding(Space.lg);
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
