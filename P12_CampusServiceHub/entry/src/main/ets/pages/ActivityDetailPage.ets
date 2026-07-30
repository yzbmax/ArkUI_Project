/**
 * ActivityDetailPage —— 活动详情（P09 分区）+ 报名状态事件（P03）
 * 接收 params.activityId 查找活动；展示详情；底部报名按钮。
 * 点击“报名” → @State enrolled 翻转，按钮文案/颜色随之变化（Apple Blue ↔ 次级灰）。
 */
import { Colors, Font, Space, Radius } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { GlassNavBar } from '../components/GlassNavBar';
import { PrimaryButton } from '../components/PrimaryButton';
import { activities } from '../mock/MockData';
import { ActivityInfo } from '../model/Models';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct ActivityDetailPage {
  @State activityId: string = '';
  @State activity: ActivityInfo | null = null;
  @State enrolled: boolean = false;

  aboutToAppear(): void {
    try {
      const params = router.getParams() as Record<string, Object>;
      this.activityId = params['activityId'] as string;
    } catch (e) {
      // 忽略参数读取失败
    }
    const found = activities.find((a: ActivityInfo) => a.id === this.activityId);
    if (found) {
      this.activity = found;
      // 已结束的活动默认不可报名（enrolled 保持 false，按钮置灰）
    }
  }

  // 报名状态事件（P03）：翻转 enrolled
  private onEnroll(): void {
    this.enrolled = !this.enrolled;
  }

  build() {
    Column() {
      GlassNavBar({
        title: this.activity ? this.activity.title : '活动详情',
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
          if (this.activity) {
            // 海报占位
            Row() {
              Text('🎫')
                .fontSize(40);
            }
            .width('100%')
            .height(140)
            .borderRadius(Radius.card)
            .backgroundColor(Colors.darkSurface)
            .justifyContent(FlexAlign.Center)
            .alignItems(VerticalAlign.Center);

            // 活动信息卡
            AppCard({ dark: false, withShadow: true, pad: Space.md }) {
              Column({ space: Space.xs }) {
                Text('活动信息')
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textTertiary);
                Text(`时间：${this.activity.time}`)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);
                Text(`地点：${this.activity.location}`)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);
                Text(`状态：${this.activity.status === 'open' ? '报名中' : '已结束'}`)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start);
            }

            // 活动简介卡
            AppCard({ dark: false, withShadow: true, pad: Space.md }) {
              Column({ space: Space.xs }) {
                Text('活动简介')
                  .fontSize(Font.caption.size)
                  .fontColor(Colors.textTertiary);
                Text(this.activity.desc)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start);
            }
          } else {
            Text('未找到活动信息')
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

      // 底部报名栏（P03 状态事件）
      if (this.activity) {
        Column() {
          PrimaryButton({
            label: this.activity.status === 'closed'
              ? '活动已结束'
              : (this.enrolled ? '已报名' : '立即报名'),
            type: this.enrolled ? 1 : 0,
            disabled: this.activity.status === 'closed',
            onPress: () => this.onEnroll()
          });
        }
        .width('100%')
        .padding({ left: Space.lg, right: Space.lg, bottom: Space.xl, top: Space.sm });
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bgLight);
  }
}
