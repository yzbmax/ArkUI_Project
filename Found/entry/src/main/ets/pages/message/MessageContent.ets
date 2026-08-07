/**
 * 消息中心（C501 框架 + C502 通知列表）—— 四类 Tab、未读角标。
 * 系统/匹配/互动 通知来自后端派生接口（ApiRepo.fetchNotifications）；
 * 私信 Tab 走会话接口（ApiRepo.fetchChats）。切换 Tab 时标记该类型已读。
 */
import { ApiRepo } from '../../shared/api/ApiRepo';
import { MessageItem, ChatSession } from '../../shared/mock/Models';
import { EmptyState, AvatarPlaceholder } from '../../common/components/UI';
import { Icon } from '../../common/components/Icon';
import { hexToTint, TINT } from '../../common/components/tint';
import { Toast } from '../../common/utils/Toast';

type MsgTab = 'system' | 'match' | 'interact' | 'chat';

@Component
export struct MessageContent {
  @State tab: MsgTab = 'system';
  @State sessions: ChatSession[] = [];
  @State system: MessageItem[] = [];
  @State match: MessageItem[] = [];
  @State interact: MessageItem[] = [];
  onOpen: (peerId: string, name: string) => void = () => {};

  aboutToAppear(): void {
    this.loadChats();
    this.loadNotifs();
  }

  private async loadChats(): Promise<void> {
    try {
      this.sessions = await ApiRepo.fetchChats();
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  /** 拉取三类通知，覆盖本地列表 */
  private async loadNotifs(): Promise<void> {
    try {
      const n = await ApiRepo.fetchNotifications();
      this.system = n.system;
      this.match = n.match;
      this.interact = n.interact;
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  /** 私信 Tab 未读数 */
  private chatUnread(): number {
    let n = 0;
    this.sessions.forEach((s: ChatSession) => n += s.unread);
    return n;
  }

  /** 当前 Tab 的通知列表 */
  private notifList(): MessageItem[] {
    if (this.tab === 'system') return this.system;
    if (this.tab === 'match') return this.match;
    if (this.tab === 'interact') return this.interact;
    return [];
  }

  /** 某通知类 Tab 未读条数 */
  private notifUnread(key: MsgTab): number {
    const arr: MessageItem[] = key === 'system' ? this.system : (key === 'match' ? this.match : this.interact);
    let n = 0;
    arr.forEach((m: MessageItem) => { if (m.unread) n++; });
    return n;
  }

  private notifEmptyTitle(key: MsgTab): string {
    if (key === 'system') return '暂无系统通知';
    if (key === 'match') return '暂无匹配提醒';
    return '暂无互动消息';
  }

  /** 切换 Tab：通知类先标记已读再本地清除未读 */
  private async switchTab(key: MsgTab): Promise<void> {
    this.tab = key;
    if (key === 'system' || key === 'match' || key === 'interact') {
      try {
        await ApiRepo.markNotifRead(key);
        const arr: MessageItem[] = key === 'system' ? this.system : (key === 'match' ? this.match : this.interact);
        const cleared: MessageItem[] = arr.map((m: MessageItem): MessageItem => {
          if (m.unread) {
            const c = new MessageItem();
            c.id = m.id;
            c.type = m.type;
            c.title = m.title;
            c.content = m.content;
            c.time = m.time;
            c.unread = false;
            return c;
          }
          return m;
        });
        if (key === 'system') { this.system = cleared; }
        if (key === 'match') { this.match = cleared; }
        if (key === 'interact') { this.interact = cleared; }
      } catch (e) {
        // 标记已读失败不影响切换
      }
    }
  }

  private msgIcon(type: string): string {
    if (type === 'system') return 'bell';
    if (type === 'match') return 'sparkles_2';
    if (type === 'interact') return 'chat_bubble';
    return 'send';
  }

  @Builder
  TabBar(label: string, key: MsgTab, icon: string, unread: number) {
    Column({ space: 2 }) {
      Row({ space: 4 }) {
        Icon({ name: icon, iconSize: 20, tint: this.tab === key ? TINT.BRAND_TERRACOTTA : TINT.TEXT_STONE })
        if (unread > 0) {
          Text(unread > 99 ? '99+' : unread.toString())
            .fontSize(9).fontColor($r('app.color.text_on_brand')).backgroundColor($r('app.color.status_urgent'))
            .width(16).height(16).borderRadius(8).textAlign(TextAlign.Center)
        }
      }
      .alignItems(VerticalAlign.Center)
      Text(label).fontSize($r('app.float.font_label'))
        .fontColor(this.tab === key ? $r('app.color.brand_terracotta') : $r('app.color.text_stone'))
    }
    .alignItems(HorizontalAlign.Center)
    .onClick(() => { this.switchTab(key); })
  }

  build() {
    Column() {
      Text('消息')
        .fontSize($r('app.float.font_h1')).fontFamily('Noto Serif SC').fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start).margin({ top: 40, left: 16, bottom: 8 })

      Row({ space: 8 }) {
        this.TabBar('系统', 'system', 'bell', this.notifUnread('system'))
        this.TabBar('匹配', 'match', 'sparkles_2', this.notifUnread('match'))
        this.TabBar('互动', 'interact', 'chat_bubble', this.notifUnread('interact'))
        this.TabBar('私信', 'chat', 'send', this.chatUnread())
      }
      .width('100%').padding({ left: 16, right: 16, bottom: 8 })
      .justifyContent(FlexAlign.SpaceBetween)

      Scroll() {
        Column({ space: 8 }) {
          if (this.tab === 'chat') {
            if (this.sessions.length === 0) {
              EmptyState({ icon: 'send', title: '暂无会话', desc: '私信会显示在这里' })
            } else {
              ForEach(this.sessions, (s: ChatSession) => {
                Row({ space: 12 }) {
                  AvatarPlaceholder({ iconSize: 40 })
                  Column({ space: 4 }) {
                    Text(s.name).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
                    Text(s.lastMsg).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone')).maxLines(1).textOverflow({ overflow: TextOverflow.Ellipsis })
                  }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                  Column({ space: 4 }) {
                    Text(s.time).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
                    if (s.unread > 0) {
                      Row().width(8).height(8).backgroundColor($r('app.color.status_urgent')).borderRadius(4).alignSelf(ItemAlign.End)
                    }
                  }.alignItems(HorizontalAlign.End)
                }
                .width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
                .alignItems(VerticalAlign.Top)
                .onClick(() => this.onOpen(s.peerId, s.name))
              }, (s: ChatSession) => s.id)
            }
          } else if (this.notifList().length > 0) {
            ForEach(this.notifList(), (m: MessageItem) => {
              Row({ space: 12 }) {
                Icon({ name: this.msgIcon(m.type), iconSize: 36, tint: TINT.BRAND_TERRACOTTA })
                Column({ space: 4 }) {
                  Text(m.title).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
                  Text(m.content).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone')).maxLines(2).textOverflow({ overflow: TextOverflow.Ellipsis })
                }.layoutWeight(1).alignItems(HorizontalAlign.Start)
                Column({ space: 4 }) {
                  Text(m.time).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
                  if (m.unread) {
                    Row().width(8).height(8).backgroundColor($r('app.color.status_urgent')).borderRadius(4).alignSelf(ItemAlign.End)
                  }
                }.alignItems(HorizontalAlign.End)
              }
              .width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
              .alignItems(VerticalAlign.Top)
            }, (m: MessageItem) => m.id)
          } else {
            EmptyState({ icon: 'bell', title: this.notifEmptyTitle(this.tab), desc: '' })
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
