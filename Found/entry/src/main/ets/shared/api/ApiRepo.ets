/**
 * API 数据仓库（A006 数据源）—— 替代 MockRepo 对接后端
 * 方法签名尽量对齐 MockRepo；全部 async；JSON → Models 显式字段映射。
 */
import { HttpClient, IMG_PREFIX } from './HttpClient';
import { fileIo } from '@kit.CoreFileKit';
import { util } from '@kit.ArkTS';
import { Post, Comment, ReportItem, ChatSession, ChatMessage, MessageItem, CreditLog, ClaimRecord, ClueRecord } from '../mock/Models';
import { PostType, PostStatus } from '../constants/Constants';
import { UserProfile, UserData, userFromJson } from '../store/AppStore';

/* ============ 查询 / 分页类型 ============ */
export interface PostQuery {
  type?: PostType;
  category?: string;
  keyword?: string;
  urgent?: boolean;
  includePending?: boolean;
  sort?: string;
}

export class PageResult<T> {
  list: T[] = [];
  total: number = 0;
  page: number = 1;
  size: number = 50;
  hasMore: boolean = false;
}

/* ============ 后端原始结构（数据层） ============ */
interface RawPost {
  id: string;
  userId: string;
  type: string;
  title: string;
  desc: string;
  category: string;
  categoryName: string;
  location: string;
  time: string;
  images: string[];
  contact: string;
  verifyQuestion: string;
  anonymous: boolean;
  urgent: boolean;
  reward: string;
  status: string;
  rejectReason: string;
  author: string;
  authorAvatar: string;
  creditLevel: number;
  likes: number;
  comments: number;
  liked: boolean;
  collected: boolean;
}

interface RawComment {
  id: string;
  userId: string;
  author: string;
  avatar: string;
  content: string;
  time: string;
  replyTo: string;
  replies: RawComment[];
}

interface RawReport {
  id: string;
  target: string;
  reason: string;
  status: string;
  time: string;
}

interface RawChatSession {
  id: string;
  peerId: string;
  name: string;
  lastMsg: string;
  time: string;
  unread: number;
  messages: ChatMessage[];
}

interface ChatListData {
  list: RawChatSession[];
}

interface RawChatMessage {
  id: string;
  me: boolean;
  content: string;
  time: string;
}

interface RawPostDetail extends RawPost {
  commentList: RawComment[];
}

interface LikeResult {
  liked: boolean;
  likeCount: number;
}

interface CollectResult {
  collected: boolean;
}

interface OkResult {
  ok: boolean;
}

interface RawLogin {
  token: string;
  user: UserData;
}

interface AdminUser {
  id: string;
  phone: string;
  nickname: string;
  role: string;
  department: string;
  campus: string;
  creditScore: number;
  status: string;
  createdAt: string;
}

export interface ClaimItem {
  id: string;
  postId: string;
  postTitle: string;
  claimant: string;
  desc: string;
  verifyAnswer: string;
  status: string;
  time: string;
}

export interface ClueItem {
  id: string;
  postId: string;
  postTitle: string;
  provider: string;
  content: string;
  helpful: boolean;
  time: string;
}

interface ClaimListData {
  list: ClaimItem[];
}

interface ClueListData {
  list: ClueItem[];
}

/* ---- 消息通知 / 积分 / 我的认领线索（本次接线） ---- */
interface RawNotification {
  id: string;
  type: string;
  title: string;
  content: string;
  time: string;
  unread: boolean;
}

interface RawNotifData {
  system: RawNotification[];
  match: RawNotification[];
  interact: RawNotification[];
}

interface RawMyClaim {
  id: string;
  postTitle: string;
  applicant: string;
  desc: string;
  status: string;
  time: string;
}

interface RawMyClue {
  id: string;
  postTitle: string;
  desc: string;
  status: string;
  time: string;
}

interface RawCreditLog {
  id: string;
  event: string;
  delta: number;
  balance: number;
  time: string;
}

interface RawCredit {
  balance: number;
  level: number;
  logs: RawCreditLog[];
}

interface MyClaimListData {
  list: RawMyClaim[];
}

interface MyClueListData {
  list: RawMyClue[];
}

export class NotifData {
  system: MessageItem[] = [];
  match: MessageItem[] = [];
  interact: MessageItem[] = [];
}

export class CreditData {
  balance: number = 0;
  level: number = 1;
  logs: CreditLog[] = [];
}

/* ============ 请求 / 响应体 ============ */
export class LoginBody {
  phone: string = '';
  password: string = '';
}

export class RegisterBody {
  phone: string = '';
  password: string = '';
  nickname: string = '';
  role: string = '';
  studentId: string = '';
  realName: string = '';
  department: string = '';
  campus: string = '';
}

export class PostBody {
  type: string = '';
  title: string = '';
  desc: string = '';
  category: string = '';
  categoryName: string = '';
  location: string = '';
  contact: string = '';
  verifyQuestion: string = '';
  anonymous: boolean = false;
  urgent: boolean = false;
  reward: string = '';
  images: string[] = [];
}

export class UploadBody {
  images: string[] = [];
}

export class UploadResult {
  urls: string[] = [];
}

export class CommentBody {
  content: string = '';
  parentId: string = '';
  replyToUserId: string = '';
}

export class AuditBody {
  reason: string = '';
}

export class ClaimBody {
  postId: string = '';
  description: string = '';
  verifyAnswer: string = '';
}

export class ClueBody {
  postId: string = '';
  content: string = '';
}

export class ClaimStatusBody {
  status: string = '';
}

export class ClueHelpfulBody {
  helpful: boolean = false;
}

export class ReportBody {
  reason: string = '';
  description: string = '';
}

export class SendChatBody {
  content: string = '';
}

export class ForgotBody {
  phone: string = '';
  newPassword: string = '';
}

export class ProfileBody {
  nickname: string = '';
  campus: string = '';
  avatar: string = '';
}

export class HandleReportBody {
  status: string = '';
  result: string = '';
}

export class LoginResult {
  token: string = '';
  user: UserProfile = new UserProfile();
}

/* ============ 映射器 ============ */
function commentFromJson(r: RawComment): Comment {
  const c = new Comment();
  c.id = r.id;
  c.userId = r.userId || '';
  c.author = r.author;
  c.avatar = r.avatar || '';
  c.content = r.content;
  c.time = r.time;
  c.replyTo = r.replyTo || '';
  c.replies = r.replies.map((rr: RawComment): Comment => commentFromJson(rr));
  return c;
}

export class ApiRepo {
  static postFromJson(r: RawPost): Post {
    const p = new Post();
    p.id = r.id;
    p.userId = r.userId;
    p.type = r.type === 'found' ? PostType.FOUND : PostType.LOST;
    p.title = r.title;
    p.desc = r.desc;
    p.category = r.category;
    p.categoryName = r.categoryName;
    p.location = r.location;
    p.time = r.time;
    p.images = r.images.map((u: string): ResourceStr => IMG_PREFIX + u);
    p.contact = r.contact;
    p.verifyQuestion = r.verifyQuestion;
    p.anonymous = r.anonymous;
    p.urgent = r.urgent;
    p.reward = r.reward;
    p.status = r.status as PostStatus;
    p.rejectReason = r.rejectReason;
    p.author = r.author;
    p.authorAvatar = r.authorAvatar;
    p.creditLevel = r.creditLevel;
    p.likes = r.likes;
    p.comments = r.comments;
    p.liked = r.liked;
    p.collected = r.collected;
    return p;
  }

  /* ============ 动态 ============ */
  static async getPosts(filter?: PostQuery, page: number = 1, size: number = 50): Promise<PageResult<Post>> {
    let q: string = '?page=' + page + '&size=' + size;
    if (filter && filter.type) {
      q += '&type=' + filter.type;
    }
    if (filter && filter.category) {
      q += '&category=' + encodeURIComponent(filter.category);
    }
    if (filter && filter.keyword) {
      q += '&keyword=' + encodeURIComponent(filter.keyword);
    }
    if (filter && filter.urgent) {
      q += '&urgent=1';
    }
    if (filter && filter.includePending) {
      q += '&includePending=1';
    }
    if (filter && filter.sort) {
      q += '&sort=' + filter.sort;
    }
    const raw = await HttpClient.get<PageResult<RawPost>>('/api/posts' + q);
    const result = new PageResult<Post>();
    result.total = raw.total;
    result.page = raw.page;
    result.size = raw.size;
    result.hasMore = raw.hasMore;
    result.list = raw.list.map((r: RawPost): Post => ApiRepo.postFromJson(r));
    return result;
  }

  static async getPost(id: string): Promise<Post> {
    const detail = await HttpClient.get<RawPostDetail>('/api/posts/' + id);
    const p = ApiRepo.postFromJson(detail);
    p.commentList = detail.commentList.map((c: RawComment): Comment => commentFromJson(c));
    return p;
  }

  static async toggleLike(id: string): Promise<Post> {
    const d = await HttpClient.post<LikeResult>('/api/posts/' + id + '/like');
    const p = await ApiRepo.getPost(id);
    p.liked = d.liked;
    p.likes = d.likeCount;
    return p;
  }

  static async toggleCollect(id: string): Promise<Post> {
    const d = await HttpClient.post<CollectResult>('/api/posts/' + id + '/collect');
    const p = await ApiRepo.getPost(id);
    p.collected = d.collected;
    return p;
  }

  static async closePost(id: string): Promise<Post> {
    const raw = await HttpClient.post<RawPost>('/api/posts/' + id + '/close');
    return ApiRepo.postFromJson(raw);
  }

  static async addPost(p: Post, imageUrls?: string[]): Promise<Post> {
    const body = new PostBody();
    body.type = p.type;
    body.title = p.title;
    body.desc = p.desc;
    body.category = p.category;
    body.categoryName = p.categoryName;
    body.location = p.location;
    body.contact = p.contact;
    body.verifyQuestion = p.verifyQuestion;
    body.anonymous = p.anonymous;
    body.urgent = p.urgent;
    body.reward = p.reward;
    body.images = imageUrls ?? [];
    const raw = await HttpClient.post<RawPost>('/api/posts', body);
    return ApiRepo.postFromJson(raw);
  }

  /** 上传 base64 图片，返回相对 URL 列表 */
  static async uploadImages(images: string[]): Promise<UploadResult> {
    const body = new UploadBody();
    body.images = images;
    const raw = await HttpClient.post<UploadResult>('/api/upload', body);
    const result = new UploadResult();
    result.urls = raw.urls;
    return result;
  }

  /** 读取本地文件 URI → base64（用于发布图片上传） */
  static async readFileToBase64(uri: string): Promise<string> {
    try {
      const file = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      const stat = fileIo.statSync(file.fd);
      const buf = new ArrayBuffer(stat.size);
      fileIo.readSync(file.fd, buf);
      fileIo.closeSync(file);
      return new util.Base64Helper().encodeToStringSync(new Uint8Array(buf));
    } catch (e) {
      return '';
    }
  }

  static async addComment(postId: string, content: string, parentId: string = '', replyToUserId: string = ''): Promise<Comment> {
    const body = new CommentBody();
    body.content = content;
    body.parentId = parentId;
    body.replyToUserId = replyToUserId;
    const raw = await HttpClient.post<RawComment>('/api/posts/' + postId + '/comments', body);
    return commentFromJson(raw);
  }

  /* ============ 我的发布 / 用户 ============ */
  static async myPosts(status?: string, type?: string): Promise<Post[]> {
    let q: string = '?';
    if (status) {
      q += 'status=' + status + '&';
    }
    if (type) {
      q += 'type=' + type + '&';
    }
    const raw = await HttpClient.get<PageResult<RawPost>>('/api/users/me/posts' + q);
    return raw.list.map((r: RawPost): Post => ApiRepo.postFromJson(r));
  }

  /** 我的收藏列表（P19） */
  static async fetchMyCollects(): Promise<Post[]> {
    const raw = await HttpClient.get<PageResult<RawPost>>('/api/users/me/collects');
    return raw.list.map((r: RawPost): Post => ApiRepo.postFromJson(r));
  }

  /* ============ 认领 / 线索 / 举报 ============ */
  static async submitClaim(postId: string, description: string, verifyAnswer: string): Promise<void> {
    const body = new ClaimBody();
    body.postId = postId;
    body.description = description;
    body.verifyAnswer = verifyAnswer;
    await HttpClient.post<OkResult>('/api/claims', body);
  }

  static async fetchReceivedClaims(): Promise<ClaimItem[]> {
    const raw = await HttpClient.get<ClaimListData>('/api/claims/received');
    return raw.list;
  }

  static async handleClaim(id: string, status: string): Promise<void> {
    const body = new ClaimStatusBody();
    body.status = status;
    await HttpClient.put<OkResult>('/api/claims/' + id + '/status', body);
  }

  static async submitClue(postId: string, content: string): Promise<void> {
    const body = new ClueBody();
    body.postId = postId;
    body.content = content;
    await HttpClient.post<OkResult>('/api/clues', body);
  }

  static async fetchReceivedClues(): Promise<ClueItem[]> {
    const raw = await HttpClient.get<ClueListData>('/api/clues/received');
    return raw.list;
  }

  static async handleClue(id: string, helpful: boolean): Promise<void> {
    const body = new ClueHelpfulBody();
    body.helpful = helpful;
    await HttpClient.put<OkResult>('/api/clues/' + id + '/helpful', body);
  }

  static async resolvePost(id: string): Promise<Post> {
    const raw = await HttpClient.post<RawPost>('/api/posts/' + id + '/resolve');
    return ApiRepo.postFromJson(raw);
  }

  static async reportPost(id: string, reason: string, description: string): Promise<void> {
    const body = new ReportBody();
    body.reason = reason;
    body.description = description;
    await HttpClient.post<OkResult>('/api/posts/' + id + '/report', body);
  }

  /* ============ 私信 ============ */
  static async fetchChats(): Promise<ChatSession[]> {
    const raw = await HttpClient.get<ChatListData>('/api/chats');
    return raw.list.map((r: RawChatSession): ChatSession => {
      const s = new ChatSession();
      s.id = r.id;
      s.peerId = r.peerId;
      s.name = r.name;
      s.lastMsg = r.lastMsg;
      s.time = r.time;
      s.unread = r.unread;
      s.messages = (r.messages || []).map((m: ChatMessage): ChatMessage => ({ me: m.me, content: m.content, time: m.time }));
      return s;
    });
  }

  static async sendChat(peerId: string, content: string): Promise<ChatMessage> {
    const body = new SendChatBody();
    body.content = content;
    const raw = await HttpClient.post<RawChatMessage>('/api/chats/' + peerId, body);
    return { me: true, content: raw.content, time: raw.time };
  }

  /* ============ 消息通知 ============ */
  static async fetchNotifications(): Promise<NotifData> {
    const raw = await HttpClient.get<RawNotifData>('/api/notifications');
    const map = (arr: RawNotification[]): MessageItem[] => arr.map((r: RawNotification): MessageItem => {
      const m = new MessageItem();
      m.id = r.id;
      m.type = r.type as 'system' | 'match' | 'interact' | 'chat';
      m.title = r.title;
      m.content = r.content;
      m.time = r.time;
      m.unread = r.unread;
      return m;
    });
    const d = new NotifData();
    d.system = map(raw.system);
    d.match = map(raw.match);
    d.interact = map(raw.interact);
    return d;
  }

  static async markNotifRead(type: string): Promise<void> {
    await HttpClient.put<OkResult>('/api/notifications/' + type + '/read');
  }

  /* ============ 信用积分 ============ */
  static async fetchCredit(): Promise<CreditData> {
    const raw = await HttpClient.get<RawCredit>('/api/credit/logs');
    const d = new CreditData();
    d.balance = raw.balance;
    d.level = raw.level;
    d.logs = raw.logs.map((l: RawCreditLog): CreditLog => {
      const c = new CreditLog();
      c.id = l.id;
      c.event = l.event;
      c.delta = l.delta;
      c.balance = l.balance;
      c.time = l.time;
      return c;
    });
    return d;
  }

  /* ============ 我的认领 / 线索 ============ */
  static async fetchMyClaims(): Promise<ClaimRecord[]> {
    const raw = await HttpClient.get<MyClaimListData>('/api/claims');
    return raw.list.map((r: RawMyClaim): ClaimRecord => {
      const c = new ClaimRecord();
      c.id = r.id;
      c.postTitle = r.postTitle;
      c.applicant = r.applicant;
      c.desc = r.desc;
      // 后端 approved → 前端 agreed
      c.status = (r.status === 'approved' ? 'agreed' : r.status) as ('pending' | 'agreed' | 'rejected' | 'cancelled');
      c.time = r.time;
      return c;
    });
  }

  static async fetchMyClues(): Promise<ClueRecord[]> {
    const raw = await HttpClient.get<MyClueListData>('/api/clues');
    return raw.list.map((r: RawMyClue): ClueRecord => {
      const c = new ClueRecord();
      c.id = r.id;
      c.postTitle = r.postTitle;
      c.desc = r.desc;
      c.status = r.status as ('valid' | 'invalid' | 'pending');
      c.time = r.time;
      return c;
    });
  }

  static async login(phone: string, password: string): Promise<LoginResult> {
    const body = new LoginBody();
    body.phone = phone;
    body.password = password;
    const raw = await HttpClient.post<RawLogin>('/api/auth/login', body);
    const result = new LoginResult();
    result.token = raw.token;
    result.user = userFromJson(raw.user);
    return result;
  }

  static async register(body: RegisterBody): Promise<LoginResult> {
    const raw = await HttpClient.post<RawLogin>('/api/auth/register', body);
    const result = new LoginResult();
    result.token = raw.token;
    result.user = userFromJson(raw.user);
    return result;
  }

  static async me(): Promise<UserProfile> {
    const raw = await HttpClient.get<UserData>('/api/auth/me');
    return userFromJson(raw);
  }

  /** 找回密码：手机号 + 新密码直接重置 */
  static async forgotPassword(phone: string, newPassword: string): Promise<void> {
    const body = new ForgotBody();
    body.phone = phone;
    body.newPassword = newPassword;
    await HttpClient.post<OkResult>('/api/auth/forgot-password', body);
  }

  /** 更新我的资料（昵称 / 校区 / 头像相对路径） */
  static async updateProfile(nickname: string, campus: string, avatar: string): Promise<UserProfile> {
    const body = new ProfileBody();
    body.nickname = nickname;
    body.campus = campus;
    body.avatar = avatar;
    const raw = await HttpClient.put<UserData>('/api/users/me', body);
    return userFromJson(raw);
  }

  /* ============ 管理端 ============ */
  static async fetchAudits(): Promise<Post[]> {
    const raw = await HttpClient.get<PageResult<RawPost>>('/api/admin/audits?size=100');
    return raw.list.map((r: RawPost): Post => ApiRepo.postFromJson(r));
  }

  static async approveAudit(id: string): Promise<Post> {
    const raw = await HttpClient.post<RawPost>('/api/admin/audits/' + id + '/approve');
    return ApiRepo.postFromJson(raw);
  }

  static async rejectAudit(id: string, reason: string): Promise<Post> {
    const body = new AuditBody();
    body.reason = reason;
    const raw = await HttpClient.post<RawPost>('/api/admin/audits/' + id + '/reject', body);
    return ApiRepo.postFromJson(raw);
  }

  static async fetchReports(): Promise<ReportItem[]> {
    const raw = await HttpClient.get<PageResult<RawReport>>('/api/admin/reports?size=100');
    return raw.list.map((r: RawReport): ReportItem => ApiRepo.reportFromJson(r));
  }

  static reportFromJson(r: RawReport): ReportItem {
    const item = new ReportItem();
    item.id = r.id;
    item.target = r.target;
    item.reason = r.reason;
    item.status = r.status as 'pending' | 'dismissed' | 'warned' | 'deleted' | 'frozen';
    item.time = r.time;
    return item;
  }

  static async handleReport(id: string, status: string, result: string): Promise<void> {
    const body = new HandleReportBody();
    body.status = status;
    body.result = result;
    await HttpClient.post<OkResult>('/api/admin/reports/' + id + '/handle', body);
  }

  static async fetchUsers(): Promise<UserProfile[]> {
    const raw = await HttpClient.get<PageResult<AdminUser>>('/api/admin/users?size=100');
    return raw.list.map((u: AdminUser): UserProfile => {
      const p = new UserProfile();
      p.id = u.id;
      p.nickname = u.nickname;
      p.role = u.role;
      p.campus = u.campus;
      p.creditScore = u.creditScore;
      return p;
    });
  }
}
