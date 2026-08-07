/**
 * 私信对话（C503）—— 会话切换 + 消息气泡（本人 Terracotta/对方白底）+ 已读回执。
 * 已对接后端：会话/消息来自 /api/chats，发送走 POST /api/chats/:peerId。
 */
import { ApiRepo } from '../shared/api/ApiRepo';
import { ChatSession, ChatMessage } from '../shared/mock/Models';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';

/** 路由参数：从消息页点入时携带。ArkTS 不支持 Record 作为断言目标类型。 */
interface RouteParams {
  peerId?: string;
  name?: string;
}

@Entry
@Component
struct Chat {
  @State sessions: ChatSession[] = [];
  @State activeId: string = '';
  @State input: string = '';
  @State loading: boolean = false;
  private targetPeerId: string = '';

  aboutToAppear(): void {
    const params = this.getUIContext().getRouter().getParams() as RouteParams;
    this.targetPeerId = params?.peerId ?? '';
    this.load();
  }

  /** 从对话返回 / 切回本页时刷新，接收对方新消息 */
  onPageShow(): void {
    this.load();
  }

  private current(): ChatSession | null {
    if (this.sessions.length === 0) {
      return null;
    }
    const hit = this.sessions.find((s: ChatSession) => s.id === this.activeId);
    return hit || this.sessions[0];
  }

  private async load(): Promise<void> {
    this.loading = true;
    try {
      const list = await ApiRepo.fetchChats();
      this.sessions = list;
      // 默认选中：优先路由带入的 peer，其次第一会话
      if (this.activeId === '') {
        if (this.targetPeerId) {
          const hit = list.find((s: ChatSession) => s.peerId === this.targetPeerId);
          this.activeId = (hit ?? list[0])?.id ?? '';
        } else if (list.length > 0) {
          this.activeId = list[0].id;
        }
      } else if (this.sessions.find((s: ChatSession) => s.id === this.activeId) === undefined && list.length > 0) {
        this.activeId = list[0].id;
      }
    } catch (e) {
      Toast.show((e as Error).message);
    } finally {
      this.loading = false;
    }
  }

  private async doSend(): Promise<void> {
    const cur = this.current();
    if (!cur || !cur.peerId) {
      Toast.show('请先选择一个会话');
      return;
    }
    const text = this.input.trim();
    if (!text) {
      Toast.show('请输入消息');
      return;
    }
    // 乐观更新：立即把消息插入当前会话（新数组 + 新对象，保证 ForEach 立即重渲染）
    const updated: ChatSession[] = [];
    this.sessions.forEach((s: ChatSession) => {
      if (s.id === cur.id) {
        const copy = new ChatSession();
        copy.id = s.id;
        copy.peerId = s.peerId;
        copy.name = s.name;
        copy.avatar = s.avatar;
        copy.lastMsg = text;
        copy.time = '刚刚';
        copy.unread = s.unread;
        copy.messages = s.messages.concat([{ me: true, content: text, time: '刚刚' } as ChatMessage]);
        updated.push(copy);
      } else {
        updated.push(s);
      }
    });
    this.sessions = updated;
    this.input = '';
    // 发送到后端，成功后以服务端数据为准刷新（含对方新消息 / lastMsg）
    try {
      await ApiRepo.sendChat(cur.peerId, text);
    } catch (e) {
      Toast.show((e as Error).message);
    }
    this.load();
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text(this.current()?.name ?? '私信').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      // 会话切换
      Scroll() {
        Row({ space: 8 }) {
          ForEach(this.sessions, (s: ChatSession) => {
            Text(s.name).fontSize($r('app.float.font_body_small'))
              .fontColor(this.activeId === s.id ? $r('app.color.text_on_brand') : $r('app.color.text_charcoal'))
              .backgroundColor(this.activeId === s.id ? $r('app.color.brand_terracotta') : $r('app.color.bg_sand'))
              .padding({ left: 12, right: 12, top: 6, bottom: 6 }).borderRadius($r('app.float.radius_rounded'))
              .onClick(() => { this.activeId = s.id; })
          })
        }.padding({ left: 16, right: 16, bottom: 8 })
      }.scrollable(ScrollDirection.Horizontal)

      // 消息气泡
      Refresh({ refreshing: $$this.loading }) {
        Scroll() {
          Column({ space: 8 }) {
            if (this.sessions.length === 0) {
              Text('暂无会话，去动态里和同学私信吧')
                .fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone')).padding(32)
            } else {
              ForEach(this.current()?.messages ?? [], (m: ChatMessage) => {
                Row() {
                  if (m.me) {
                    Row().layoutWeight(1)
                    Column({ space: 2 }) {
                      Text(m.content).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_on_brand'))
                        .backgroundColor($r('app.color.brand_terracotta'))
                        .padding(12).borderRadius($r('app.float.radius_feature')).constraintSize({ maxWidth: '70%' })
                      Text('已读').fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone')).alignSelf(ItemAlign.End)
                    }.alignItems(HorizontalAlign.End)
                  } else {
                    Column({ space: 2 }) {
                      Text(m.content).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
                        .backgroundColor($r('app.color.bg_ivory'))
                        .padding(12).borderRadius($r('app.float.radius_feature')).constraintSize({ maxWidth: '70%' })
                      Text(m.time).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
                    }.alignItems(HorizontalAlign.Start)
                    Row().layoutWeight(1)
                  }
                }.width('100%')
              }, (m: ChatMessage, idx: number) => idx.toString())
            }
          }.padding(16)
        }
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
      }
      .layoutWeight(1)
      .onRefreshing(() => this.load())
      .backgroundColor($r('app.color.bg_parchment'))

      // 输入栏
      Row({ space: 8 }) {
        TextInput({ placeholder: '输入消息', text: this.input }).onChange((v) => this.input = v)
          .layoutWeight(1).height(40).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
        Icon({ name: 'send', iconSize: 28, tint: this.current() ? TINT.BRAND_TERRACOTTA : TINT.TEXT_STONE })
          .onClick(() => { this.doSend(); })
      }
      .width('100%').padding(16).backgroundColor($r('app.color.bg_ivory')).border({ width: { top: 1 }, color: $r('app.color.border_cream') })
      .alignItems(VerticalAlign.Center)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
