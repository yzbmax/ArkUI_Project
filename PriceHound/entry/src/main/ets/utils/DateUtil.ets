/** 日期工具类 */
export class DateUtil {
  /** 格式化为 yyyy-MM-dd */
  static formatDate(ts: number): string {
    const d = new Date(ts);
    const y = d.getFullYear();
    const m = DateUtil.pad(d.getMonth() + 1);
    const day = DateUtil.pad(d.getDate());
    return `${y}-${m}-${day}`;
  }

  /** 格式化为 MM-dd HH:mm */
  static formatDateTime(ts: number): string {
    const d = new Date(ts);
    const m = DateUtil.pad(d.getMonth() + 1);
    const day = DateUtil.pad(d.getDate());
    const hh = DateUtil.pad(d.getHours());
    const mm = DateUtil.pad(d.getMinutes());
    return `${m}-${day} ${hh}:${mm}`;
  }

  /** 格式化为 HH:mm */
  static formatTime(ts: number): string {
    const d = new Date(ts);
    return `${DateUtil.pad(d.getHours())}:${DateUtil.pad(d.getMinutes())}`;
  }

  /** 相对时间：刚刚 / x分钟前 / x小时前 / x天前 */
  static relativeTime(ts: number): string {
    const diff = Date.now() - ts;
    if (diff < 60 * 1000) {
      return '刚刚';
    }
    if (diff < 3600 * 1000) {
      return `${Math.floor(diff / 60000)} 分钟前`;
    }
    if (diff < 24 * 3600 * 1000) {
      return `${Math.floor(diff / 3600000)} 小时前`;
    }
    if (diff < 30 * 24 * 3600 * 1000) {
      return `${Math.floor(diff / (24 * 3600000))} 天前`;
    }
    return DateUtil.formatDate(ts);
  }

  /** 今天 0 点时间戳 */
  static startOfToday(): number {
    const d = new Date();
    d.setHours(0, 0, 0, 0);
    return d.getTime();
  }

  /** 日期轴刻度：取整小时 */
  static axisLabel(ts: number, rangeDays: number): string {
    if (rangeDays <= 2) {
      return DateUtil.formatTime(ts);
    }
    return `${DateUtil.pad(new Date(ts).getMonth() + 1)}/${DateUtil.pad(new Date(ts).getDate())}`;
  }

  private static pad(n: number): string {
    return n < 10 ? `0${n}` : `${n}`;
  }
}
