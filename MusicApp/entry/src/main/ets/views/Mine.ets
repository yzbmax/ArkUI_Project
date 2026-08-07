/**
 * 我的页（F06）：个人中心
 * 登录态切换：默认未登录，展示登录入口；点击进入本地校验登录表单
 * （用户名长度 > 6、密码长度 > 8，纯前端校验，不涉及后端）。
 * 登录成功展示资料头 + 收藏网格 + 退出登录；未登录隐藏用户相关信息。
 */
import { Colors, Font, Radius, Space } from '../theme/AppTheme';
import { UserType, SongItemType } from '../models/index';
import { musicRepository } from '../services/index';
import { CoverImage, tintMatrix } from '../components/common';

@Component
export struct Mine {
  @State isLogin: boolean = false;          // 登录态（默认未登录）
  @State showLogin: boolean = false;        // 是否展示登录表单
  @State user: UserType | null = null;      // 已登录用户资料

  // 登录表单字段
  @State username: string = '';
  @State password: string = '';
  @State loginError: string = '';           // 校验错误提示

  aboutToAppear(): void {
    if (this.isLogin) {
      this.loadUser();
    }
  }

  // 拉取用户资料（已登录后调用）
  private loadUser(): void {
    musicRepository.getUser().then((d: UserType) => {
      this.user = d;
    });
  }

  // 本地校验：用户名 > 6 位，密码 > 8 位
  private doLogin(): void {
    if (this.username.length <= 6) {
      this.loginError = '用户名长度需大于 6 位';
      return;
    }
    if (this.password.length <= 8) {
      this.loginError = '密码长度需大于 8 位';
      return;
    }
    this.loginError = '';
    this.isLogin = true;
    this.showLogin = false;
    this.loadUser();
  }

  private doLogout(): void {
    this.isLogin = false;
    this.showLogin = false;
    this.user = null;
    this.username = '';
    this.password = '';
    this.loginError = '';
  }

  build() {
    Scroll() {
      Column({ space: 20 }) {
        // 页面大标题
        Text('我的')
          .fontSize(Font.title)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
          .alignSelf(ItemAlign.Start)
          .padding({ left: Space.xxl, top: Space.xl, bottom: Space.sm })

        if (!this.isLogin) {
          // ---- 未登录：展示登录入口或登录表单 ----
          if (!this.showLogin) {
            this.buildLoginEntry()
          } else {
            this.buildLoginForm()
          }
        } else if (this.user) {
          // ---- 已登录：用户信息 + 退出 ----
          this.buildUserProfile()
        } else {
          // 已登录但资料未加载完成：占位
          Column()
            .width('100%')
            .height(120)
            .backgroundColor(Colors.surface)
            .borderRadius(Radius.card)
            .margin({ left: Space.xxl, right: Space.xxl })
        }
      }
      .width('100%')
      .padding({ left: 0, right: 0, bottom: 150 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bg)
  }

  // 未登录：登录入口卡片
  @Builder
  private buildLoginEntry() {
    Column({ space: Space.lg }) {
      // 头像占位
      Column() {
        Text('登')
          .fontSize(Font.head)
          .fontColor(Colors.textPrimary)
          .fontWeight(FontWeight.Bold)
      }
      .width(72)
      .height(72)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Colors.surfaceMid)
      .borderRadius(Radius.circle)

      Text('未登录')
        .fontSize(Font.head)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.textPrimary)

      Text('登录后同步你的收藏与偏好')
        .fontSize(Font.caption)
        .fontColor(Colors.textSecondary)

      Button('登录 / 注册')
        .fontSize(Font.body)
        .fontColor(Colors.bg)
        .backgroundColor(Colors.accent)
        .borderRadius(Radius.pill)
        .height(44)
        .width('60%')
        .onClick(() => {
          this.showLogin = true;
        })
    }
    .width('100%')
    .padding({ top: 60, bottom: 60 })
    .alignItems(HorizontalAlign.Center)
  }

  // 未登录：登录表单
  @Builder
  private buildLoginForm() {
    Column({ space: Space.lg }) {
      Text('账号登录')
        .fontSize(Font.head)
        .fontWeight(FontWeight.Medium)
        .fontColor(Colors.textPrimary)
        .alignSelf(ItemAlign.Start)

      // 用户名输入
      TextInput({ placeholder: '用户名（大于 6 位）', text: this.username })
        .width('100%')
        .height(48)
        .backgroundColor(Colors.surface)
        .borderRadius(Radius.card)
        .fontColor(Colors.textPrimary)
        .placeholderColor(Colors.textSecondary)
        .onChange((v: string) => {
          this.username = v;
          this.loginError = '';
        })

      // 密码输入
      TextInput({ placeholder: '密码（大于 8 位）', text: this.password })
        .width('100%')
        .height(48)
        .backgroundColor(Colors.surface)
        .borderRadius(Radius.card)
        .fontColor(Colors.textPrimary)
        .placeholderColor(Colors.textSecondary)
        .type(InputType.Password)
        .onChange((v: string) => {
          this.password = v;
          this.loginError = '';
        })

      // 错误提示
      if (this.loginError.length > 0) {
        Text(this.loginError)
          .fontSize(Font.caption)
          .fontColor(Colors.negative)
          .alignSelf(ItemAlign.Start)
          .width('100%')
      }

      // 登录按钮
      Button('登录')
        .fontSize(Font.body)
        .fontColor(Colors.bg)
        .backgroundColor(Colors.accent)
        .borderRadius(Radius.pill)
        .height(44)
        .width('100%')
        .onClick(() => {
          this.doLogin();
        })

      // 返回入口
      Button('取消')
        .fontSize(Font.caption)
        .fontColor(Colors.textSecondary)
        .backgroundColor(Colors.transparent)
        .borderRadius(Radius.pill)
        .height(36)
        .width('100%')
        .onClick(() => {
          this.showLogin = false;
          this.loginError = '';
        })
    }
    .width('100%')
    .padding({ left: Space.xxl, right: Space.xxl, top: Space.xl })
    .alignItems(HorizontalAlign.Start)
  }

  // 已登录：用户信息 + 退出
  @Builder
  private buildUserProfile() {
    Column({ space: 20 }) {
      // 资料头
      Row() {
        // 头像占位（预留真实头像资源位置）
        Column() {
          Text(this.user!.name.charAt(0))
            .fontSize(Font.head)
            .fontColor(Colors.textPrimary)
            .fontWeight(FontWeight.Bold)
        }
        .width(64)
        .height(64)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.user!.avatarColor)
        .borderRadius(Radius.circle)

        Column() {
          Row() {
            Text(this.user!.name)
              .fontSize(Font.body)
              .fontColor(Colors.textPrimary)
              .fontWeight(FontWeight.Bold)
            if (this.user!.vip) {
              // VIP 标记（接入 star 图标）
              Image($r('app.media.star'))
                .width(16)
                .height(16)
                .objectFit(ImageFit.Contain)
                .colorFilter(tintMatrix(Colors.accent))
                .margin({ left: Space.sm })
            }
          }
          Text(this.user!.age + '岁 · ' + this.user!.star + ' · ' + this.user!.city)
            .margin({ top: 4 })
            .fontSize(Font.small)
            .fontColor(Colors.textSecondary)
        }
        .alignItems(HorizontalAlign.Start)
        .margin({ left: Space.md })
      }
      .width('100%')
      .padding({ bottom: Space.lg })

      // 关注 / 粉丝
      Row() {
        Text('关注 ' + this.user!.follow).fontSize(Font.caption).fontColor(Colors.textPrimary)
        Text('粉丝 ' + this.user!.fans)
          .margin({ left: Space.xl })
          .fontSize(Font.caption)
          .fontColor(Colors.textPrimary)
      }
      .width('100%')

      // 收藏封面网格
      Text('我收藏的')
        .fontSize(Font.head)
        .fontWeight(FontWeight.Bold)
        .fontColor(Colors.textPrimary)
        .alignSelf(ItemAlign.Start)
        .padding({ bottom: Space.md })

      GridRow({ columns: 3, gutter: Space.md }) {
        ForEach(
          this.user!.collects,
          (song: SongItemType) => {
            GridCol() {
              CoverImage({ color: song.color, radius: Radius.card, img: song.img })
                .width('100%')
                .aspectRatio(1)
            }
          },
          (song: SongItemType) => song.id
        )
      }
      .width('100%')

      // 退出登录
      Button('退出登录')
        .fontSize(Font.body)
        .fontColor(Colors.negative)
        .backgroundColor(Colors.surface)
        .borderRadius(Radius.pill)
        .height(44)
        .width('100%')
        .margin({ top: Space.lg })
        .onClick(() => {
          this.doLogout();
        })
    }
    .width('100%')
    .padding({ left: Space.xxl, right: Space.xxl })
    .alignItems(HorizontalAlign.Start)
  }
}
