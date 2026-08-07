/**
 * 瀑布流数据源（LazyForEach 必需）
 * 实现 LazyForEach 所需的结构（totalCount / getData / registerDataChangeListener / unregisterDataChangeListener），
 * 不依赖具体 SDK 包名导入（不同 API 版本 IDataSource 导出路径不一致），用本地接口 + 结构匹配即可被 LazyForEach 接受。
 * 关键方法：pushPage（追加一页并通知）/ reset（整页替换）/ totalCount / getData。
 */
import { WaterfallItemType } from '../models/index';

// 本地最小接口，对应框架 DataChangeListener（仅声明 LazyForEach 实际调用的方法）
interface IDataChangeListener {
  onDataAdd(index: number): void;
  onDataReloaded(): void;
  onDataDelete(index: number): void;
  onDataChange(index: number): void;
  onDataMove(from: number, to: number): void;
}

export class WaterfallDataSource {
  private data: WaterfallItemType[] = [];
  private listeners: IDataChangeListener[] = [];

  constructor(init?: WaterfallItemType[]) {
    if (init) {
      this.data = init.slice();
    }
  }

  // 追加一页数据并逐条通知 LazyForEach 在尾部新增（框架按需渲染可视区域）
  pushPage(items: WaterfallItemType[]): void {
    for (let i = 0; i < items.length; i++) {
      this.data.push(items[i]);
      const idx = this.data.length - 1;
      this.listeners.forEach((l: IDataChangeListener) => {
        l.onDataAdd(idx);
      });
    }
  }

  // 首次加载：整页替换
  reset(items: WaterfallItemType[]): void {
    this.data = items.slice();
    this.listeners.forEach((l: IDataChangeListener) => {
      l.onDataReloaded();
    });
  }

  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): WaterfallItemType {
    return this.data[index];
  }

  registerDataChangeListener(listener: IDataChangeListener): void {
    if (this.listeners.indexOf(listener) === -1) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: IDataChangeListener): void {
    const idx = this.listeners.indexOf(listener);
    if (idx !== -1) {
      this.listeners.splice(idx, 1);
    }
  }
}
