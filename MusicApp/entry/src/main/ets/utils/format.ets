/**
 * 通用工具：时间格式化
 * 将秒数格式化为 mm:ss（用于播放进度 / 总时长展示）。
 */
export function formatTime(sec: number): string {
  let s: number = sec;
  if (s < 0) {
    s = 0;
  }
  const m: number = Math.floor(s / 60);
  const secPart: number = Math.floor(s % 60);
  const mm: string = m < 10 ? '0' + m : '' + m;
  const ss: string = secPart < 10 ? '0' + secPart : '' + secPart;
  return mm + ':' + ss;
}
