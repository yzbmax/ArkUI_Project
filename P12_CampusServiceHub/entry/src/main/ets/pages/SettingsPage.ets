/**
 * SettingsPage —— 设置（P01 / P07）
 * ForEach 渲染 settings: ToggleItem[]；每项独立 Toggle({type: Switch})，
 * @State enabled 互不影响（数组元素重建 + 整体替换响应式）。
 */
import { Colors, Font, Space } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { GlassNavBar } from '../components/GlassNavBar';
import { settings as mockSettings } from '../mock/MockData';
import { ToggleItem } from '../model/Models';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct SettingsPage {
  @State toggles: ToggleItem[] = mockSettings;

  // 多状态开关（P07）：独立更新该项 enabled
  private onToggle(index: number, value: boolean): void {
    const item = this.toggles[index];
    this.toggles[index] = { id: item.id, title: item.title, desc: item.desc, enabled: value };
    this.toggles = [...this.toggles];
  }

  build() {
    Column() {
      GlassNavBar({
        title: '设置',
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
          AppCard({ dark: false, withShadow: true, pad: Space.md }) {
            Column({ space: Space.md }) {
              ForEach(this.toggles, (t: ToggleItem, index: number) => {
                Row() {
                  Column({ space: Space.xs }) {
                    Text(t.title)
                      .fontSize(Font.body.size)
                      .fontColor(Colors.textDark);
                    Text(t.desc)
                      .fontSize(Font.caption.size)
                      .fontColor(Colors.textSecondary);
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1);
                  Toggle({ type: ToggleType.Switch, isOn: t.enabled })
                    .selectedColor(Colors.blue)
                    .onChange((v: boolean) => {
                      this.onToggle(index, v);
                    });
                }
                .width('100%');
              }, (t: ToggleItem) => t.id);
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
