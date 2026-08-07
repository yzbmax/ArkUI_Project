/**
 * 搜索页（C204）—— 关键词搜索、历史 20 条、热门 Top10、输入联想（防抖 300ms）。
 */
import { ROUTES } from '../shared/constants/Routes';
import { AppStore } from '../shared/store/AppStore';
import { ApiRepo } from '../shared/api/ApiRepo';
import { Post } from '../shared/mock/Models';
import { PostCard } from '../common/components/PostCard';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';

const HOT: string[] = ['校园卡', '耳机', '钥匙', '雨伞', '水杯', '手机', '书包', '身份证', '眼镜', '钱包'];

@Entry
@Component
struct SearchPage {
  @State kw: string = '';
  @State suggest: string[] = [];
  @State result: Post[] = [];
  @State searched: boolean = false;
  @State history: string[] = AppStore.searchHistory;

  build() {
    Column() {
      Row({ space: 12 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK })
          .onClick(() => this.getUIContext().getRouter().back())
        Row({ space: 8 }) {
          Icon({ name: 'zoom', iconSize: 18, tint: TINT.TEXT_STONE })
          TextInput({ placeholder: '搜索失物 / 寻物', text: this.kw })
            .onChange((v) => this.onInput(v))
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
            .onSubmit(() => this.doSearch(this.kw))
          Text('搜索').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
            .onClick(() => this.doSearch(this.kw))
        }
        .layoutWeight(1).height(44).padding({ left: 16, right: 16 })
        .alignItems(VerticalAlign.Center)
        .backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
      }
      .width('100%').padding({ left: 16, right: 16 })
      .margin({ top: 40, bottom: 12 })

      Scroll() {
        Column({ space: 16 }) {
          if (this.suggest.length > 0 && !this.searched) {
            ForEach(this.suggest, (s: string) => {
              Row({ space: 8 }) {
                Icon({ name: 'trending_up', iconSize: 16, tint: TINT.TEXT_STONE })
                Text(s).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_charcoal'))
              }
              .width('100%').padding(8)
              .alignItems(VerticalAlign.Center)
              .onClick(() => { this.kw = s; this.doSearch(s); })
            })
          }

          if (!this.searched) {
            if (this.history.length > 0) {
              Row({ space: 8 }) {
                Text('搜索历史').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_olive'))
                Text('清空').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
                  .onClick(() => { AppStore.clearSearchHistory(); this.history = []; Toast.show('已清空'); })
              }
              .width('100%').justifyContent(FlexAlign.SpaceBetween)
            }
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(this.history, (h: string) => {
                Text(h).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_charcoal'))
                  .backgroundColor($r('app.color.bg_sand')).padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius($r('app.float.radius_rounded'))
                  .margin({ right: 8, bottom: 8 })
                  .onClick(() => { this.kw = h; this.doSearch(h); })
              })
            }

            Text('热门搜索').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_olive'))
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(HOT, (h: string) => {
                Row({ space: 4 }) {
                  Icon({ name: 'flame', iconSize: 14, tint: TINT.STATUS_REWARD })
                  Text(h).fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_charcoal'))
                }
                .backgroundColor($r('app.color.bg_sand')).padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .alignItems(VerticalAlign.Center)
                .borderRadius($r('app.float.radius_rounded'))
                .margin({ right: 8, bottom: 8 })
                .onClick(() => { this.kw = h; this.doSearch(h); })
              })
            }
          } else {
            if (this.result.length > 0) {
              ForEach(this.result, (p: Post) => {
                PostCard({ post: p, onTap: (id) => this.getUIContext().getRouter().pushUrl({ url: ROUTES.lostDetail, params: { id } }) })
                  .margin({ left: 16, right: 16 })
              }, (p: Post) => p.id)
            } else {
              Text('未找到相关结果，试试"图书馆 耳机"双词').fontSize($r('app.float.font_body_small'))
                .fontColor($r('app.color.text_stone')).width('100%').textAlign(TextAlign.Center).padding(40)
            }
          }
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }

  private onInput(v: string): void {
    this.kw = v;
    this.searched = false;
    if (!v.trim()) {
      this.suggest = [];
      return;
    }
    setTimeout(() => {
      this.suggest = HOT.filter((h) => h.includes(v));
      this.history = AppStore.searchHistory;
    }, 300);
  }

  private async doSearch(kw: string): Promise<void> {
    if (!kw.trim()) {
      Toast.show('请输入关键词');
      return;
    }
    AppStore.addSearchHistory(kw);
    this.history = AppStore.searchHistory;
    try {
      const r = await ApiRepo.getPosts({ keyword: kw });
      this.result = r.list;
    } catch (e) {
      Toast.show((e as Error).message);
    }
    this.searched = true;
    this.suggest = [];
  }
}
