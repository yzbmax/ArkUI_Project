/**
 * 真实接口实现（P5 联调）
 * 接入 PRD §7 约定的 HTTP 接口：/data/swiper、/data/dailyRecommend、
 * /data/recommendList、/data/songList、/data/momentList、/data/user。
 * 与 MockMusicRepository 实现同一 MusicRepository 契约，页面与组件零改动即可切换。
 */
import { http } from '@kit.NetworkKit';
import { MusicRepository } from './MusicRepository';
import {
  SwiperType,
  DailyRecommendType,
  RecommendListType,
  SongItemType,
  MomentListType,
  UserType,
} from '../models/index';

// baseUrl 配置化：后续改为真实域名（也可放 resources 配置）
const BASE_URL: string = 'http://your-api-base';

export class HttpMusicRepository implements MusicRepository {
  // 通用 GET 请求：请求 + JSON 解析
  private get<T>(path: string): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      try {
        http.createHttp().request(
          BASE_URL + path,
          { method: http.RequestMethod.GET },
          (err: Error | null, data: http.HttpResponse) => {
            if (err) {
              reject(err);
              return;
            }
            const result: string = data.result as string;
            resolve(JSON.parse(result) as T);
          }
        );
      } catch (e) {
        reject(e);
      }
    });
  }

  getSwiper(): Promise<SwiperType[]> {
    return this.get<SwiperType[]>('/data/swiper');
  }

  getDailyRecommend(): Promise<DailyRecommendType[]> {
    return this.get<DailyRecommendType[]>('/data/dailyRecommend');
  }

  getRecommendList(): Promise<RecommendListType[]> {
    return this.get<RecommendListType[]>('/data/recommendList');
  }

  getSongList(): Promise<SongItemType[]> {
    return this.get<SongItemType[]>('/data/songList');
  }

  getMomentList(): Promise<MomentListType[]> {
    return this.get<MomentListType[]>('/data/momentList');
  }

  getUser(): Promise<UserType> {
    return this.get<UserType>('/data/user');
  }
}
