/**
 * colorFilter 矩阵工具与预定义染色常量
 * 矩阵格式：[r,0,0,0,R, 0,g,0,0,G, 0,0,b,0,B, 0,0,0,1,0] (5×4)
 * 效果：将所有非透明像素替换为目标颜色
 *
 * TINT 用 getter 实现主题感知：深色模式下取提亮色值，
 * 避免 TEXT_NEAR_BLACK 等深色图标在深色背景上隐形。
 */
import { AppTheme } from '../../shared/theme/AppTheme';

export function hexToTint(hex: string): number[] {
  const h = hex.replace('#', '');
  const f = (i: number) => parseInt(h.substring(i * 2, i * 2 + 2), 16) / 255;
  return [0, 0, 0, 0, f(0), 0, 0, 0, 0, f(1), 0, 0, 0, 0, f(2), 0, 0, 0, 1, 0];
}

class Tint {
  get DEFAULT(): number[] {
    return hexToTint('#000000');
  }

  get TEXT_STONE(): number[] {
    return hexToTint(AppTheme.isDark ? '#6E6E68' : '#87867F');
  }

  get TEXT_CHARCOAL(): number[] {
    return hexToTint(AppTheme.isDark ? '#A8A69E' : '#4D4C48');
  }

  get TEXT_NEAR_BLACK(): number[] {
    return hexToTint(AppTheme.isDark ? '#B0AEA5' : '#141413');
  }

  get BRAND_TERRACOTTA(): number[] {
    return hexToTint('#C96442');
  }

  get BG_IVORY(): number[] {
    return hexToTint('#FAF9F5');
  }

  get STATUS_REWARD(): number[] {
    return hexToTint(AppTheme.isDark ? '#D4A455' : '#C9923E');
  }

  get STATUS_PENDING(): number[] {
    return hexToTint(AppTheme.isDark ? '#D4A455' : '#C9923E');
  }

  get STATUS_URGENT(): number[] {
    return hexToTint(AppTheme.isDark ? '#D64545' : '#B53333');
  }

  get WHITE(): number[] {
    return hexToTint('#FFFFFF');
  }
}

export const TINT: Tint = new Tint();
