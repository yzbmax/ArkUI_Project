/**
 * 色彩生成工具
 */

interface HSLColor {
  h: number;
  s: number;
  l: number;
}

export class ColorGenerator {
  /**
   * 用随机种子直接生成色相，而非窄映射到温度
   */
  static seedToHue(seed: number): number {
    return (seed * 67) % 360;
  }

  /**
   * 根据天气调整饱和度
   */
  static weatherToSaturation(weatherCode: number): number {
    switch (weatherCode) {
      case 0: return 55;  // 晴：鲜艳
      case 1: return 40;  // 多云
      case 2: return 25;  // 阴：低饱和
      case 3: return 30;  // 雨
      case 4: return 20;  // 雪：灰白
      default: return 40;
    }
  }

  /**
   * 根据时间段调整亮度
   */
  static periodToLightness(period: string): number {
    switch (period) {
      case 'morning': return 62;
      case 'noon': return 70;
      case 'afternoon': return 55;
      case 'night': return 30;
      default: return 50;
    }
  }

  static generatePrimaryColor(seed: number, temperature: number, dayPeriod: string, weatherCode: number): string {
    const hue = ColorGenerator.seedToHue(seed);
    const saturation = ColorGenerator.weatherToSaturation(weatherCode);
    const lightness = ColorGenerator.periodToLightness(dayPeriod);
    return ColorGenerator.hslToHex(hue, saturation, lightness);
  }

  static generateSecondaryColor(primaryHex: string): string {
    const hsl = ColorGenerator.hexToHsl(primaryHex);
    const newHue = (hsl.h + 30) % 360;
    const newLightness = Math.max(10, hsl.l - 12);
    return ColorGenerator.hslToHex(newHue, hsl.s, newLightness);
  }

  static generateParticleColor(primaryHex: string, weatherCode: number): string {
    const hsl = ColorGenerator.hexToHsl(primaryHex);
    if (weatherCode === 4) return ColorGenerator.hslToHex(210, 20, 85);
    if (weatherCode === 3) return ColorGenerator.hslToHex(hsl.h, 10, 80);
    return ColorGenerator.hslToHex(hsl.h, Math.min(80, hsl.s + 20), Math.min(85, hsl.l + 15));
  }

  static generateTextColor(bgHsl: HSLColor): string {
    return bgHsl.l > 50 ? 'rgba(30, 30, 30, 0.85)' : 'rgba(255, 255, 255, 0.9)';
  }

  static generateGlowColor(primaryHex: string): string {
    const hsl = ColorGenerator.hexToHsl(primaryHex);
    const rgb = ColorGenerator.hslToRgb(hsl.h, hsl.s, hsl.l);
    return `rgba(${rgb[0]},${rgb[1]},${rgb[2]},0.35)`;
  }

  static generateCardBgColor(): string {
    return 'rgba(255, 255, 255, 0.08)';
  }

  static stepsToActivityLevel(steps: number): number {
    const clamped = Math.max(3000, Math.min(20000, steps));
    return 0.5 + ((clamped - 3000) / 17000);
  }

  // ---- HSL / Hex 转换 ----

  static hslToHex(h: number, s: number, l: number): string {
    const sNorm = s / 100;
    const lNorm = l / 100;
    const a = sNorm * Math.min(lNorm, 1 - lNorm);
    const f = (n: number): number => {
      const k = (n + h / 30) % 12;
      const color = lNorm - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
      return Math.round(255 * color);
    };
    return `#${f(0).toString(16).padStart(2, '0')}${f(8).toString(16).padStart(2, '0')}${f(4).toString(16).padStart(2, '0')}`;
  }

  static hexToHsl(hex: string): HSLColor {
    let hx = hex.replace('#', '');
    if (hx.length === 3) hx = hx.split('').map((c: string) => c + c).join('');
    const r = parseInt(hx.substring(0, 2), 16) / 255;
    const g = parseInt(hx.substring(2, 4), 16) / 255;
    const b = parseInt(hx.substring(4, 6), 16) / 255;
    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    const l = (max + min) / 2;
    let h = 0;
    let s = 0;
    if (max !== min) {
      const d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
      switch (max) {
        case r: h = ((g - b) / d + (g < b ? 6 : 0)) / 6; break;
        case g: h = ((b - r) / d + 2) / 6; break;
        case b: h = ((r - g) / d + 4) / 6; break;
      }
    }
    return { h: Math.round(h * 360), s: Math.round(s * 100), l: Math.round(l * 100) };
  }

  static hslToRgb(h: number, s: number, l: number): number[] {
    const sNorm = s / 100;
    const lNorm = l / 100;
    const a = sNorm * Math.min(lNorm, 1 - lNorm);
    const f = (n: number): number => {
      const k = (n + h / 30) % 12;
      const color = lNorm - a * Math.max(Math.min(k - 3, 9 - k, 1), -1);
      return Math.round(255 * color);
    };
    return [f(0), f(8), f(4)];
  }
}
