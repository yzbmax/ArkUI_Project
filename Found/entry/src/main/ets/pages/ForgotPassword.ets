/**
 * 找回密码（C103）—— 手机验证码重置密码。
 * 验证码为演示模拟（固定 123456）；重置走真实接口 ApiRepo.forgotPassword。
 */
import { AppButton } from '../common/components/UI';
import { Toast } from '../common/utils/Toast';
import { ApiRepo } from '../shared/api/ApiRepo';

const MOCK_CODE: string = '123456';

@Entry
@Component
struct ForgotPassword {
  @State phone: string = '';
  @State code: string = '';
  @State pwd: string = '';
  @State pwd2: string = '';
  @State codeSent: boolean = false;
  @State submitting: boolean = false;

  private sendCode(): void {
    if (!/^1\d{10}$/.test(this.phone)) {
      Toast.show('请输入正确的手机号');
      return;
    }
    this.codeSent = true;
    Toast.show('验证码已发送（演示验证码 123456）');
  }

  build() {
    Column({ space: 16 }) {
      Text('找回密码')
        .fontSize($r('app.float.font_h1'))
        .fontFamily('Noto Serif SC')
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 40, bottom: 8 })
      TextInput({ placeholder: '手机号', text: this.phone })
        .onChange((v) => this.phone = v).type(InputType.PhoneNumber)
        .height(48).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
      Row() {
        TextInput({ placeholder: '验证码', text: this.code }).onChange((v) => this.code = v)
          .layoutWeight(1).backgroundColor(Color.Transparent)
        Text('获取验证码').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
          .onClick(() => this.sendCode())
      }.height(48).padding({ left: 16, right: 16 }).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
      TextInput({ placeholder: '新密码（8~20 位字母+数字）', text: this.pwd }).onChange((v) => this.pwd = v)
        .type(InputType.Password).height(48).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
      TextInput({ placeholder: '确认新密码', text: this.pwd2 }).onChange((v) => this.pwd2 = v)
        .type(InputType.Password).height(48).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
      AppButton({ text: '重置密码', full: true, loading: this.submitting, onTap: () => this.submit() })
    }
    .width('100%').height('100%').padding(24).backgroundColor($r('app.color.bg_parchment')).alignItems(HorizontalAlign.Start)
  }

  private async submit(): Promise<void> {
    if (!/^1\d{10}$/.test(this.phone)) {
      Toast.show('请输入正确的手机号');
      return;
    }
    if (!this.codeSent) {
      Toast.show('请先获取验证码');
      return;
    }
    if (this.code !== MOCK_CODE) {
      Toast.show('验证码错误');
      return;
    }
    if (!/^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,20}$/.test(this.pwd)) {
      Toast.show('密码需 8~20 位字母+数字');
      return;
    }
    if (this.pwd !== this.pwd2) {
      Toast.show('两次密码不一致');
      return;
    }
    this.submitting = true;
    try {
      await ApiRepo.forgotPassword(this.phone, this.pwd);
      Toast.show('密码重置成功，请用新密码登录');
      this.getUIContext().getRouter().back();
    } catch (e) {
      Toast.show((e as Error).message);
    } finally {
      this.submitting = false;
    }
  }
}
