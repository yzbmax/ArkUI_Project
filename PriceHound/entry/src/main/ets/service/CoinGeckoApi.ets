import { http } from '@kit.NetworkKit';

/**
 * CoinGeckoApi.ets
 * 免费公开 API 数据源（无需密钥）：https://api.coingecko.com/api/v3/
 * 用于演示"真实数据源"能力：拉取加密货币实时价格，映射为商品价格走势。
 * 通过 Coingecko 市场数据接口获取热门币种价格，配合商品 id 的稳定映射，可生成
 * 与真实世界价格波动一致的走势数据。
 */

export interface CoinMarket {
  id: string;
  symbol: string;
  name: string;
  image: string;
  current_price: number;
  price_change_percentage_24h: number;
}

interface MarketChartResult {
  prices: Array<Array<number>>;
}

const BASE_URL: string = 'https://api.coingecko.com/api/v3';
const TIMEOUT_MS: number = 10000;

export class CoinGeckoApi {
  /** 获取市值前 N 的币种行情（免费额度 30 calls/min） */
  static async fetchTopMarkets(limit: number = 50): Promise<Array<CoinMarket>> {
    const url = `${BASE_URL}/coins/markets?vs_currency=cny&order=market_cap_desc&per_page=${limit}&page=1&sparkline=false&price_change_percentage=24h`;
    const httpRequest = http.createHttp();
    try {
      const resp = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: TIMEOUT_MS,
        readTimeout: TIMEOUT_MS,
        header: { 'Accept': 'application/json' },
      });
      if (resp.responseCode === 200) {
        const data = JSON.parse(resp.result as string) as Array<CoinMarket>;
        return data;
      }
      return [];
    } catch (e) {
      console.error('CoinGeckoApi fetchTopMarkets error: ' + JSON.stringify(e));
      return [];
    } finally {
      httpRequest.destroy();
    }
  }

  /** 获取单个币种 7 天价格走势 */
  static async fetchMarketChart(coinId: string, days: number = 30): Promise<Array<number>> {
    const url = `${BASE_URL}/coins/${coinId}/market_chart?vs_currency=cny&days=${days}`;
    const httpRequest = http.createHttp();
    try {
      const resp = await httpRequest.request(url, {
        method: http.RequestMethod.GET,
        connectTimeout: TIMEOUT_MS,
        readTimeout: TIMEOUT_MS,
      });
      if (resp.responseCode === 200) {
        const data = JSON.parse(resp.result as string) as MarketChartResult;
        const prices: Array<number> = [];
        for (let i = 0; i < data.prices.length; i++) {
          prices.push(data.prices[i][1]);
        }
        return prices;
      }
      return [];
    } catch (e) {
      console.error('CoinGeckoApi fetchMarketChart error: ' + JSON.stringify(e));
      return [];
    } finally {
      httpRequest.destroy();
    }
  }

  /** 检查 API 连通性（健康检查） */
  static async ping(): Promise<boolean> {
    const httpRequest = http.createHttp();
    try {
      const resp = await httpRequest.request(`${BASE_URL}/ping`, {
        method: http.RequestMethod.GET,
        connectTimeout: 8000,
        readTimeout: 8000,
      });
      return resp.responseCode === 200;
    } catch (e) {
      return false;
    } finally {
      httpRequest.destroy();
    }
  }
}
