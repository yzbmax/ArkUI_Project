/**
 * 登录页（C101）—— 手机号+密码/验证码、自动登录、冻结提示。
 * 前端 Mock：任意非空即登录成功；手机号 13800000000 模拟冻结账号。
 */
import { ROUTES } from '../shared/constants/Routes';
import { AppStore } from '../shared/store/AppStore';
import { ApiRepo } from '../shared/api/ApiRepo';
import { AppButton, BtnVariant } from '../common/components/UI';
import { TINT } from '../common/components/tint';
import { Icon } from '../common/components/Icon';
import { Toast } from '../common/utils/Toast';

@Entry
@Component
struct Login {
  @State phone: string = '';
  @State pwd: string = '';
  @State code: string = '';
  @State mode: 'pwd' | 'code' = 'pwd';
  @State autoLogin: boolean = true;
  @State showPwd: boolean = false;
  @State loading: boolean = false;
  @State remain: number = 5;

  build() {
    Column({ space: 16 }) {
      Text('登录')
        .fontSize($r('app.float.font_h1'))
        .fontFamily('Noto Serif SC')
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_near_black'))
        .alignSelf(ItemAlign.Start)
        .margin({ top: 40, bottom: 16 })

      // 手机号
      TextInput({ placeholder: '手机号', text: this.phone })
        .onChange((v) => this.phone = v)
        .type(InputType.PhoneNumber)
        .height(48)
        .backgroundColor($r('app.color.bg_ivory'))
        .borderRadius($r('app.float.radius_generous'))

      // 密码 / 验证码
      if (this.mode === 'pwd') {
      Row() {
        TextInput({ placeholder: '密码', text: this.pwd })
          .onChange((v) => this.pwd = v)
          .type(this.showPwd ? InputType.Normal : InputType.Password)
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)

      }
      .height(48)
      .padding({ left: 0, right: 16 })
      .backgroundColor($r('app.color.bg_ivory'))
      .borderRadius($r('app.float.radius_generous'))
      .alignItems(VerticalAlign.Center)
      } else {
        Row() {
          TextInput({ placeholder: '验证码', text: this.code })
            .onChange((v) => this.code = v)
            .type(InputType.Number)
            .layoutWeight(1)
            .backgroundColor(Color.Transparent)
          Text('获取验证码').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
            .onClick(() => Toast.show('验证码已发送（Mock）'))
        }
        .height(48)
        .padding({ left: 0, right: 16 })
        .backgroundColor($r('app.color.bg_ivory'))
        .borderRadius($r('app.float.radius_generous'))
      }

      // 自动登录 + 切换方式
      Row() {
        Row({ space: 6 }) {
          Icon({ name: 'bookmark', iconSize: 18, tint: this.autoLogin ? TINT.BRAND_TERRACOTTA : TINT.TEXT_STONE })
            .onClick(() => this.autoLogin = !this.autoLogin)
          Text('自动登录').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_olive'))
        }
        .alignItems(VerticalAlign.Center)
        Text(this.mode === 'pwd' ? '验证码登录' : '密码登录')
          .fontSize($r('app.float.font_body_small'))
          .fontColor($r('app.color.brand_terracotta'))
          .onClick(() => this.mode = this.mode === 'pwd' ? 'code' : 'pwd')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)

      AppButton({
        text: '登录', full: true, loading: this.loading, onTap: () => this.doLogin()
      })

      Row({ space: 24 }) {
        Text('注册账号').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
          .onClick(() => this.getUIContext().getRouter().pushUrl({ url: ROUTES.register }))
        Text('找回密码').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
          .onClick(() => this.getUIContext().getRouter().pushUrl({ url: ROUTES.forgot }))
      }
      .margin({ top: 4 })
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .backgroundColor($r('app.color.bg_parchment'))
    .alignItems(HorizontalAlign.Start)
  }

  private async doLogin(): Promise<void> {
    if (!this.phone || (this.mode === 'pwd' ? !this.pwd : !this.code)) {
      Toast.show('请输入登录信息');
      return;
    }
    this.loading = true;
    try {
      const result = await ApiRepo.login(this.phone, this.pwd);
      AppStore.login(result.user, result.token);
      this.getUIContext().getRouter().replaceUrl({ url: ROUTES.home });
    } catch (e) {
      Toast.show((e as Error).message);
    } finally {
      this.loading = false;
    }
  }
}
