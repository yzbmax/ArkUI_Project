/**
 * Icon 组件 — Image + SVG + colorFilter 颜色矩阵染色
 * @param name 图标名（对应 base/media/*.svg 不含扩展名）
 * @param iconSize 正方形尺寸，默认 24
 * @param tint colorFilter 矩阵数组，用 TINT 常量或 hexToTint()
 */
import { TINT } from './tint';
import { ICON_IMAGE } from './IconImage';

@Component
export struct Icon {
  @Prop name: string = '';
  @Prop iconSize: number = 24;
  @Prop tint: number[] = TINT.DEFAULT;

  build() {
    Image(ICON_IMAGE[this.name] ?? ICON_IMAGE['home'])
      .width(this.iconSize)
      .height(this.iconSize)
      .objectFit(ImageFit.Contain)
      .colorFilter(this.tint)
  }
}
