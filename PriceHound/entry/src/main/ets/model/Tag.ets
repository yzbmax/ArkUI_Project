/** 标签模型 */
export class Tag {
  id: string;
  name: string;
  color: string;
  isSystem: boolean;

  constructor() {
    this.id = '';
    this.name = '';
    this.color = '#c96442';
    this.isSystem = true;
  }
}
