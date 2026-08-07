/**
 * 启动页（C101 部分）—— 品牌启动 2s 跳转。
 */
import { ROUTES } from '../shared/constants/Routes';
import { AppStore } from '../shared/store/AppStore';

@Entry
@Component
struct Splash {
  private timer: number = 0;

  aboutToAppear(): void {
    this.timer = setTimeout(() => {
      this.redirect();
    }, 2000);
  }

  private async redirect(): Promise<void> {
    if (AppStore.isLogin()) {
      await AppStore.me();
    }
    try {
      this.getUIContext().getRouter().replaceUrl({ url: AppStore.isLogin() ? ROUTES.home : ROUTES.login });
    } catch (e) {
      // 跳转失败时忽略
    }
  }

  aboutToDisappear(): void {
    clearTimeout(this.timer);
  }

  build() {
    Column() {
      Image($r('app.media.img_1'))
        .width(96)
        .height(96)
        .borderRadius(24)
        .margin({ bottom: 16 })
      Text('校园失物招领')
        .fontSize($r('app.float.font_h1'))
        .fontFamily('Noto Serif SC')
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.brand_terracotta'))
      Text('让失物回家，让善意相连')
        .fontSize($r('app.float.font_body_small'))
        .fontColor($r('app.color.text_stone'))
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.bg_parchment'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}
