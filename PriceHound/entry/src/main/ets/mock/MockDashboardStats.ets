import { DashboardStats } from '../model/DashboardStats';

/** 预制看板统计 */
export class MockDashboardStats {
  static stats: DashboardStats = {
    totalMonitored: 12,
    todayChanges: 5,
    totalSaved: 1860,
    todaySaved: 120,
  };
}
