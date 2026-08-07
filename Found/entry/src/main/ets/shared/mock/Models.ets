/**
 * 数据模型定义
 */
import { PostType, PostStatus } from '../constants/Constants';

export class Comment {
  id: string = '';
  userId: string = '';
  author: string = '';
  avatar: ResourceStr = $r('app.media.user');
  content: string = '';
  time: string = '';
  replyTo: string = ''; // 楼中楼回复目标昵称
  replies: Comment[] = [];
}

export class Post {
  id: string = '';
  userId: string = '';
  type: PostType = PostType.LOST;
  title: string = '';
  desc: string = '';
  category: string = 'card';
  categoryName: string = '证件卡类';
  location: string = '';
  time: string = '';
  images: ResourceStr[] = [];
  contact: string = '';
  verifyQuestion: string = '';
  anonymous: boolean = false;
  urgent: boolean = false;
  reward: string = '';
  status: PostStatus = PostStatus.PROCESSING;
  rejectReason: string = '';
  author: string = '热心同学';
  authorAvatar: ResourceStr = $r('app.media.user');
  creditLevel: number = 1;
  likes: number = 0;
  comments: number = 0;
  liked: boolean = false;
  collected: boolean = false;
  commentList: Comment[] = [];
}

export class ClaimRecord {
  id: string = '';
  postTitle: string = '';
  applicant: string = '';
  desc: string = '';
  status: 'pending' | 'agreed' | 'rejected' | 'cancelled' = 'pending';
  time: string = '';
}

export class ClueRecord {
  id: string = '';
  postTitle: string = '';
  desc: string = '';
  status: 'valid' | 'invalid' | 'pending' = 'pending';
  time: string = '';
}

export class MessageItem {
  id: string = '';
  type: 'system' | 'match' | 'interact' | 'chat' = 'system';
  title: string = '';
  content: string = '';
  time: string = '';
  unread: boolean = true;
}

/** 聊天消息。ArkTS 要求数组元素为可推导的显式类型。 */
export interface ChatMessage {
  me: boolean;
  content: string;
  time: string;
}

export class ChatSession {
  id: string = '';
  peerId: string = '';
  name: string = '';
  avatar: ResourceStr = $r('app.media.user');
  lastMsg: string = '';
  time: string = '';
  unread: number = 0;
  messages: ChatMessage[] = [];
}

export class CreditLog {
  id: string = '';
  event: string = '';
  delta: number = 0;
  balance: number = 0;
  time: string = '';
}

export class ReportItem {
  id: string = '';
  target: string = '';
  reason: string = '';
  status: 'pending' | 'dismissed' | 'warned' | 'deleted' | 'frozen' = 'pending';
  time: string = '';
}
