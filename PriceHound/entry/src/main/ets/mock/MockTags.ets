import { Tag } from '../model/Tag';

/** 预制标签 */
export class MockTags {
  static list: Array<Tag> = [
    { id: 't_wish', name: '心愿单', color: '#c96442', isSystem: true },
    { id: 't_gift', name: '送礼', color: '#d9a441', isSystem: true },
    { id: 't_work', name: '办公', color: '#3898ec', isSystem: true },
    { id: 't_home', name: '居家', color: '#7a9e6b', isSystem: true },
    { id: 't_study', name: '学习', color: '#b53333', isSystem: true },
    { id: 't_cheap', name: '捡漏', color: '#5e5d59', isSystem: false },
  ];

  static getById(id: string): Tag {
    for (let i = 0; i < MockTags.list.length; i++) {
      if (MockTags.list[i].id === id) {
        return MockTags.list[i];
      }
    }
    return MockTags.list[0];
  }
}
