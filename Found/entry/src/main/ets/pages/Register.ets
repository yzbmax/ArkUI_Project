/**
 * 注册页（C102）—— 角色 → 认证字段 → 验证码。前端 Mock。
 */
import { ROUTES } from '../shared/constants/Routes';
import { AppStore } from '../shared/store/AppStore';
import { ApiRepo, RegisterBody } from '../shared/api/ApiRepo';
import { AppButton, BtnVariant } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';
import { ROLE_NAMES } from '../shared/constants/Constants';

type Role = 'student' | 'teacher' | 'staff';

@Entry
@Component
struct Register {
  @State step: number = 1;
  @State role: Role = 'student';
  @State sid: string = '';
  @State name: string = '';
  @State phone: string = '';
  @State pwd: string = '';
  @State code: string = '';
  @State agree: boolean = false;

  build() {
    Column({ space: 16 }) {
      Text('注册')
        .fontSize($r('app.float.font_h1'))
        .fontFamily('Noto Serif SC')
        .fontWeight(FontWeight.Bold)
        .alignSelf(ItemAlign.Start)
        .margin({ top: 40, bottom: 8 })

      if (this.step === 1) {
        Text('选择身份').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_olive'))
        ForEach(['student', 'teacher', 'staff'] as Role[], (r: Role) => {
          Row({ space: 12 }) {
            Text(ROLE_NAMES.get(r) ?? r).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
            if (this.role === r) {
              Icon({ name: 'bookmark', iconSize: 18, tint: TINT.BRAND_TERRACOTTA })
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor(this.role === r ? $r('app.color.bg_sand') : $r('app.color.bg_ivory'))
          .borderRadius($r('app.float.radius_generous'))
          .alignItems(VerticalAlign.Center)
          .onClick(() => this.role = r)
        })
        AppButton({ text: '下一步', full: true, onTap: () => this.step = 2 })
      } else if (this.step === 2) {
        TextInput({ placeholder: '学工号', text: this.sid })
          .onChange((v) => this.sid = v)
          .height(48).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
        TextInput({ placeholder: '姓名', text: this.name })
          .onChange((v) => this.name = v)
          .height(48).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
        TextInput({ placeholder: '手机号', text: this.phone })
          .onChange((v) => this.phone = v)
          .type(InputType.PhoneNumber)
          .height(48).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
        TextInput({ placeholder: '密码（6~20 位，含字母和数字）', text: this.pwd })
          .onChange((v) => this.pwd = v)
          .type(InputType.Password)
          .height(48).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
        Row() {
          TextInput({ placeholder: '验证码', text: this.code })
            .onChange((v) => this.code = v).layoutWeight(1).backgroundColor(Color.Transparent)
          Text('获取验证码').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
            .onClick(() => Toast.show('验证码已发送（Mock）'))
        }
        .height(48).padding({ left: 16, right: 16 }).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
        AppButton({ text: '下一步', full: true, onTap: () => this.step = 3 })
      } else {
        Row({ space: 6 }) {
          Icon({ name: 'bookmark', iconSize: 18, tint: this.agree ? TINT.BRAND_TERRACOTTA : TINT.TEXT_STONE })
            .onClick(() => this.agree = !this.agree)
          Text('我已阅读并同意《用户协议》与《隐私政策》').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_olive'))
        }
        .alignItems(VerticalAlign.Center)
        AppButton({ text: '注册并登录', full: true, onTap: () => this.doRegister() })
      }
    }
    .width('100%').height('100%').padding(24).backgroundColor($r('app.color.bg_parchment')).alignItems(HorizontalAlign.Start)
  }

  private async doRegister(): Promise<void> {
    if (this.step < 3) {
      this.step++;
      return;
    }
    const sidOk = this.role === 'student' ? /^20\d{8,10}$/.test(this.sid) : this.sid.length >= 4;
    if (!sidOk) {
      Toast.show('学工号格式不正确');
      return;
    }
    if (!this.agree) {
      Toast.show('请先同意协议');
      return;
    }
    if (!this.pwd) {
      Toast.show('请设置密码');
      return;
    }
    try {
      const body = new RegisterBody();
      body.phone = this.phone;
      body.password = this.pwd;
      body.nickname = this.name || '新用户';
      body.role = this.role;
      body.studentId = this.sid;
      body.realName = this.name;
      body.campus = '中心校区';
      const result = await ApiRepo.register(body);
      AppStore.login(result.user, result.token);
      this.getUIContext().getRouter().replaceUrl({ url: ROUTES.home });
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }
}
