/**
 * LoginPage —— 登录页（P01 / P03 / P04）
 * 深色沉浸式标题 + 深色表单卡（无边框）+ 协议勾选 + Apple Blue 登录按钮。
 * 校验通过（P04）→ 写入 AppStorage 登录态（P03）→ router.replaceUrl 到 HomePage。
 */
import { Colors, Font, Space, Radius } from '../theme/AppTheme';
import { AppCard } from '../components/AppCard';
import { PrimaryButton } from '../components/PrimaryButton';
import { promptAction, router } from '@kit.ArkUI';

@Entry
@Component
struct LoginPage {
  @State studentId: string = '';
  @State password: string = '';
  @State agree: boolean = false;
  @State loading: boolean = false;

  // 表单校验（P04）：学号非空且为数字、密码 ≥6、协议已勾选
  private validate(): string | null {
    const id = this.studentId.trim();
    if (!id || !/^\d+$/.test(id)) {
      return '请输入有效的学号（仅限数字）';
    }
    if (this.password.length < 6) {
      return '密码长度至少为 6 位';
    }
    if (!this.agree) {
      return '请先阅读并同意《用户协议》';
    }
    return null;
  }

  private showError(msg: string): void {
    AlertDialog.show({ title: '提示', message: msg, confirm: { value: '我知道了', action: () => {} } });
  }

  // 登录状态事件（P03）
  private onLogin(): void {
    if (this.loading) {
      return;
    }
    const err = this.validate();
    if (err) {
      this.showError(err);
      return;
    }
    this.loading = true;
    // 模拟登录：写入登录态并跳转首页（纯前端，无网络请求）
    AppStorage.setOrCreate('isLogin', true);
    AppStorage.setOrCreate('studentId', this.studentId.trim());
    try {
      router.replaceUrl({ url: 'pages/HomePage' });
    } catch (e) {
      this.loading = false;
    }
  }

  build() {
    Scroll() {
      Column() {
        // 顶部标题区（深色沉浸式）
        Column() {
          Text('校园服务枢纽')
            .fontSize(Font.hero.size)
            .fontWeight(Font.hero.weight)
            .fontColor(Colors.white)
            .letterSpacing(Font.hero.letterSpacing)
            .margin({ bottom: Space.sm });
          Text('一站式校园生活，从登录开始')
            .fontSize(Font.subHeading.size)
            .fontColor(Colors.whiteTertiary);
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
        .padding({ left: Space.lg, right: Space.lg, top: Space.xxl, bottom: Space.xl });

        // 表单卡片（深色、无边框、柔和阴影）
        AppCard({ dark: true, withShadow: true, pad: Space.lg }) {
          Column({ space: Space.md }) {
            // 学号
            Column({ space: Space.xs }) {
              Text('学号')
                .fontSize(Font.caption.size)
                .fontColor(Colors.whiteSecondary);
              TextInput({ placeholder: '请输入学号', text: this.studentId })
                .width('100%')
                .height(48)
                .backgroundColor(Colors.black)
                .borderRadius(Radius.cardSmall)
                .padding({ left: Space.md, right: Space.md })
                .fontSize(Font.body.size)
                .fontColor(Colors.white)
                .placeholderColor(Colors.whiteTertiary)
                .onChange((v: string) => {
                  this.studentId = v;
                });
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 密码
            Column({ space: Space.xs }) {
              Text('密码')
                .fontSize(Font.caption.size)
                .fontColor(Colors.whiteSecondary);
              TextInput({ placeholder: '请输入密码', text: this.password })
                .width('100%')
                .height(48)
                .backgroundColor(Colors.black)
                .borderRadius(Radius.cardSmall)
                .padding({ left: Space.md, right: Space.md })
                .fontSize(Font.body.size)
                .fontColor(Colors.white)
                .placeholderColor(Colors.whiteTertiary)
                .type(InputType.Password)
                .onChange((v: string) => {
                  this.password = v;
                });
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')

            // 协议勾选行
            Row() {
              Checkbox({ name: 'agree', group: 'login' })
                .select(this.agree)
                .selectedColor(Colors.blue)
                .onChange((v: boolean) => {
                  this.agree = v;
                });
              Text('我已阅读并同意《用户协议》')
                .fontSize(Font.caption.size)
                .fontColor(Colors.brightBlue)
                .onClick(() => {
                  promptAction.showToast({ message: '《用户协议》即将上线' });
                });
            }
            .width('100%')
            .alignItems(VerticalAlign.Center)

            // 登录按钮（Apple Blue 主 CTA）
            PrimaryButton({ label: this.loading ? '登录中…' : '登录', onPress: () => this.onLogin() });
          }
          .width('100%')
        }

      }
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.black)
    .padding({ left: Space.lg, right: Space.lg, bottom: Space.xl });
  }
}
