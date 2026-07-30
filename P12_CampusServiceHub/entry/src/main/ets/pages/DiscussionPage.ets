/**
 * DiscussionPage —— 讨论列表 + 点赞 + 草稿发布（P01 / P03 / P06 / P10）
 * ForEach 渲染 posts: Post[]；每条含点赞按钮（@State liked + 点赞数增减，P03）。
 * 底部输入框绑定 @State draft，发布 → 构造 Post 并 unshift 到 posts（P10），新帖置顶。
 */
import { Colors, Font, Space, Radius } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { GlassNavBar } from '../components/GlassNavBar';
import { posts as mockPosts } from '../mock/MockData';
import { Post } from '../model/Models';
import { router, promptAction } from '@kit.ArkUI';

@Entry
@Component
struct DiscussionPage {
  @State posts: Post[] = mockPosts;
  @State draft: string = '';

  // 点赞状态事件（P03）：liked 翻转 + 点赞数增减
  private toggleLike(index: number): void {
    const p = this.posts[index];
    const updated: Post = {
      id: p.id,
      author: p.author,
      avatar: p.avatar,
      content: p.content,
      time: p.time,
      liked: !p.liked,
      likes: p.liked ? p.likes - 1 : p.likes + 1
    };
    this.posts[index] = updated;
    this.posts = [...this.posts]; // 整体替换触发响应式刷新
  }

  // 发布流程（P10）：构造 Post 并 unshift，清空草稿
  private publish(): void {
    const content = this.draft.trim();
    if (!content) {
      try {
        promptAction.showToast({ message: '说点什么再发布吧～' });
      } catch (e) {
        // 忽略提示失败
      }
      return;
    }
    const newPost: Post = {
      id: 'p_' + Date.now().toString(),
      author: '我',
      content: content,
      likes: 0,
      liked: false,
      time: '刚刚'
    };
    this.posts.unshift(newPost);
    this.draft = '';
  }

  build() {
    Column() {
      GlassNavBar({ title: '讨论', showBack: true, onBack: () => { try { router.back(); } catch (e) {} } });

      Scroll() {
        Column({ space: Space.md }) {
          ForEach(this.posts, (p: Post, index: number) => {
            AppCard({ dark: false, withShadow: true, pad: Space.md }) {
              Column({ space: Space.sm }) {
                Row() {
                  Text(p.author)
                    .fontSize(Font.bodyEmphasis.size)
                    .fontWeight(Font.bodyEmphasis.weight)
                    .fontColor(Colors.textDark);
                  Blank();
                  Text(p.time)
                    .fontSize(Font.caption.size)
                    .fontColor(Colors.textTertiary);
                }
                .width('100%');

                Text(p.content)
                  .fontSize(Font.body.size)
                  .fontColor(Colors.textDark);

                Row() {
                  Button() {
                    Row({ space: Space.xs }) {
                      Text(p.liked ? '👍' : '🤍')
                        .fontSize(Font.caption.size);
                      Text(`${p.likes}`)
                        .fontSize(Font.caption.size);
                    }
                  }
                  .backgroundColor(p.liked ? Colors.blue : Colors.bgLight)
                  .fontColor(p.liked ? Colors.white : Colors.textSecondary)
                  .borderRadius(Radius.cardSmall)
                  .padding({ left: Space.sm, right: Space.sm })
                  .onClick(() => {
                    this.toggleLike(index);
                  });

                  Blank();
                }
                .width('100%');
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start);
            }
          }, (p: Post) => p.id);
        }
        .width('100%')
        .padding({ left: Space.lg, right: Space.lg, top: Space.lg, bottom: Space.xl });
      }
      .layoutWeight(1)
      .width('100%');

      // 底部草稿发布栏（P10）
      Row({ space: Space.sm }) {
        TextInput({ placeholder: '说点什么…', text: this.draft })
          .width('100%')
          .height(44)
          .backgroundColor(Colors.white)
          .borderRadius(Radius.cardSmall)
          .padding({ left: Space.md, right: Space.md })
          .fontSize(Font.body.size)
          .fontColor(Colors.textDark)
          .layoutWeight(1)
          .onChange((v: string) => {
            this.draft = v;
          });
        Button('发布', { type: ButtonType.Normal })
          .height(44)
          .borderRadius(Radius.cta)
          .backgroundColor(Colors.blue)
          .fontColor(Colors.white)
          .fontSize(Font.body.size)
          .onClick(() => {
            this.publish();
          });
      }
      .width('100%')
      .padding({ left: Space.lg, right: Space.lg, bottom: Space.xl, top: Space.sm });
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bgLight);
  }
}
