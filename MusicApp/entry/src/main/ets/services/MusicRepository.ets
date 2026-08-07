/**
 * 数据访问契约（PRD §6.1）
 * 页面只依赖此接口，不感知数据来源（Mock / 真实接口）。
 */
import {
  SwiperType,
  DailyRecommendType,
  RecommendListType,
  SongItemType,
  MomentListType,
  UserType,
  WaterfallItemType,
} from '../models/index';

export interface MusicRepository {
  getSwiper(): Promise<SwiperType[]>;
  getDailyRecommend(): Promise<DailyRecommendType[]>;
  getRecommendList(): Promise<RecommendListType[]>;
  getSongList(): Promise<SongItemType[]>;
  getMomentList(): Promise<MomentListType[]>;
  getUser(): Promise<UserType>;
  searchSongs(keyword: string): Promise<SongItemType[]>;
  // 瀑布流分页：第 page 页（从 1 开始），每页 pageSize 条；返回空数组表示已无更多
  getWaterfallPage(page: number, pageSize: number): Promise<WaterfallItemType[]>;
  // 歌词：按歌曲 id 拉取 LRC 文本（带 [mm:ss.xx] 时间标签）；无歌词返回空串
  getLyric(id: string): Promise<string>;
}

/**
 * HttpMusicRepository（真实接口实现，预留）
 * 详见 PRD §7 路径：/data/swiper、/data/dailyRecommend、/data/recommendList、
 * /data/songList、/data/momentList、/data/user。
 * 本期不实现，待 P5 在 services/HttpMusicRepository.ets 中落地。
 */
// export class HttpMusicRepository implements MusicRepository { /* P5 实现 */ }
