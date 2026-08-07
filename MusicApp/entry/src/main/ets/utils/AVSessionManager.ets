/**
 * 媒体会话（F08）：锁屏 / 控制中心
 * 同步封面、歌名、播放控制；注册播控回调驱动 AVPlayerManager。
 * 设计要点：全链路 try/catch，会话不可用时静默降级（不影响页面播放）。
 */
import { avSession } from '@kit.AVSessionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { PlayState } from '../models/index';
import { AVPlayerManager } from './AVPlayerManager';

const DOMAIN = 0x0002;

export class AVSessionManager {
  private static instance: AVSessionManager | null = null;
  private session: avSession.AVSession | null = null;

  static getInstance(): AVSessionManager {
    if (AVSessionManager.instance === null) {
      AVSessionManager.instance = new AVSessionManager();
    }
    return AVSessionManager.instance;
  }

  // 初始化媒体会话（由 EntryAbility 在窗口创建后调用，需要 UIAbilityContext）
  init(context: Context): void {
    try {
      avSession.createAVSession(context, '黑马云音乐', 'audio')
        .then((session: avSession.AVSession) => {
          this.session = session;
          // 注册锁屏 / 控制中心控制回调
          session.on('play', () => {
            AVPlayerManager.getInstance().play();
          });
          session.on('pause', () => {
            AVPlayerManager.getInstance().pause();
          });
          session.on('playNext', () => {
            AVPlayerManager.getInstance().next();
          });
          session.on('playPrevious', () => {
            AVPlayerManager.getInstance().prev();
          });
          session.on('seek', (time: number) => {
            AVPlayerManager.getInstance().seek(time);
          });
          // 支持的播控命令由系统默认提供；如需定制可见性可在此补充 setSupportedControls
        })
        .catch((err: Error) => {
          hilog.error(DOMAIN, 'AVSession', 'create failed: %{public}s', JSON.stringify(err));
        });
    } catch (err) {
      hilog.error(DOMAIN, 'AVSession', 'init error: %{public}s', JSON.stringify(err));
    }
  }

  // 同步播放状态到锁屏 / 控制中心
  update(state: PlayState): void {
    if (!this.session) {
      return;
    }
    try {
      // 元数据（封面 artwork 预留：后续用真实封面 PixelMap/URI 填充）
      const meta: avSession.AVMetadata = {
        assetId: state.title, // 资源唯一标识（预留：后续用真实歌曲 id）
        title: state.title,
        artist: state.artist,
      };
      this.session.setAVMetadata(meta).catch(() => {});

      // 播放状态
      const pbState = state.isPlay
        ? avSession.PlaybackState.PLAYBACK_STATE_PLAY
        : avSession.PlaybackState.PLAYBACK_STATE_PAUSE;
      const pb: avSession.AVPlaybackState = {
        state: pbState,
        position: { elapsedTime: state.time, updateTime: 0 },
      };
      this.session.setAVPlaybackState(pb).catch(() => {});
    } catch (err) {
      hilog.error(DOMAIN, 'AVSession', 'update error: %{public}s', JSON.stringify(err));
    }
  }

  // 释放会话
  destroy(): void {
    if (this.session) {
      try {
        this.session.destroy();
      } catch (err) {
        hilog.error(DOMAIN, 'AVSession', 'destroy error: %{public}s', JSON.stringify(err));
      }
      this.session = null;
    }
  }
}
