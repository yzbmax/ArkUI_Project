/**
 * 分类检索页（C203）—— 8 大一级分类 + 二级级联。前端 Mock。
 */
import { ROUTES } from '../shared/constants/Routes';
import { CATEGORIES, CategoryItem } from '../shared/constants/Constants';
import { ApiRepo } from '../shared/api/ApiRepo';
import { Post } from '../shared/mock/Models';
import { PostCard } from '../common/components/PostCard';
import { EmptyState } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';

@Entry
@Component
struct Category {
  @State selCat: number = 0;
  @State selSub: string = '';
  @State result: Post[] = [];

  aboutToAppear(): void {
    this.query();
  }

  private async query(): Promise<void> {
    try {
      const r = await ApiRepo.getPosts({ category: CATEGORIES[this.selCat].key }, 1, 3);
      this.result = r.list;
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  build() {
    Column() {
      Text('分类检索')
        .fontSize($r('app.float.font_h1')).fontFamily('Noto Serif SC').fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start).margin({ top: 40, left: 16, bottom: 8 })

      // 一级分类
      Scroll() {
        Column({ space: 12 }) {
          ForEach(CATEGORIES, (c: CategoryItem, i: number) => {
            Row({ space: 12 }) {
              Icon({ name: c.icon, iconSize: 24, tint: TINT.BRAND_TERRACOTTA })
              Text(c.name).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
            }
            .width('100%').padding(16)
            .alignItems(VerticalAlign.Center)
            .backgroundColor(this.selCat === i ? $r('app.color.bg_sand') : $r('app.color.bg_ivory'))
            .borderRadius($r('app.float.radius_generous'))
            .border({ width: 1, color: this.selCat === i ? $r('app.color.brand_terracotta') : $r('app.color.border_cream') })
            .onClick(() => { this.selCat = i; this.selSub = ''; this.query(); })
          })
        }
        .padding(16)
      }
      .layoutWeight(1)
      .align(Alignment.TopStart)

      // 二级级联 + 结果
      Column({ space: 8 }) {
        // 二级分类 chips（横向滚动，防溢出）
        Scroll() {
          Row({ space: 8 }) {
            ForEach(CATEGORIES[this.selCat].sub, (s: string) => {
              Text(s)
                .fontSize($r('app.float.font_body_small'))
                .fontColor(this.selSub === s ? $r('app.color.text_on_brand') : $r('app.color.text_charcoal'))
                .backgroundColor(this.selSub === s ? $r('app.color.brand_terracotta') : $r('app.color.bg_sand'))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .borderRadius($r('app.float.radius_rounded'))
                .onClick(() => { this.selSub = s; })
            })
          }
          .padding({ left: 16, right: 16 })
        }
        .scrollable(ScrollDirection.Horizontal)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
        .flexShrink(0)

        // 结果卡片（纵向滚动，防裁剪）
        Scroll() {
          Column({ space: 8 }) {
            if (this.result.length > 0) {
              ForEach(this.result.slice(0, 3), (p: Post) => {
                PostCard({ post: p, onTap: (id) => this.getUIContext().getRouter().pushUrl({ url: ROUTES.lostDetail, params: { id } }) })
                  .margin({ left: 16, right: 16 })
              }, (p: Post) => p.id)
            } else {
              EmptyState({ title: '该分类暂无动态', desc: '' })
            }
          }
          .padding({ left: 0, right: 0 })
        }
        .layoutWeight(1)
        .scrollable(ScrollDirection.Vertical)
        .edgeEffect(EdgeEffect.Spring)
        .width('100%')
      }
      .layoutWeight(1)
      .backgroundColor($r('app.color.bg_parchment'))
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
