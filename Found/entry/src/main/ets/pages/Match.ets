/**
 * 智能匹配入口（C404）—— 按高中低匹配度展示我发布的寻物对应的失物。
 */
import { ROUTES } from '../shared/constants/Routes';
import { MockRepo } from '../shared/mock/MockRepo';
import { Post } from '../shared/mock/Models';
import { PostCard } from '../common/components/PostCard';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';

type Level = 'high' | 'mid' | 'low';

/** ArkTS 要求对象字面量对应显式声明的类/接口。 */
export interface MatchItem {
  level: Level;
  post: Post;
}

interface LevelStyle {
  t: string;
  c: Resource;
}

const LEVEL_STYLE: Map<string, LevelStyle> = new Map<string, LevelStyle>([
  ['high', { t: '高匹配', c: $r('app.color.status_resolved') }],
  ['mid', { t: '中匹配', c: $r('app.color.status_pending') }],
  ['low', { t: '低匹配', c: $r('app.color.text_stone') }],
  ['default', { t: '低匹配', c: $r('app.color.text_stone') }]
]);

@Entry
@Component
struct Match {
  @State matches: MatchItem[] = [
    { level: 'high', post: MockRepo.posts[0] },
    { level: 'high', post: MockRepo.posts[2] },
    { level: 'mid', post: MockRepo.posts[4] },
    { level: 'mid', post: MockRepo.posts[6] },
    { level: 'low', post: MockRepo.posts[8] }
  ];

  @Builder
  LevelTag(level: Level) {
    Text((LEVEL_STYLE.get(level) ?? LEVEL_STYLE.get('default')!).t)
      .fontSize($r('app.float.font_label'))
      .fontColor((LEVEL_STYLE.get(level) ?? LEVEL_STYLE.get('default')!).c)
      .backgroundColor((LEVEL_STYLE.get(level) ?? LEVEL_STYLE.get('default')!).c).opacity(0.14)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 }).borderRadius(4)
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('智能匹配').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 12 }) {
          ForEach(this.matches, (m: MatchItem) => {
            Column({ space: 8 }) {
              Row() {
                Icon({ name: 'sparkles_2', iconSize: 18, tint: TINT.BRAND_TERRACOTTA })
                this.LevelTag(m.level)
              }
              .alignItems(VerticalAlign.Center)
              PostCard({
                post: m.post,
                onTap: (id) => this.getUIContext().getRouter().pushUrl({ url: ROUTES.lostDetail, params: { id } }),
                onClaim: (id) => this.getUIContext().getRouter().pushUrl({ url: ROUTES.lostDetail, params: { id } })
              })
            }.alignItems(HorizontalAlign.Start)
          }, (m: MatchItem) => m.post.id)
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
