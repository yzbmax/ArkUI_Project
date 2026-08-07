/**
 * 底部自定义 TabBar（F02）
 * 图标 + 文字，选中态为半透明深灰圆角胶囊（白字白图标），
 * 常态无背景、浅灰文字与图标。
 * 图标资源：由 Index 传入 tab.icon（Resource）。
 */
import { Colors, Font, Space } from '../theme/AppTheme';
import { TabType } from '../models/index';
import { IconSlot } from './common';

@Component
export struct TabBar {
  @Prop activeIndex: number = 0;
  tabs: TabType[] = []; // 由 Index 传入（普通属性，仅用于渲染）
  onTabClick: (index: number) => void = () => {}; // 切换回调

  build() {
    Row() {
      ForEach(this.tabs, (tab: TabType, index: number) => {
        Column() {
          // 图标：选中态品牌绿、未选线性浅灰；统一尺寸保证视觉重量均衡
          IconSlot({
            iconSize: 24,
            icon: tab.icon,
            label: '',
            bg: Colors.transparent,
            fg: this.activeIndex === index ? Colors.accent : Colors.textSecondary,
          })
          Text(tab.text)
            .margin({ top: 2 })
            .fontSize(Font.caption)
            .fontColor(this.activeIndex === index ? Colors.accent : Colors.textSecondary)
            .fontWeight(this.activeIndex === index ? FontWeight.Bold : FontWeight.Normal)
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .padding({ top: Space.xs, bottom: Space.xs })
        .onClick(() => {
          // 点击切换当前 Tab
          this.onTabClick(index);
        })
      }, (tab: TabType) => tab.name)
    }
    .width('100%')
    .height(56)
    .padding({ left: Space.xs, right: Space.xs })
    .backgroundColor('rgba(0, 0, 0, 0.55)') // 磨砂加深，保证文字图标清晰
    .backdropBlur(30)
    .margin({ bottom: 20 })
  }
}
