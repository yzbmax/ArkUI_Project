/**
 * 数据层切换点（PRD §6.2）
 * 页面只依赖导出的 musicRepository（MusicRepository 类型），
 * 切换数据源只需改下方 USE_HTTP 开关，页面与组件零改动。
 *
 * 真实数据源：Apple iTunes Search API（免鉴权 / HTTPS / 返回可播放音频直链与封面）。
 * 全部信息流（轮播/每日推荐/推荐歌单/动态/我的/发现）均走真实数据；
 * 无真实社交/个人资料源的部分用真实歌曲封面 + 模板文案兜底，网络失败回退 Mock。
 */
import { MusicRepository } from './MusicRepository';
import { MockMusicRepository } from './MockMusicRepository';
import http from '@ohos.net.http';
import hilog from '@ohos.hilog';
import {
  SwiperType,
  DailyRecommendType,
  RecommendListType,
  SongItemType,
  MomentListType,
  UserType,
  WaterfallItemType,
} from '../models/index';
import { Colors } from '../theme/AppTheme';

const BASE_URL = 'https://itunes.apple.com';
const DEFAULT_TERM = 'pop'; // 发现页默认内容（无搜索词时）
const DOMAIN = 0x1002;

// iTunes 单条 track 的字段（仅取本项目需要的）
interface ItunesTrack {
  trackId: number;
  trackName: string;
  artistName: string;
  collectionName: string;
  artworkUrl100: string;
  previewUrl: string;
  trackTimeMillis: number;
}

// iTunes 搜索接口整体返回结构
interface ItunesSearchResponse {
  resultCount: number;
  results: ItunesTrack[];
}

class ItunesMusicRepository implements MusicRepository {
  // 无真实源时回退（如网络失败）的兜底
  private mock = new MockMusicRepository();

  // ---- 通用工具 ----

  // 按关键词调 iTunes Search，返回 track 列表（失败/空返回 []）
  private searchTracks(term: string): Promise<ItunesTrack[]> {
    const url = `${BASE_URL}/search?term=${encodeURIComponent(term)}&entity=song&limit=20`;
    return new Promise<ItunesTrack[]>((resolve) => {
      try {
        const req = http.createHttp();
        req.request(
          url,
          { method: http.RequestMethod.GET, expectDataType: http.HttpDataType.OBJECT },
          (err: Error | null, data: http.HttpResponse) => {
            req.destroy();
            if (err) {
              hilog.error(DOMAIN, 'Itunes', 'request failed: ' + err.message);
              resolve([]);
              return;
            }
            try {
              const res = data.result as ItunesSearchResponse;
              resolve(res.results || []);
            } catch (e) {
              resolve([]);
            }
          }
        );
      } catch (e) {
        resolve([]);
      }
    });
  }

  // 封面 100x100 → 300x300，更清晰（取更大尺寸提升清晰度）
  private cover(t: ItunesTrack): string {
    const raw = t.artworkUrl100 || '';
    return raw.replace('100x100bb', '300x300bb');
  }

  // iTunes track → 歌曲模型（含真实音频直链）
  private toSong(t: ItunesTrack): SongItemType {
    return {
      id: String(t.trackId),
      img: this.cover(t),
      color: Colors.surfaceMid,
      title: t.trackName || '',
      artist: t.artistName || '',
      url: t.previewUrl || '',
    };
  }

  // ---- 各信息流 ----

  // 轮播 banner：随机关键词 + 洗牌，每次进入随机展示不同封面
  getSwiper(): Promise<SwiperType[]> {
    const terms: string[] = [
      'top hits 2024',
      'kpop',
      'jazz',
      'rock classics',
      'lofi',
      'classical',
      'edm',
      'rnb',
    ];
    const term = terms[Math.floor(Math.random() * terms.length)];
    return this.searchTracks(term).then((tracks: ItunesTrack[]) => {
      if (tracks.length === 0) {
        return this.mock.getSwiper();
      }
      // 洗牌后取前 3 张，保证每次进入图片不同
      const arr: ItunesTrack[] = tracks.slice();
      for (let i = arr.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        const tmp: ItunesTrack = arr[i];
        arr[i] = arr[j];
        arr[j] = tmp;
      }
      const picked: ItunesTrack[] = arr.slice(0, 3);
      const list: SwiperType[] = picked.map((t: ItunesTrack): SwiperType => ({
        id: String(t.trackId),
        img: this.cover(t),
        color: Colors.surfaceMid,
        title: t.collectionName || t.trackName || '每日推荐',
      }));
      return list;
    });
  }

  // 每日推荐：多风格并行搜索，每张卡片用真实封面 + 歌曲
  getDailyRecommend(): Promise<DailyRecommendType[]> {
    const terms: string[] = ['morning calm', 'pop hits', 'workout energy', 'late night'];
    const bottoms: string[] = ['为你生成', '回忆杀', '打工人', '伴你入眠'];
    return Promise.all(terms.map((term: string) => this.searchTracks(term))).then(
      (groups: ItunesTrack[][]) => {
        if (groups.every((g: ItunesTrack[]) => g.length === 0)) {
          return this.mock.getDailyRecommend();
        }
        const list: DailyRecommendType[] = groups.map((tracks: ItunesTrack[], i: number): DailyRecommendType => {
          const t = tracks[0];
          return {
            id: 'd' + (i + 1),
            img: t ? this.cover(t) : '',
            color: Colors.surfaceMid,
            title: t ? (t.trackName || '每日推荐') : '每日推荐',
            type: t ? (t.artistName || '为你推荐') : '为你推荐',
            top: '每日',
            bottom: bottoms[i] || '为你推荐',
          };
        });
        return list;
      }
    );
  }

  // 推荐歌单：多风格并行搜索，封面 + 歌单名（播放量由 trackId 派生稳定文案）
  getRecommendList(): Promise<RecommendListType[]> {
    const terms: string[] = ['华语流行', '轻音乐', '健身燃脂', '民谣'];
    return Promise.all(terms.map((term: string) => this.searchTracks(term))).then(
      (groups: ItunesTrack[][]) => {
        if (groups.every((g: ItunesTrack[]) => g.length === 0)) {
          return this.mock.getRecommendList();
        }
        const list: RecommendListType[] = groups.map((tracks: ItunesTrack[], i: number): RecommendListType => {
          const t = tracks[0];
          const count = t ? ((t.trackId % 900) + 100) + '万' : '0万';
          return {
            id: 'r' + (i + 1),
            img: t ? this.cover(t) : '',
            color: Colors.surfaceMid,
            title: t ? (t.collectionName || t.trackName || '推荐歌单') : '推荐歌单',
            count: count,
          };
        });
        return list;
      }
    );
  }

  // 瀑布流分页（推荐页「发现更多」）：关键词轮询 + limit 固定取前 N + 洗牌，
  // 每页都返回满数据、风格多样，真正无限流；某关键词无结果自动换词重试，仍无则回退 Mock。
  private waterfallTerms: string[] = ['华语流行', '欧美热歌', '轻音乐', '说唱', '电音', '民谣', '古典', '爵士', '动漫', '怀旧'];

  getWaterfallPage(page: number, pageSize: number): Promise<WaterfallItemType[]> {
    // 关键词轮询：每页换关键词，保证风格多样且永不空
    const term = this.waterfallTerms[(page - 1) % this.waterfallTerms.length];
    return this.searchTracks(term)
      .then((tracks: ItunesTrack[]): WaterfallItemType[] | Promise<WaterfallItemType[]> => {
        if (tracks.length === 0 && page === 1) {
          // 首页即空：回退 Mock，避免直接空状态（真实数据不可用时体验更稳）
          return this.mock.getWaterfallPage(page, pageSize);
        }
        if (tracks.length === 0) {
          // 真实接口该关键词无结果：换下一个关键词重试一层，仍空则回退 Mock 保底
          const nextTerm = this.waterfallTerms[page % this.waterfallTerms.length];
          return this.searchTracks(nextTerm).then((t2: ItunesTrack[]): WaterfallItemType[] | Promise<WaterfallItemType[]> => {
            if (t2.length === 0) {
              return this.mock.getWaterfallPage(page, pageSize);
            }
            return this.buildWaterfall(page, t2, pageSize);
          });
        }
        return this.buildWaterfall(page, tracks, pageSize);
      })
      .catch((): WaterfallItemType[] | Promise<WaterfallItemType[]> => {
        // 真实请求异常/超时：回退 Mock 保底，保证瀑布流不中断
        return this.mock.getWaterfallPage(page, pageSize);
      });
  }

  // 把 tracks 洗牌后取 pageSize 条，映射为瀑布流卡片
  private buildWaterfall(page: number, tracks: ItunesTrack[], pageSize: number): WaterfallItemType[] {
    const arr: ItunesTrack[] = tracks.slice();
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      const tmp: ItunesTrack = arr[i];
      arr[i] = arr[j];
      arr[j] = tmp;
    }
    const picked: ItunesTrack[] = arr.slice(0, pageSize);
    const ratios: number[] = [1, 1.3, 0.8, 1.15, 1, 1.4, 0.9, 1.2];
    const list: WaterfallItemType[] = picked.map((t: ItunesTrack, i: number): WaterfallItemType => ({
      id: 'w' + page + '_' + t.trackId + '_' + i,
      img: this.cover(t),
      color: Colors.surfaceMid,
      title: t.collectionName || t.trackName || '精选歌单',
      artist: t.artistName || '未知歌手',
      count: ((t.trackId % 900) + 100) + '万',
      ratio: ratios[(page + i) % ratios.length],
    }));
    return list;
  }

  // 动态：真实歌曲 + 模板化社交文案（无社交后端，文案为预设）
  getMomentList(): Promise<MomentListType[]> {
    const authors: string[] = ['音乐旅人', '耳机里的世界', '现场控', '夜行听歌人', '旋律收藏家'];
    const contents: string[] = [
      '今天循环了一整天，太治愈了。',
      '分享一份适合深夜写代码的无歌词歌单。',
      'live 版真的比录音室更有张力！',
      '副歌一响，整个人都放松了。',
      '在路上单曲循环，通勤也变轻松。',
    ];
    return this.searchTracks('popular songs').then((tracks: ItunesTrack[]) => {
      if (tracks.length === 0) {
        return this.mock.getMomentList();
      }
      const picked = tracks.slice(0, 5);
      const list: MomentListType[] = picked.map((t: ItunesTrack, i: number): MomentListType => ({
        id: 'm' + (i + 1),
        author: authors[i % authors.length],
        avatar: this.cover(t), // 用真实歌曲封面作头像
        avatarColor: Colors.surfaceMid,
        content: contents[i % contents.length],
        comment: (t.trackId % 90) + 5,
        like: (t.trackId % 900) + 50,
        share: (t.trackId % 50) + 3,
        song: this.toSong(t),
      }));
      return list;
    });
  }

  // 我的：真实收藏封面（取自 iTunes），个人资料无真实源，保留静态默认值
  getUser(): Promise<UserType> {
    return this.searchTracks('best of 2024').then((tracks: ItunesTrack[]) => {
      if (tracks.length === 0) {
        return this.mock.getUser();
      }
      const collects: SongItemType[] = tracks.slice(0, 6).map((t: ItunesTrack): SongItemType => this.toSong(t));
      const t0 = tracks[0];
      const user: UserType = {
        name: '黑马音乐人',
        vip: true,
        age: 24,
        star: '天秤座',
        city: '杭州',
        follow: 123,
        fans: 456,
        avatar: t0 ? this.cover(t0) : '',
        avatarColor: Colors.surfaceMid,
        collects: collects,
      };
      return user;
    });
  }

  // 发现页默认内容：用默认关键词拉一批真实歌曲
  getSongList(): Promise<SongItemType[]> {
    return this.searchSongs(DEFAULT_TERM);
  }

  // 歌词：iTunes Search API 不提供歌词，直接回退 Mock（保证播放页歌词区有内容演示）
  getLyric(id: string): Promise<string> {
    return this.mock.getLyric(id);
  }

  // 真实搜索：调用 iTunes Search API
  searchSongs(keyword: string): Promise<SongItemType[]> {
    const term = encodeURIComponent(keyword.trim() || DEFAULT_TERM);
    const url = `${BASE_URL}/search?term=${term}&entity=song&limit=30`;
    return new Promise<SongItemType[]>((resolve) => {
      try {
        const req = http.createHttp();
        req.request(
          url,
          { method: http.RequestMethod.GET, expectDataType: http.HttpDataType.OBJECT },
          (err: Error | null, data: http.HttpResponse) => {
            req.destroy();
            if (err) {
              hilog.error(DOMAIN, 'Itunes', 'search failed: ' + err.message);
              resolve([]);
              return;
            }
            try {
              const response = data.result as ItunesSearchResponse;
              const results: ItunesTrack[] = response.results || [];
              const songs: SongItemType[] = results.map((t: ItunesTrack): SongItemType => ({
                id: String(t.trackId),
                // 把 100x100 封面升级为 300x300，更清晰
                img: (t.artworkUrl100 || '').replace('100x100bb', '300x300bb'),
                color: Colors.surfaceMid,
                title: t.trackName || '',
                artist: t.artistName || '',
                url: t.previewUrl || '', // 真实音频直链
              }));
              resolve(songs);
            } catch (e) {
              hilog.error(DOMAIN, 'Itunes', 'parse failed');
              resolve([]);
            }
          }
        );
      } catch (e) {
        resolve([]);
      }
    });
  }
}

// 数据源开关：true=ItunesMusicRepository（真实），false=Mock
const USE_HTTP: boolean = true;

let repo: MusicRepository;
if (USE_HTTP) {
  repo = new ItunesMusicRepository();
} else {
  repo = new MockMusicRepository();
}

export const musicRepository: MusicRepository = repo;
