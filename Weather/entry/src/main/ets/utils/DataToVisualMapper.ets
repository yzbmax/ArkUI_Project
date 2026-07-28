/**
 * 数据到视觉映射器
 * 将天气、步数、时间等数据映射到 CardData 视觉参数
 */
import { CardData, WeatherData, DayPeriod, ParticleType } from '../model/CardData';
import { ColorGenerator } from './ColorGenerator';
import { QUOTES_LIBRARY, QuoteItem } from '../model/QuotesData';

export class DataToVisualMapper {

  /**
   * 主映射函数
   */
  static map(weather: WeatherData, steps: number, timestamp: number, extraSeed: number = 0): CardData {
    const dayPeriod = DataToVisualMapper.getDayPeriod(timestamp);
    const combinedSeed = timestamp + extraSeed * 10007;
    const primaryColor = ColorGenerator.generatePrimaryColor(combinedSeed, weather.temperature, dayPeriod, weather.weatherCode);
    const secondaryColor = ColorGenerator.generateSecondaryColor(primaryColor);
    const primaryHsl = ColorGenerator.hexToHsl(primaryColor);

    const particleCount = DataToVisualMapper.mapParticleCount(steps);
    const baseSpeed = DataToVisualMapper.mapParticleSpeed(weather.weatherCode, weather.temperature);
    const gravityDirection = DataToVisualMapper.mapGravityDirection(weather.weatherCode);
    const baseOpacity = DataToVisualMapper.mapParticleOpacity(weather.weatherCode, dayPeriod);
    const particleType = DataToVisualMapper.mapParticleType(weather.weatherCode);
    const activityLevel = ColorGenerator.stepsToActivityLevel(steps);

    const quoteItem = DataToVisualMapper.selectQuote(dayPeriod, timestamp);

    const dateStr = DataToVisualMapper.formatDate(timestamp);
    const temperatureStr = `${weather.temperature}°C`;
    const cardId = `card_${DataToVisualMapper.formatDateKey(timestamp)}`;

    const cardData: CardData = {
      weather: weather,
      steps: steps,
      timestamp: timestamp,
      dayPeriod: dayPeriod,

      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      cardBgColor: 'rgba(255, 255, 255, 0.08)',
      particleColor: ColorGenerator.generateParticleColor(primaryColor, weather.weatherCode),
      textColor: ColorGenerator.generateTextColor(primaryHsl),
      glowColor: ColorGenerator.generateGlowColor(primaryColor),

      particleCount: particleCount,
      particleSpeed: baseSpeed,
      gravityDirection: gravityDirection,
      particleOpacity: baseOpacity,
      particleType: particleType,

      quote: quoteItem.text,
      quoteAuthor: quoteItem.author,
      dateStr: dateStr,
      temperatureStr: temperatureStr,

      cardId: cardId,
      isFavorite: false
    };
    return cardData;
  }

  static mapParticleCount(steps: number): number {
    const base = 80;
    const max = 200;
    const range = max - base;
    const clamped = Math.max(0, Math.min(20000, steps));
    return Math.round(base + (clamped / 20000) * range);
  }

  static mapParticleSpeed(weatherCode: number, temperature: number): number {
    switch (weatherCode) {
      case 0: return 0.6 + (temperature / 35) * 0.4;
      case 1: return 0.5 + (temperature / 35) * 0.3;
      case 2: return 0.4;
      case 3: return 1.5;
      case 4: return 0.3;
      default: return 0.7;
    }
  }

  static mapGravityDirection(weatherCode: number): number {
    switch (weatherCode) {
      case 0: return -1;
      case 1: return -0.5;
      case 2: return 0;
      case 3: return 1;
      case 4: return 0.5;
      default: return 0;
    }
  }

  static mapParticleOpacity(weatherCode: number, dayPeriod: string): number {
    let base = 0.7;
    if (dayPeriod === DayPeriod.NIGHT) base -= 0.2;
    if (weatherCode === 2) base -= 0.15;
    if (weatherCode === 3) base -= 0.25;
    if (weatherCode === 4) base -= 0.1;
    return Math.max(0.25, base);
  }

  static mapParticleType(weatherCode: number): ParticleType {
    switch (weatherCode) {
      case 0: return ParticleType.CIRCLE;
      case 1: return ParticleType.CIRCLE;
      case 2: return ParticleType.LINE;
      case 3: return ParticleType.DROP;
      case 4: return ParticleType.HEXAGON;
      default: return ParticleType.CIRCLE;
    }
  }

  /**
   * 时间段判断
   */
  static getDayPeriod(timestamp: number): DayPeriod {
    const date = new Date(timestamp);
    const hours = date.getHours();
    if (hours >= 6 && hours < 11) return DayPeriod.MORNING;
    if (hours >= 11 && hours < 14) return DayPeriod.NOON;
    if (hours >= 14 && hours < 19) return DayPeriod.AFTERNOON;
    return DayPeriod.NIGHT;
  }

  /**
   * 根据时间段选取哲言
   */
  static selectQuote(dayPeriod: DayPeriod, timestamp: number): QuoteItem {
    const date = new Date(timestamp);
    const seed = date.getFullYear() * 10000 + (date.getMonth() + 1) * 100 + date.getDate();
    const filtered = QUOTES_LIBRARY.filter((q: QuoteItem) => q.periods.includes(dayPeriod));
    const pool = filtered.length > 0 ? filtered : QUOTES_LIBRARY;
    const index = seed % pool.length;
    return pool[index];
  }

  /**
   * 格式化日期
   */
  static formatDate(timestamp: number): string {
    const date = new Date(timestamp);
    return `${date.getMonth() + 1}月${date.getDate()}日`;
  }

  /**
   * 格式化日期为缓存key
   */
  static formatDateKey(timestamp: number): string {
    const date = new Date(timestamp);
    const y = date.getFullYear();
    const m = String(date.getMonth() + 1).padStart(2, '0');
    const d = String(date.getDate()).padStart(2, '0');
    return `${y}${m}${d}`;
  }
}
