/**
 * Mock 实现（本期使用）
 * 直接返回本地静态数据，模拟异步以便与真实接口签名一致。
 */
import { MusicRepository } from './MusicRepository';
import {
  SwiperType,
  DailyRecommendType,
  RecommendListType,
  SongItemType,
  MomentListType,
  UserType,
  WaterfallItemType,
} from '../models/index';
import {
  swiperData,
  dailyRecommendData,
  recommendListData,
  songListData,
  momentListData,
  userData,
} from '../mock/data';

const MOCK_WF_TITLES: string[] = ['华语流行精选', '轻音乐图书馆', '运动燃脂歌单', '民谣故事集', '深夜电台', '经典回放', '治愈钢琴曲', '城市民谣'];
const MOCK_WF_ARTISTS: string[] = ['周杰伦', '陈奕迅', '朴树', '赵雷', '逃跑计划', '李健', '毛不易', '万晓利'];

export class MockMusicRepository implements MusicRepository {
  getSwiper(): Promise<SwiperType[]> {
    return Promise.resolve(swiperData);
  }

  getDailyRecommend(): Promise<DailyRecommendType[]> {
    return Promise.resolve(dailyRecommendData);
  }

  getRecommendList(): Promise<RecommendListType[]> {
    return Promise.resolve(recommendListData);
  }

  getSongList(): Promise<SongItemType[]> {
    return Promise.resolve(songListData);
  }

  // Mock 搜索：按标题/歌手过滤本地数据
  searchSongs(keyword: string): Promise<SongItemType[]> {
    const kw = keyword.trim().toLowerCase();
    if (!kw) {
      return Promise.resolve(songListData);
    }
    const r = songListData.filter(
      (s: SongItemType) => s.title.toLowerCase().includes(kw) || s.artist.toLowerCase().includes(kw)
    );
    return Promise.resolve(r);
  }

  getMomentList(): Promise<MomentListType[]> {
    return Promise.resolve(momentListData);
  }

  getUser(): Promise<UserType> {
    return Promise.resolve(userData);
  }

  // Mock 瀑布流分页：生成与页码一一对应的稳定卡片（无网络依赖，离线可演示）
  getWaterfallPage(page: number, pageSize: number): Promise<WaterfallItemType[]> {
    const list: WaterfallItemType[] = [];
    const ratios: number[] = [1, 1.3, 0.8, 1.15, 1, 1.4, 0.9, 1.2];
    for (let i = 0; i < pageSize; i++) {
      const idx = (page - 1) * pageSize + i;
      list.push({
        id: 'mw_' + idx,
        img: '',
        color: ['#1ed760', '#539df5', '#ffa42b', '#f3727f', '#1db954', '#7c7c7c'][idx % 6],
        title: MOCK_WF_TITLES[idx % MOCK_WF_TITLES.length] + ' ' + (idx + 1),
        artist: MOCK_WF_ARTISTS[idx % MOCK_WF_ARTISTS.length],
        count: ((idx * 37) % 900 + 100) + '万',
        ratio: ratios[idx % ratios.length],
      });
    }
    return Promise.resolve(list);
  }

  // Mock 歌词：按 id 返回带时间戳的 LRC 文本（无对应歌词返回空串）
  getLyric(id: string): Promise<string> {
    const lrc = new Map<string, string>();
    lrc.set('g1', `[ti:晴天]\n[ar:周杰伦]\n[00:00.00]晴天 - 周杰伦\n[00:04.50]故事的小黄花\n[00:09.20]从出生那年就飘着\n[00:14.00]童年的荡秋千\n[00:18.80]随记忆一直晃到现在\n[00:23.50]Re So So Si Do Si La\n[00:28.30]So La Si Si Si Si La Si La So\n[00:33.10]吹着前奏望着天空\n[00:37.90]我想起花瓣试着掉落\n[00:42.60]为你翘课的那一天\n[00:47.40]花落的那一天\n[00:52.20]教室的那一间\n[00:57.00]我怎么看不见`);
    lrc.set('g2', `[ti:起风了]\n[ar:买辣椒也用券]\n[00:00.00]起风了 - 买辣椒也用券\n[00:03.80]这一路上走走停停\n[00:08.50]顺着少年漂流的痕迹\n[00:13.20]迈出车站的前一刻\n[00:18.00]竟有些犹豫\n[00:22.70]不禁笑这近乡情怯\n[00:27.50]仍无可避免\n[00:32.30]而长野的天\n[00:37.10]依旧那么暖`);
    lrc.set('g3', `[ti:夜空中最亮的星]\n[ar:逃跑计划]\n[00:00.00]夜空中最亮的星 - 逃跑计划\n[00:04.00]夜空中最亮的星\n[00:08.50]能否听清\n[00:13.00]那仰望的人\n[00:17.50]心底的孤独和叹息\n[00:22.00]夜空中最亮的星\n[00:26.50]能否记起\n[00:31.00]曾与我同行\n[00:35.50]消失在风里的身影`);
    lrc.set('g4', `[ti:平凡之路]\n[ar:朴树]\n[00:00.00]平凡之路 - 朴树\n[00:04.50]徘徊着的 在路上的\n[00:09.50]你要走吗\n[00:14.00]易碎的 骄傲着\n[00:19.00]那也曾是我的模样\n[00:23.50]沸腾着的 不安着的\n[00:28.50]你要去哪\n[00:33.00]谜一样的 沉默着\n[00:38.00]故事你真的在听吗`);
    lrc.set('g5', `[ti:成都]\n[ar:赵雷]\n[00:00.00]成都 - 赵雷\n[00:03.50]余路还要走多久\n[00:08.50]你攥着我的手\n[00:13.50]让我感到为难的\n[00:18.50]是挣扎的自由\n[00:23.50]分别总是在九月\n[00:28.50]回忆是思念的愁\n[00:33.50]深秋嫩绿的垂柳\n[00:38.50]亲吻着我额头`);
    lrc.set('g6', `[ti:理想三旬]\n[ar:陈鸿宇]\n[00:00.00]理想三旬 - 陈鸿宇\n[00:04.00]雨后有车驶来\n[00:09.00]驶过暮色苍白\n[00:14.00]旧铁皮往南开\n[00:19.00]恋人已不在\n[00:24.00]收听浓烟下的\n[00:29.00]诗歌电台`);
    return Promise.resolve(lrc.get(id) || '');
  }
}
