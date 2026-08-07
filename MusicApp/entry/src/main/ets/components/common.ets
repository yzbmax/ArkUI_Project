/**
 * 公共 UI 原子：封面占位 / 图标占位
 * 说明（对应需求：不使用 emoji、预留图标与图片位置并注释标注）：
 *  - 本期用 color 色块替代真实封面，用浅色圆框（可带文字）替代真实图标；
 *  - 接入真实资源时，按注释位置替换为 Image($r('app.media.xxx')) / 图标 Resource。
 */
import { Colors, Radius } from '../theme/AppTheme';
// ImageFit 为 ArkUI 内置全局枚举（Cover 裁切 / Contain 完整），直接引用无需 import

// 将十六进制颜色（#RGB / #RRGGBB / #RRGGBBAA）转为 colorFilter 的 4x5 染色矩阵（20 个元素，偏移量范围 0..255）。
// 原理：把原图 RGB 乘子全置 0、用第 5 列常数偏移直接设为目标色，alpha 行 (0,0,0,1,0) 保持透明度，
// 因此 outline 图标的描边被染成目标色，而中间（无像素）保持透明，不会被填充。
export function tintMatrix(color: string): number[] {
  let hex = color.replace('#', '').trim();
  if (hex.length === 3 || hex.length === 4) {
    hex = hex.split('').map((c: string) => c + c).join('');
  }
  const r = parseInt(hex.substring(0, 2), 16) || 0;
  const g = parseInt(hex.substring(2, 4), 16) || 0;
  const b = parseInt(hex.substring(4, 6), 16) || 0;
  return [
    0, 0, 0, 0, r,
    0, 0, 0, 0, g,
    0, 0, 0, 0, b,
    0, 0, 0, 1, 0,
  ];
}

/**
 * 封面占位组件
 * 本期：color 圆角色块。
 * 预留位置：后续用 Image($r('app.media.cover_xxx')).objectFit(ImageFit.Cover) 替换内部 Column。
 */
@Component
export struct CoverImage {
  @Prop color: string = Colors.surfaceMid; // 占位色（Mock / 图片未加载时的兜底）
  @Prop radius: number | string = Radius.card; // 圆角（支持数字或 '50%' 等字符串）
  @Prop text: string = '';                 // 占位文字（可选，如首字/序号）
  @Prop img?: string;                      // 真实封面 URL（网络图片）；有则优先渲染
  @Prop fit: ImageFit = ImageFit.Cover;    // 填充方式：Cover 裁切填满（默认，方卡片用）；Contain 完整显示不裁切（瀑布流用）

  build() {
    Column() {
      if (this.img !== undefined && this.img.length > 0) {
        // 真实封面：网络图片直接渲染（高度由父级/aspectRatio 决定，objectFit 控制裁切或完整）
        Image(this.img)
          .width('100%')
          .height('100%')
          .objectFit(this.fit)
      } else if (this.text.length > 0) {
        // 未接入图片时的文字占位（兼容 / 兜底）
        Text(this.text)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.color)
    .borderRadius(this.radius)
  }
}

/**
 * 图标占位 / 渲染组件（非 emoji）
 * 接入图标：传入 icon（Resource）即渲染 Image 并按前景色 fg 着色；
 * 未传 icon 时保留占位文字能力，便于兼容未接入场景。
 * 资源命名约定：媒体文件名仅含小写字母/数字/下划线（连字符已统一改为下划线）。
 */
@Component
export struct IconSlot {
  @Prop iconSize: number = 24; // 占位框边长（避免与组件内置 size 属性冲突）
  @Prop label: string = '';    // 占位文字（接入图标后可移除 / 兜底）
  @Prop bg: string = Colors.surfaceMid;
  @Prop fg: string = Colors.textPrimary;
  @Prop icon?: Resource;       // 图标资源；传入后渲染 Image 并按 fg 着色

  build() {
    Column() {
      if (this.icon !== undefined) {
        // 接入真实图标：Image + colorFilter 染色（outline SVG 的 fill=none 保证中间不被填充）
        Image(this.icon)
          .width(this.iconSize * 0.6)
          .height(this.iconSize * 0.6)
          .objectFit(ImageFit.Contain)
          .colorFilter(tintMatrix(this.fg))
      } else if (this.label.length > 0) {
        // 未接入图标时的文字占位（兼容 / 兜底）
        Text(this.label)
          .fontSize(12)
          .fontColor(this.fg)
          .fontWeight(FontWeight.Bold)
      }
    }
    .width(this.iconSize)
    .height(this.iconSize)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.bg)
    .borderRadius(Radius.circle)
  }
}
