/**
 * 播放单例（P4 核心，F07 播放 / F08 锁屏的数据源）
 * 负责：play / pause / next / prev / seek / 播放模式切换。
 * 设计要点：
 *  - 全局唯一 AVPlayer，复用不重复创建；
 *  - 全链路 try/catch，缺 URL 时仅更新状态不崩溃（满足 Mock 离线演示）；
 *  - 状态统一写入 AppStorage(SONG_KEY) 的 PlayState，供 Play 页 / Mini-Bar 共享。
 */
import { media } from '@kit.MediaKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PlayState, SongItemType, parseLyric } from '../models/index';
import { SONG_KEY } from '../contants/index';
import { musicRepository } from '../services/index';

const DOMAIN = 0x0001;

export class AVPlayerManager {
  private static instance: AVPlayerManager | null = null;
  private avPlayer: media.AVPlayer | null = null; // 真实播放器（有 URL 时使用）
  private timer: number = -1;                     // 模拟进度定时器（无 URL 时使用）

  // 单例获取
  static getInstance(): AVPlayerManager {
    if (AVPlayerManager.instance === null) {
      AVPlayerManager.instance = new AVPlayerManager();
    }
    return AVPlayerManager.instance;
  }

  // 读取全局播放状态（确保存在）
  private getState(): PlayState {
    let s = AppStorage.get<PlayState>(SONG_KEY) as PlayState;
    if (!s) {
      s = new PlayState();
      AppStorage.setOrCreate(SONG_KEY, s);
    }
    return s;
  }

  /**
   * 单曲播放（点击歌曲时调用）
   * @param song 当前歌曲
   * @param list 播放列表（可选；缺省以单曲为列表）
   */
  singPlay(song: SongItemType, list?: SongItemType[]): void {
    try {
      const s: PlayState = this.getState();
      s.title = song.title;
      s.artist = song.artist;
      s.img = song.img;
      s.color = song.color;
      s.url = song.url;
      s.isPlay = true;
      s.time = 0;
      s.duration = 215; // Mock 默认时长；真实音频由 AVPlayer durationUpdate 覆盖
      // 禁用对象展开：显式重建列表
      if (list && list.length > 0) {
        s.playList = [];
        for (let i = 0; i < list.length; i++) {
          s.playList.push(list[i]);
        }
      } else {
        s.playList = [song];
      }
      s.playIndex = 0;
      this.startPlay(song.url);
      this.loadLyric(song.id);
    } catch (err) {
      hilog.error(DOMAIN, 'AVPlayerManager', 'singPlay failed. Cause: %{public}s', JSON.stringify(err));
    }
  }

  // 切歌时异步加载歌词并写入全局状态（失败/无歌词则清空，不阻塞播放）
  private loadLyric(id: string): void {
    const s = this.getState();
    s.lyricLines = [];
    musicRepository.getLyric(id).then((lrc: string) => {
      // 仅当当前仍是同一首歌时才写入，避免快速切歌串歌词
      if (this.getState().playList[this.getState().playIndex]?.id === id) {
        s.lyricLines = parseLyric(lrc);
      }
    });
  }

  // 根据 URL 决定走真实播放器还是模拟进度
  private startPlay(url: string): void {
    if (url && url.length > 0) {
      this.startAVPlayer(url);
    } else {
      this.startFakeTicker(); // 离线演示：模拟进度推进
    }
  }

  // 真实 AVPlayer 播放（有 URL 时）
  private startAVPlayer(url: string): void {
    try {
      media.createAVPlayer((err: Error | null, player: media.AVPlayer) => {
        if (err || !player) {
          // 创建失败退回模拟进度，保证不崩溃
          this.startFakeTicker();
          return;
        }
        this.avPlayer = player;
        // 时长更新
        player.on('durationUpdate', () => {
          const s = this.getState();
          s.duration = player.duration / 1000;
        });
        // 进度更新
        player.on('timeUpdate', () => {
          const s = this.getState();
          s.time = player.currentTime / 1000;
        });
        // 状态机
        player.on('stateChange', (state: string) => {
          const s = this.getState();
          if (state === 'prepared') {
            player.play();
          } else if (state === 'playing') {
            s.isPlay = true;
          } else if (state === 'paused') {
            s.isPlay = false;
          } else if (state === 'completed') {
            this.onTrackEnd();
          }
        });
        player.url = url;
        player.prepare();
      });
    } catch (err) {
      hilog.error(DOMAIN, 'AVPlayerManager', 'startAVPlayer failed. Cause: %{public}s', JSON.stringify(err));
      this.startFakeTicker();
    }
  }

  // 模拟进度（无真实音频时，每秒推进，使进度条/唱片动画可演示）
  private startFakeTicker(): void {
    this.stopTimer();
    this.timer = setInterval(() => {
      const s = this.getState();
      if (!s.isPlay) {
        return;
      }
      s.time = s.time + 1;
      if (s.time >= s.duration) {
        this.onTrackEnd();
        return;
      }
    }, 1000) as number;
  }

  // 停止模拟定时器
  private stopTimer(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  // 一首结束：按播放模式决定下一首或停止
  private onTrackEnd(): void {
    const s = this.getState();
    if (s.playMode === 'repeat') {
      s.time = 0;
      this.startPlay(s.url);
    } else {
      this.next();
    }
  }

  // 播放
  play(): void {
    const s = this.getState();
    s.isPlay = true;
    if (this.avPlayer) {
      try {
        this.avPlayer.play();
      } catch (err) {
        hilog.error(DOMAIN, 'AVPlayerManager', 'play failed. Cause: %{public}s', JSON.stringify(err));
      }
    } else {
      this.startPlay(s.url); // 重新拉起（模拟或真实）
    }
  }

  // 暂停
  pause(): void {
    const s = this.getState();
    s.isPlay = false;
    if (this.avPlayer) {
      try {
        this.avPlayer.pause();
      } catch (err) {
        hilog.error(DOMAIN, 'AVPlayerManager', 'pause failed. Cause: %{public}s', JSON.stringify(err));
      }
    }
  }

  // 切换播放/暂停
  toggle(): void {
    const s = this.getState();
    if (s.isPlay) {
      this.pause();
    } else {
      this.play();
    }
  }

  // 下一首
  next(): void {
    const s = this.getState();
    if (s.playList.length === 0) {
      return;
    }
    if (s.playMode === 'random') {
      s.playIndex = Math.floor(Math.random() * s.playList.length);
    } else {
      s.playIndex = (s.playIndex + 1) % s.playList.length;
    }
    this.applyCurrentIndex(s);
  }

  // 上一首
  prev(): void {
    const s = this.getState();
    if (s.playList.length === 0) {
      return;
    }
    if (s.playMode === 'random') {
      s.playIndex = Math.floor(Math.random() * s.playList.length);
    } else {
      s.playIndex = (s.playIndex - 1 + s.playList.length) % s.playList.length;
    }
    this.applyCurrentIndex(s);
  }

  // 应用当前索引指向的歌曲
  private applyCurrentIndex(s: PlayState): void {
    const song = s.playList[s.playIndex];
    if (!song) {
      return;
    }
    s.title = song.title;
    s.artist = song.artist;
    s.img = song.img;
    s.color = song.color;
    s.url = song.url;
    s.time = 0;
    s.isPlay = true;
    this.startPlay(song.url);
    this.loadLyric(song.id);
  }

  // 跳转进度（秒）
  seek(time: number): void {
    const s = this.getState();
    s.time = time;
    if (this.avPlayer) {
      try {
        this.avPlayer.seek(time * 1000);
      } catch (err) {
        hilog.error(DOMAIN, 'AVPlayerManager', 'seek failed. Cause: %{public}s', JSON.stringify(err));
      }
    }
  }

  // 播放模式三态切换：auto → repeat → random
  switchMode(): void {
    const s = this.getState();
    if (s.playMode === 'auto') {
      s.playMode = 'repeat';
    } else if (s.playMode === 'repeat') {
      s.playMode = 'random';
    } else {
      s.playMode = 'auto';
    }
  }

  // 选中播放列表中指定曲目（点击列表项时调用）
  select(index: number): void {
    const s = this.getState();
    if (index < 0 || index >= s.playList.length) {
      return;
    }
    s.playIndex = index;
    this.applyCurrentIndex(s);
  }

  // 从播放列表移除指定曲目（左滑删除）
  removeFromList(index: number): void {
    const s = this.getState();
    if (index < 0 || index >= s.playList.length) {
      return;
    }
    // 禁用对象展开：显式重建数组
    const newList: SongItemType[] = [];
    for (let i = 0; i < s.playList.length; i++) {
      if (i !== index) {
        newList.push(s.playList[i]);
      }
    }
    s.playList = newList;
    // 若删除的是当前曲目，跳到新列表首项
    if (index === s.playIndex) {
      if (newList.length > 0) {
        s.playIndex = 0;
        this.applyCurrentIndex(s);
      } else {
        s.isPlay = false;
        s.title = '';
        s.artist = '';
      }
    } else if (index < s.playIndex) {
      s.playIndex = s.playIndex - 1;
    }
  }

  // 释放资源（Ability 销毁时调用）
  release(): void {
    this.stopTimer();
    if (this.avPlayer) {
      try {
        this.avPlayer.release();
      } catch (err) {
        hilog.error(DOMAIN, 'AVPlayerManager', 'release failed. Cause: %{public}s', JSON.stringify(err));
      }
      this.avPlayer = null;
    }
  }
}
