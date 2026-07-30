/**
 * ServicePage —— 校园服务（P01 / P05 / P06 / P08）
 * ForEach 渲染 services: ServiceItem[]；每项含勾选框 + −/+ 修改 qty（P08，整体替换响应式）。
 * 派生计算（P05）：仅勾选项目计入总价 Σ(price×qty)；底部固定栏展示总价 + 去结算。
 */
import { Colors, Font, Space, Radius } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { GlassNavBar } from '../components/GlassNavBar';
import { PrimaryButton } from '../components/PrimaryButton';
import { services as mockServices } from '../mock/MockData';
import { ServiceItem } from '../model/Models';
import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct ServicePage {
  @State list: ServiceItem[] = mockServices;
  @State total: number = 0;

  // 派生计算（P05）：仅统计已勾选项 Σ(price×qty)
  private recalcTotal(): void {
    this.total = this.list.reduce((s: number, i: ServiceItem) => s + (i.checked ? i.price * i.qty : 0), 0);
  }

  // 数组更新（P08）：修改数量，保留 checked，整体替换触发刷新
  private changeQty(index: number, delta: number): void {
    const item = this.list[index];
    const qty = Math.max(0, item.qty + delta);
    this.list[index] = { id: item.id, name: item.name, desc: item.desc, price: item.price, qty: qty, checked: item.checked };
    this.list = [...this.list];
    this.recalcTotal();
  }

  // 勾选切换：仅勾选项目计入总价
  private toggleCheck(index: number, v: boolean): void {
    const item = this.list[index];
    this.list[index] = { id: item.id, name: item.name, desc: item.desc, price: item.price, qty: item.qty, checked: v };
    this.list = [...this.list];
    this.recalcTotal();
  }

  aboutToAppear() {
    this.recalcTotal();
  }

  @Builder
  serviceCard(item: ServiceItem, index: number) {
    AppCard({ dark: false, withShadow: true, pad: Space.md }) {
      Column({ space: Space.xs }) {
        Row() {
          Checkbox({ name: 'svc_' + item.id })
            .select(item.checked)
            .selectedColor(Colors.blue)
            .width(24)
            .height(24)
            .onChange((v: boolean) => {
              this.toggleCheck(index, v);
            });
          Column({ space: Space.xs }) {
            Text(item.name)
              .fontSize(Font.cardTitle.size)
              .fontWeight(Font.cardTitle.weight)
              .fontColor(item.checked ? Colors.textDark : Colors.textTertiary);
            Text(item.desc)
              .fontSize(Font.caption.size)
              .fontColor(item.checked ? Colors.textSecondary : Colors.textTertiary);
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1);
          Text(`¥${item.price.toFixed(2)}`)
            .fontSize(Font.body.size)
            .fontColor(item.checked ? Colors.textDark : Colors.textTertiary);
        }
        .width('100%');

        Row() {
          Text('数量')
            .fontSize(Font.caption.size)
            .fontColor(Colors.textSecondary);
          Blank();
          Row({ space: Space.sm }) {
            Button('-', { type: ButtonType.Normal })
              .width(44)
              .height(44)
              .borderRadius(Radius.cardSmall)
              .backgroundColor(Colors.bgLight)
              .fontColor(Colors.textDark)
              .onClick(() => {
                this.changeQty(index, -1);
              });
            Text(`${item.qty}`)
              .fontSize(Font.body.size)
              .fontColor(Colors.textDark)
              .width(28)
              .textAlign(TextAlign.Center);
            Button('+', { type: ButtonType.Normal })
              .width(44)
              .height(44)
              .borderRadius(Radius.cardSmall)
              .backgroundColor(Colors.bgLight)
              .fontColor(Colors.textDark)
              .onClick(() => {
                this.changeQty(index, 1);
              });
          }
        }
        .width('100%');
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
  }

  build() {
    Column() {
      GlassNavBar({ title: '校园服务', showBack: true, onBack: () => { try { router.back(); } catch (e) {} } });

      Scroll() {
        Column({ space: Space.md }) {
          ForEach(this.list, (s: ServiceItem, index: number) => {
            this.serviceCard(s, index);
          }, (s: ServiceItem) => s.id);
        }
        .width('100%')
        .padding({ left: Space.lg, right: Space.lg, top: Space.lg, bottom: Space.xl });
      }
      .layoutWeight(1)
      .width('100%');

      // 底部总价栏（P05 派生展示）
      Column({ space: Space.sm }) {
        Row() {
          Text('合计')
            .fontSize(Font.body.size)
            .fontColor(Colors.textSecondary);
          Blank();
          Text(`¥${this.total.toFixed(2)}`)
            .fontSize(Font.cardTitle.size)
            .fontWeight(Font.cardTitle.weight)
            .fontColor(Colors.textDark);
        }
        .width('100%');
        PrimaryButton({
          label: '去结算',
          onPress: () => {
            try {
              const n = this.list.filter((i: ServiceItem) => i.checked && i.qty > 0).length;
              promptAction.showToast({ message: `演示：已选 ${n} 项，合计 ¥${this.total.toFixed(2)}` });
            } catch (e) {
              // 忽略提示失败
            }
          }
        });
      }
      .width('100%')
      .padding({ left: Space.lg, right: Space.lg, bottom: Space.xl, top: Space.sm });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bgLight);
  }
}
