import { Category } from '../model/Category';

/** 预制分类 */
export class MockCategories {
  static list: Array<Category> = [
    { id: 'c_audio', name: '音频耳机', icon: '🎧', isSystem: true },
    { id: 'c_tv', name: '电视投影', icon: '📺', isSystem: true },
    { id: 'c_home', name: '家居家电', icon: '🏠', isSystem: true },
    { id: 'c_computer', name: '电脑外设', icon: '💻', isSystem: true },
    { id: 'c_camera', name: '摄影摄像', icon: '📷', isSystem: true },
    { id: 'c_tablet', name: '平板电脑', icon: '📱', isSystem: true },
    { id: 'c_ebook', name: '阅读器', icon: '📖', isSystem: true },
    { id: 'c_other', name: '其他', icon: '📦', isSystem: true },
  ];

  static getById(id: string): Category {
    for (let i = 0; i < MockCategories.list.length; i++) {
      if (MockCategories.list[i].id === id) {
        return MockCategories.list[i];
      }
    }
    return MockCategories.list[MockCategories.list.length - 1];
  }
}
