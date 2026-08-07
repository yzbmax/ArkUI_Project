/** 看板统计数据模型 */
export class DashboardStats {
  totalMonitored: number;   // 监控商品数
  todayChanges: number;     // 今日变动
  totalSaved: number;       // 累计节省金额
  todaySaved: number;       // 今日节省

  constructor() {
    this.totalMonitored = 0;
    this.todayChanges = 0;
    this.totalSaved = 0;
    this.todaySaved = 0;
  }
}

/** 看板 Top 5 波动项 */
export class TopMoveItem {
  productId: string;
  productName: string;
  changePercent: number;   // 正=涨价，负=降价
  sparkPoints: Array<number>; // 迷你走势数据

  constructor() {
    this.productId = '';
    this.productName = '';
    this.changePercent = 0;
    this.sparkPoints = [];
  }
}
