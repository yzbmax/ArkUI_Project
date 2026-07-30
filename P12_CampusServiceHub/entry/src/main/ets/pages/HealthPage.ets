/**
 * HealthPage —— 健康（P01 / P05）
 * 身高/体重输入 @State；BMI 派生计算（P05）：bmi = weight/(height/100)² 普通 getter 实时派生，
 * 映射等级文案（仅蓝/灰，不用额外彩色）。
 */
import { Colors, Font, Space, Radius } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { GlassNavBar } from '../components/GlassNavBar';
import { health } from '../mock/MockData';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct HealthPage {
  @State heightText: string = health.height.toString();
  @State weightText: string = health.weight.toString();
  @State bmiValue: number = 0;

  // BMI 计算（P05）：用 @State 保存（V1 不支持 getter 实时派生），输入变化时重算
  private calcBmi(): number {
    const h = Number(this.heightText);
    const w = Number(this.weightText);
    if (!h || !w || h <= 0) {
      return 0;
    }
    return w / Math.pow(h / 100, 2);
  }

  aboutToAppear() {
    this.bmiValue = this.calcBmi();
  }

  private category(): string {
    const b = this.bmiValue;
    if (b === 0) {
      return '请输入身高体重';
    }
    if (b < 18.5) {
      return '偏瘦';
    }
    if (b < 24) {
      return '正常';
    }
    if (b < 28) {
      return '偏胖';
    }
    return '肥胖';
  }

  build() {
    Column() {
      GlassNavBar({ title: '健康', showBack: true, onBack: () => { try { router.back(); } catch (e) {} } });

      Scroll() {
        Column({ space: Space.md }) {
          // 身体数据录入卡
          AppCard({ dark: false, withShadow: true, pad: Space.md }) {
            Column({ space: Space.sm }) {
              Text('身体数据')
                .fontSize(Font.caption.size)
                .fontColor(Colors.textTertiary);
              Row({ space: Space.md }) {
                Column({ space: Space.xs }) {
                  Text('身高 (cm)')
                    .fontSize(Font.caption.size)
                    .fontColor(Colors.textSecondary);
                  TextInput({ placeholder: '170', text: this.heightText })
                    .width('100%')
                    .height(44)
                    .backgroundColor(Colors.bgLight)
                    .borderRadius(Radius.cardSmall)
                    .padding({ left: Space.md, right: Space.md })
                    .fontSize(Font.body.size)
                    .fontColor(Colors.textDark)
                    .type(InputType.Number)
                    .onChange((v: string) => {
                      this.heightText = v;
                      this.bmiValue = this.calcBmi();
                    });
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);
                Column({ space: Space.xs }) {
                  Text('体重 (kg)')
                    .fontSize(Font.caption.size)
                    .fontColor(Colors.textSecondary);
                  TextInput({ placeholder: '60', text: this.weightText })
                    .width('100%')
                    .height(44)
                    .backgroundColor(Colors.bgLight)
                    .borderRadius(Radius.cardSmall)
                    .padding({ left: Space.md, right: Space.md })
                    .fontSize(Font.body.size)
                    .fontColor(Colors.textDark)
                    .type(InputType.Number)
                    .onChange((v: string) => {
                      this.weightText = v;
                      this.bmiValue = this.calcBmi();
                    });
                }
                .alignItems(HorizontalAlign.Start)
                .layoutWeight(1);
              }
              .width('100%');
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start);
          }

          // BMI 结果卡（P05 派生展示）
          AppCard({ dark: false, withShadow: true, pad: Space.md }) {
            Column({ space: Space.xs }) {
              Text('BMI 指数')
                .fontSize(Font.caption.size)
                .fontColor(Colors.textTertiary);
              Row() {
                Text(this.bmiValue > 0 ? this.bmiValue.toFixed(1) : '--')
                  .fontSize(Font.section.size)
                  .fontWeight(Font.section.weight)
                  .fontColor(Colors.textDark);
                Blank();
                Text(this.category())
                  .fontSize(Font.body.size)
                  .fontColor(this.category() === '正常' ? Colors.blue : Colors.textTertiary);
              }
              .width('100%');
              Text('BMI = 体重(kg) / 身高(m)²，结果仅供参考')
                .fontSize(Font.caption.size)
                .fontColor(Colors.textSecondary);
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start);
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
