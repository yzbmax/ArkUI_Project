/**
 * 前端 Mock 数据仓库（替代后端 B 系列，A006 网络层的数据源）
 * 所有页面数据由此提供，后续接入真实接口时替换此文件即可。
 */
import { Post, Comment, ClaimRecord, ClueRecord, MessageItem, ChatSession, CreditLog, ReportItem } from './Models';
import { PostType, PostStatus } from '../constants/Constants';

export interface PostQuery {
  type?: PostType;
  keyword?: string;
  category?: string;
  urgent?: boolean;
  includePending?: boolean;
}

const IMG1: ResourceStr = $r('app.media.background');
const IMG2: ResourceStr = $r('app.media.foreground');
const IMG3: ResourceStr = $r('app.media.startIcon');

function mkPost(i: number): Post {
  const types = [PostType.LOST, PostType.FOUND];
  const type = types[i % 2];
  const cats = ['card', 'digital', 'key', 'book', 'clothes', 'sport', 'life', 'other'];
  const catNames: Map<string, string> = new Map<string, string>([
    ['card', '证件卡类'], ['digital', '电子数码'], ['key', '钥匙钱包'], ['book', '书本文具'],
    ['clothes', '衣物配饰'], ['sport', '运动器材'], ['life', '生活用品'], ['other', '其他']
  ]);
  const cat = cats[i % cats.length];
  const catName: string = catNames.get(cat) ?? '其他';
  const p = new Post();
  p.id = 'p' + i;
  p.type = type;
  p.title = type === PostType.LOST ? '捡到' + catName : '丢失' + catName;
  p.desc = '大概在图书馆三层自习区' + (type === PostType.LOST ? '捡到' : '丢失') + '的，希望尽快物归原主，请联系我。';
  p.category = cat;
  p.categoryName = catName;
  p.location = ['图书馆', '食堂', '教学楼', '操场', '宿舍'][i % 5];
  p.time = ['10分钟前', '1小时前', '今天 09:30', '昨天', '2天前'][i % 5];
  p.images = i % 3 === 0 ? [IMG1, IMG2, IMG3] : (i % 3 === 1 ? [IMG1] : [IMG1, IMG2]);
  p.contact = '138****' + (1000 + i);
  p.urgent = i % 4 === 0;
  p.reward = i % 3 === 0 ? '奶茶一杯' : '';
  p.status = [PostStatus.PROCESSING, PostStatus.PENDING, PostStatus.RESOLVED, PostStatus.CLOSED][i % 4];
  p.author = ['小南', '阿诚', '林同学', '王同学', '张三'][i % 5];
  p.creditLevel = (i % 5) + 1;
  p.likes = (i * 7) % 50;
  p.comments = (i * 3) % 20;
  return p;
}

export class MockRepo {
  static posts: Post[] = Array.from({ length: 24 }, (_idx: number, i: number): Post => mkPost(i + 1));
  static claims: ClaimRecord[] = [
    { id: 'c1', postTitle: '捡到校园卡', applicant: '李同学', desc: '我在图书馆捡到的，能详细描述颜色和挂绳', status: 'pending', time: '10分钟前' },
    { id: 'c2', postTitle: '丢失耳机', applicant: '赵同学', desc: '是我上周买的，可提供购买记录', status: 'agreed', time: '1小时前' },
    { id: 'c3', postTitle: '捡到钥匙', applicant: '钱同学', desc: '描述相符，请核实', status: 'rejected', time: '昨天' },
    { id: 'c4', postTitle: '丢失水杯', applicant: '孙同学', desc: '想确认一下', status: 'cancelled', time: '2天前' }
  ];
  static clues: ClueRecord[] = [
    { id: 'l1', postTitle: '丢失手机', desc: '我在失物招领处看到过类似的', status: 'valid', time: '20分钟前' },
    { id: 'l2', postTitle: '丢失雨伞', desc: '可能是蓝色那把', status: 'invalid', time: '1小时前' },
    { id: 'l3', postTitle: '丢失钱包', desc: '在食堂捡到，已上交', status: 'pending', time: '今天' }
  ];
  static messages: MessageItem[] = [
    { id: 'm1', type: 'system', title: '系统通知', content: '您的失物信息已通过审核', time: '09:30', unread: true },
    { id: 'm2', type: 'match', title: '智能匹配', content: '为您找到一条高度匹配的失物信息', time: '10:12', unread: true },
    { id: 'm3', type: 'interact', title: '互动消息', content: '有人评论了您的动态', time: '11:05', unread: false },
    { id: 'm4', type: 'chat', title: '私信', content: '你好，请问东西还在吗？', time: '12:00', unread: true }
  ];
  static sessions: ChatSession[] = [
    { id: 's1', peerId: 'u1', name: '小南', avatar: $r('app.media.user'), lastMsg: '东西还在的，方便今天来取吗', time: '12:01', unread: 2,
      messages: [
        { me: false, content: '你好，请问东西还在吗？', time: '11:50' },
        { me: true, content: '在的，你在哪捡到的呀', time: '11:55' },
        { me: false, content: '图书馆三层，可以今天来取', time: '12:00' },
        { me: false, content: '东西还在的，方便今天来取吗', time: '12:01' }
      ] },
    { id: 's2', peerId: 'u2', name: '阿诚', avatar: $r('app.media.user'), lastMsg: '好的谢谢！', time: '昨天', unread: 0,
      messages: [{ me: false, content: '感谢你捡到我的卡', time: '昨天' }, { me: true, content: '不客气~', time: '昨天' }] }
  ];
  static creditLogs: CreditLog[] = [
    { id: 'cr1', event: '发布失物', delta: 2, balance: 102, time: '今天 09:30' },
    { id: 'cr2', event: '有效线索', delta: 10, balance: 100, time: '昨天 15:20' },
    { id: 'cr3', event: '成功认领', delta: 5, balance: 90, time: '3天前' },
    { id: 'cr4', event: '被举报', delta: -5, balance: 85, time: '1周前' }
  ];
  static reports: ReportItem[] = [
    { id: 'r1', target: '动态 p3', reason: '垃圾广告', status: 'pending', time: '今天 08:00' },
    { id: 'r2', target: '用户 李同学', reason: '骚扰私信', status: 'dismissed', time: '昨天' }
  ];
  static auditList: Post[] = MockRepo.posts.filter((p) => p.status === PostStatus.PENDING);

  static getPosts(filter?: PostQuery): Post[] {
    // 返回副本，避免调用方（如就地 sort/mutate）污染全局数据源
    let list = MockRepo.posts.slice();
    // 待审核内容默认不进入前台查询结果，仅审核列表可显式包含
    if (!filter?.includePending) {
      list = list.filter((p) => p.status !== PostStatus.PENDING);
    }
    if (filter?.type) {
      list = list.filter((p) => p.type === filter.type);
    }
    if (filter?.category) {
      list = list.filter((p) => p.category === filter.category);
    }
    if (filter?.urgent) {
      list = list.filter((p) => p.urgent);
    }
    if (filter?.keyword) {
      const kw = filter.keyword.toLowerCase();
      list = list.filter((p) => p.title.toLowerCase().includes(kw) || p.desc.toLowerCase().includes(kw) || p.location.toLowerCase().includes(kw));
    }
    return list;
  }

  static getPost(id: string): Post | null {
    return MockRepo.posts.find((p) => p.id === id) ?? null;
  }

  static toggleLike(id: string): void {
    const p = MockRepo.getPost(id);
    if (p) {
      p.liked = !p.liked;
      p.likes += p.liked ? 1 : -1;
    }
  }

  static toggleCollect(id: string): void {
    const p = MockRepo.getPost(id);
    if (p) {
      p.collected = !p.collected;
    }
  }

  static addComment(id: string, c: Comment): void {
    const p = MockRepo.getPost(id);
    if (p) {
      if (c.replyTo) {
        p.commentList.push(c);
      } else {
        p.commentList.push(c);
      }
      p.comments += 1;
    }
  }

  static addPost(p: Post): void {
    p.id = 'p' + (MockRepo.posts.length + 1);
    MockRepo.posts.unshift(p);
  }
}
