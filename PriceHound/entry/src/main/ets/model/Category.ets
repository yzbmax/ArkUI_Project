/** 分类模型 */
export class Category {
  id: string;
  name: string;
  icon: string;
  isSystem: boolean;   // 系统预置 or 自定义

  constructor() {
    this.id = '';
    this.name = '';
    this.icon = '📦';
    this.isSystem = true;
  }
}
