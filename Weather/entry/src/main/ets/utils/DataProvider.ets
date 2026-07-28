/**
 * 数据提供者
 * 封装数据获取逻辑：使用模拟数据，预留真实API接口
 */
import { WeatherData, CardData } from '../model/CardData';
import { DataToVisualMapper } from './DataToVisualMapper';
import { preferences } from '@kit.ArkData';

const PREF_NAME = 'floating_light_store';
const KEY_DAILY_CARD = 'daily_card';
const KEY_FAVORITES = 'favorites_list';

export class DataProvider {

  static async getWeatherData(extraSeed: number = 0): Promise<WeatherData> {
    const now = new Date();
    const hour = now.getHours();
    const dayOfYear = DataProvider.getDayOfYear(now);

    const seed = dayOfYear + hour + extraSeed;
    const weatherCode = seed % 5;

    let baseTemp = 20;
    switch (weatherCode) {
      case 0: baseTemp = 22 + (seed % 15); break;
      case 1: baseTemp = 18 + (seed % 12); break;
      case 2: baseTemp = 15 + (seed % 10); break;
      case 3: baseTemp = 10 + (seed % 12); break;
      case 4: baseTemp = -5 + (seed % 10); break;
    }

    if (hour < 6 || hour >= 22) baseTemp -= 5;

    const descriptions: string[] = ['晴', '多云', '阴', '雨', '雪'];
    const weather: WeatherData = {
      weatherCode: weatherCode,
      temperature: baseTemp,
      description: descriptions[weatherCode]
    };
    return weather;
  }

  static async getStepCount(): Promise<number> {
    const now = new Date();
    const hour = now.getHours();
    const baseSteps = 3000;
    const hourBonus = hour >= 18 ? 6000 : hour >= 12 ? 4000 : hour >= 6 ? 2000 : 0;
    const randomBonus = Math.floor(Math.random() * 3000);
    return baseSteps + hourBonus + randomBonus;
  }

  static getTimestamp(): number {
    return Date.now();
  }

  static async generateDailyCard(context: Context): Promise<CardData> {
    const timestamp = DataProvider.getTimestamp();
    const dateKey = DataToVisualMapper.formatDateKey(timestamp);

    // 尝试从缓存读取
    try {
      const prefs = await preferences.getPreferences(context, PREF_NAME);
      const cached = await prefs.get(KEY_DAILY_CARD, '');
      if (typeof cached === 'string' && (cached as string).length > 0) {
        const cachedStr = cached as string;
        const cachedCard = JSON.parse(cachedStr) as CardData;
        const cachedDateKey = DataToVisualMapper.formatDateKey(cachedCard.timestamp);
        if (cachedDateKey === dateKey) {
          return cachedCard;
        }
      }
    } catch (e) {
      // 缓存读取失败，重新生成
    }

    return await DataProvider.buildNewCard(context, 0);
  }

  static async buildNewCard(context: Context, extraSeed: number): Promise<CardData> {
    const timestamp = DataProvider.getTimestamp();
    const weather = await DataProvider.getWeatherData(extraSeed);
    const steps = await DataProvider.getStepCount();
    const cardData = DataToVisualMapper.map(weather, steps, timestamp, extraSeed);

    // 缓存
    try {
      const prefs = await preferences.getPreferences(context, PREF_NAME);
      await prefs.put(KEY_DAILY_CARD, JSON.stringify(cardData));
      await prefs.flush();
    } catch (e) {
      // 忽略
    }

    return cardData;
  }

  static async saveFavoriteCard(context: Context, cardData: CardData): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(context, PREF_NAME);
      const favStr = await prefs.get(KEY_FAVORITES, '[]');
      const favJson = typeof favStr === 'string' ? favStr as string : '[]';
      let favorites: CardData[] = JSON.parse(favJson) as CardData[];
      const existsIdx = favorites.findIndex((f: CardData) => f.cardId === cardData.cardId);
      if (existsIdx < 0) {
        const cardCopy: CardData = {
          weather: cardData.weather,
          steps: cardData.steps,
          timestamp: cardData.timestamp,
          dayPeriod: cardData.dayPeriod,
          primaryColor: cardData.primaryColor,
          secondaryColor: cardData.secondaryColor,
          cardBgColor: cardData.cardBgColor,
          particleColor: cardData.particleColor,
          textColor: cardData.textColor,
          glowColor: cardData.glowColor,
          particleCount: cardData.particleCount,
          particleSpeed: cardData.particleSpeed,
          gravityDirection: cardData.gravityDirection,
          particleOpacity: cardData.particleOpacity,
          particleType: cardData.particleType,
          quote: cardData.quote,
          quoteAuthor: cardData.quoteAuthor,
          dateStr: cardData.dateStr,
          temperatureStr: cardData.temperatureStr,
          cardId: cardData.cardId,
          isFavorite: true
        };
        favorites.unshift(cardCopy);
        const trimmed = favorites.slice(0, 100);
        await prefs.put(KEY_FAVORITES, JSON.stringify(trimmed));
        await prefs.flush();
      }
    } catch (e) {
      console.error('Save favorite failed: ' + typeof e);
    }
  }

  static async getFavoriteCards(context: Context): Promise<CardData[]> {
    try {
      const prefs = await preferences.getPreferences(context, PREF_NAME);
      const favStr = await prefs.get(KEY_FAVORITES, '[]');
      const favJson = typeof favStr === 'string' ? favStr as string : '[]';
      const favorites: CardData[] = JSON.parse(favJson) as CardData[];
      return favorites;
    } catch (e) {
      return [];
    }
  }

  static async isTodayCardFavorite(context: Context, cardId: string): Promise<boolean> {
    const favorites = await DataProvider.getFavoriteCards(context);
    for (let i = 0; i < favorites.length; i++) {
      if (favorites[i].cardId === cardId) {
        return true;
      }
    }
    return false;
  }

  private static getDayOfYear(date: Date): number {
    const start = new Date(date.getFullYear(), 0, 0);
    const diff = date.getTime() - start.getTime();
    return Math.floor(diff / (1000 * 60 * 60 * 24));
  }

  private static refreshCounter: number = 0;
  static getNextRefreshSeed(): number {
    DataProvider.refreshCounter += 1;
    return DataProvider.refreshCounter;
  }
}
