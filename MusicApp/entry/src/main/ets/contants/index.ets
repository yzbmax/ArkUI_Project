/**
 * AppStorage 键常量（集中管理，避免魔法字符串）
 * EntryAbility 在窗口创建后写入安全区域；播放器写入 SONG_KEY。
 */
export const SAFE_TOP: string = 'safeTop';    // 顶部安全区高度（px）
export const SAFE_BOTTOM: string = 'safeBottom'; // 底部安全区高度（px）
export const SONG_KEY: string = 'songKey';    // 全局播放状态键（PlayState）
