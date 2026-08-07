/**
 * 全局常量与枚举（A002 辅助）
 */
export const CAMPUSES: string[] = ['中心校区', '东校区', '西校区', '南校区', '北校区'];

/** 分类项。ArkTS 要求对象字面量必须对应显式声明的类或接口。 */
export interface CategoryItem {
  key: string;
  name: string;
  icon: string;
  sub: string[];
}

export const CATEGORIES: CategoryItem[] = [
  { key: 'card', name: '证件卡类', icon: 'id', sub: ['校园卡', '身份证', '学生证', '其他证件'] },
  { key: 'digital', name: '电子数码', icon: 'smartphone', sub: ['手机', '耳机', '平板', '充电宝', '其他数码'] },
  { key: 'key', name: '钥匙钱包', icon: 'key', sub: ['钥匙', '钱包', '卡包', '其他'] },
  { key: 'book', name: '书本文具', icon: 'book', sub: ['教材', '笔记本', '文具', '其他'] },
  { key: 'clothes', name: '衣物配饰', icon: 'shirt', sub: ['外套', '帽子', '眼镜', '其他'] },
  { key: 'sport', name: '运动器材', icon: 'ball_volleyball', sub: ['球类', '球拍', '护具', '其他'] },
  { key: 'life', name: '生活用品', icon: 'cup', sub: ['水杯', '雨伞', '化妆品', '其他'] },
  { key: 'other', name: '其他', icon: 'grid_dots', sub: ['不详', '其他'] }
];

/** 角色名映射。ArkTS 不支持 Record 无类型字面量，改用 Map。 */
export const ROLE_NAMES: Map<string, string> = new Map<string, string>([
  ['student', '学生'],
  ['teacher', '教师'],
  ['staff', '教职工']
]);

export const CREDIT_TITLES: string[] = ['新人', '热心同学', '校园达人', '失物克星', '校园守护者'];

export enum PostType {
  LOST = 'lost', // 失物（捡到）
  FOUND = 'found' // 寻物（丢失）
}

export enum PostStatus {
  PENDING = 'pending', // 待审核
  PROCESSING = 'processing', // 进行中
  RESOLVED = 'resolved', // 已完结
  CLOSED = 'closed' // 已关闭
}

export const STATUS_LABEL: Map<string, string> = new Map<string, string>([
  ['pending', '待认领'],
  ['processing', '认领中'],
  ['resolved', '已归还'],
  ['closed', '已关闭']
]);

export const STATUS_COLOR: Map<string, Resource> = new Map<string, Resource>([
  ['pending', $r('app.color.status_pending')],
  ['processing', $r('app.color.status_claiming')],
  ['resolved', $r('app.color.status_resolved')],
  ['closed', $r('app.color.status_closed')]
]);
