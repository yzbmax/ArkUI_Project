/** 通知模型 */
export class AppNotification {
  id: string;
  title: string;
  content: string;
  time: number;         // 时间戳 ms
  isRead: boolean;
  productId: string;

  constructor() {
    this.id = '';
    this.title = '';
    this.content = '';
    this.time = Date.now();
    this.isRead = false;
    this.productId = '';
  }
}
