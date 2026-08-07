/**
 * 数据模型（PRD §5）
 * 页面与组件仅依赖这些契约，与数据来源（Mock / 真实接口）解耦。
 */

/** Tab 定义。icon 预留真实图标资源位置，本期不依赖图片，用占位框替代（见 components/common.ets）。 */
export interface TabType {
  text: string; // 标签文字
  name: string; // 唯一标识（用于 ForEach key）
  // 预留图标位置：后续替换为 $r('app.media.ic_xxx') 等 Resource；本期留空
  icon?: Resource;
}

/** 轮播 banner */
export interface SwiperType {
  id: string;
  img: string;   // 预留封面图位置（本期用 color 占位）
  color: string; // Mock 视觉占位色
  title: string;
}

/** 每日推荐 */
export interface DailyRecommendType {
  id: string;
  img: string;   // 预留封面图位置
  color: string; // Mock 视觉占位色
  title: string;
  type: string;  // 类型标签（如「私人雷达」）
  top: string;   // 角标文案（如「每日」）
  bottom: string;
}

/** 推荐歌单 */
export interface RecommendListType {
  id: string;
  img: string;   // 预留封面图位置
  color: string; // Mock 视觉占位色
  title: string;
  count: string; // 播放量文案（如「128万」）
}

/** 歌曲 */
export interface SongItemType {
  id: string;
  img: string;   // 预留封面图位置
  color: string; // Mock 视觉占位色（真实数据可忽略）
  title: string;
  artist: string;
  url: string;   // 音频地址（Mock 为空，播放器缺 URL 时仅更新状态不崩溃）
}

/** 动态 */
export interface MomentListType {
  id: string;
  author: string;
  avatar: string;  // 预留头像图位置（本期用 color 占位）
  avatarColor: string;
  content: string;
  comment: number;
  like: number;
  share: number;
  song: SongItemType; // 内嵌歌曲卡片
}

/** 用户信息 */
export interface UserType {
  name: string;
  vip: boolean;
  age: number;
  star: string;  // 星座
  city: string;
  follow: number;
  fans: number;
  avatar: string;     // 预留头像图位置
  avatarColor: string;
  collects: SongItemType[]; // 收藏封面（用于 GridRow）
}

/** 瀑布流卡片（推荐页「发现更多」区块，支持无限加载） */
export interface WaterfallItemType {
  id: string;
  img: string;     // 封面图 URL
  color: string;   // 占位/兜底色
  title: string;   // 歌单/专辑标题
  artist: string;  // 作者/歌手
  count: string;   // 播放量文案
  ratio: number;   // 封面宽高比（高度变体，实现错落布局），如 1=正方形、1.3 偏长
}

/**
 * 歌词单行（含时间偏移，单位秒）
 */
export interface LyricLine {
  time: number; // 该行起始时间（秒）
  text: string; // 歌词文本
}

/**
 * 全局播放状态（核心类）
 * 使用 @Observed + @Track 保证 @StorageLink 能感知字段变化，
 * 避免「getter/对象展开」导致的不刷新问题。
 */
@Observed
export class PlayState {
  @Track img: string = '';
  @Track color: string = '';
  @Track title: string = '';
  @Track artist: string = '';
  @Track url: string = '';
  @Track playIndex: number = 0;
  @Track time: number = 0;
  @Track duration: number = 0;
  @Track isPlay: boolean = false;
  // 播放模式：auto 顺序 / repeat 单曲循环 / random 随机
  @Track playMode: 'auto' | 'repeat' | 'random' = 'auto';
  @Track playList: SongItemType[] = [];
  // 歌词（解析后的逐行，含时间；为空表示无歌词/加载中）
  @Track lyricLines: LyricLine[] = [];
}

/**
 * 解析 LRC 文本（[mm:ss.xx] 行内时间标签）为 LyricLine[]，按时间升序。
 * 无时间标签的行（如标题/作者）跳过其标签仅保留文本；纯文本行 time=0。
 */
export function parseLyric(lrc: string): LyricLine[] {
  const lines: LyricLine[] = [];
  if (!lrc || lrc.length === 0) {
    return lines;
  }
  const raw = lrc.split('\n');
  const tagReg = /\[(\d{1,2}):(\d{1,2})(?:[.:](\d{1,3}))?\]/g;
  for (let i = 0; i < raw.length; i++) {
    const line = raw[i];
    // 收集该行所有时间标签
    const times: number[] = [];
    let match: RegExpExecArray | null = tagReg.exec(line);
    let lastIndex = 0;
    while (match !== null) {
      const min = parseInt(match[1], 10) || 0;
      const sec = parseInt(match[2], 10) || 0;
      const msStr = match[3] || '0';
      const ms = parseInt(msStr, 10) || 0;
      // 兼容 2 位（百分秒）与 3 位（毫秒）
      const frac = msStr.length >= 3 ? ms : ms * 10;
      times.push(min * 60 + sec + frac / 1000);
      lastIndex = tagReg.lastIndex;
      match = tagReg.exec(line);
    }
    const text = line.substring(lastIndex).trim();
    if (text.length === 0 && times.length === 0) {
      continue;
    }
    if (times.length === 0) {
      // 无时间标签：归到 0 秒（如 [ti:]/[ar:] 元信息或纯文本）
      lines.push({ time: 0, text: text });
    } else {
      for (let t = 0; t < times.length; t++) {
        lines.push({ time: times[t], text: text });
      }
    }
  }
  // 按时间升序排序
  lines.sort((a: LyricLine, b: LyricLine) => a.time - b.time);
  return lines;
}
