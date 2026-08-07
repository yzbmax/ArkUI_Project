/**
 * 启动页（F01）
 * 5 秒倒计时自动进入首页；右上角胶囊「跳过」可立即进入；进入后不可返回。
 */
import { router } from '@kit.ArkUI';
import { Colors, Font, Radius } from '../theme/AppTheme';
import { tintMatrix } from '../components/common';

@Entry
@Component
struct Start {
  @State seconds: number = 15;        // 剩余倒计时
  private timer: number = -1;        // setInterval 句柄
  private readonly total: number = 5;

  // 启动倒计时
  aboutToAppear(): void {
    this.timer = setInterval(() => {
      this.seconds = this.seconds - 1;
      if (this.seconds <= 0) {
        this.enterHome();
      }
    }, 1000) as number;
  }

  // 进入首页（replaceUrl：不可返回启动页）
  private enterHome(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
    router.replaceUrl({ url: 'pages/Index' });
  }

  // 页面销毁时释放定时器，防止泄漏
  aboutToDisappear(): void {
    if (this.timer !== -1) {
      clearInterval(this.timer);
      this.timer = -1;
    }
  }

  build() {
    Column() {
      // 右上角「跳过」胶囊
      Row() {
        Row() {
          // 跳过图标：接入 x 图标
          Image($r('app.media.x')) // 注意：不需要写 .svg 后缀
            .width(24)
            .height(24)
            .colorFilter(tintMatrix(Colors.textPrimary))
          Text('跳过 ' + this.seconds + 's')
            .fontSize(Font.caption)
            .fontColor(Colors.textPrimary)
            .margin({ left: 6})
        }
        .padding({ left: 12, right: 12, top: 6, bottom: 6 })
        .backgroundColor(Colors.surfaceMid)
        .borderRadius(Radius.pill)

        .onClick(() => {
          this.enterHome();
        })
      }
      .margin({top : 20})
      .width('100%')
      .justifyContent(FlexAlign.End)
      .padding({ top: 16, right: 16 })

      // 居中 Logo（接入真实 logo 图片）
      Column() {
        Image($r('app.media.logo'))
          .width(96)
          .height(96)
          .objectFit(ImageFit.Contain)
          .colorFilter(tintMatrix('#1DB954'))
      }
      .layoutWeight(1)
      .width('100%')
      .justifyContent(FlexAlign.Center)

      // 标题
      Text('黑马云音乐')
        .fontSize(Font.title)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.textPrimary)
      Text('HARMONY MUSIC')
        .fontSize(Font.small)
        .fontColor(Colors.textSecondary)
        .margin({ top: 8, bottom: 48 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bg)
  }
}
