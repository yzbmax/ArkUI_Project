/**
 * 个人信息编辑（C104）—— 头像/昵称/简介/校区；游客拦截由路由守卫处理。
 */
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { AppStore } from '../shared/store/AppStore';
import { CAMPUSES } from '../shared/constants/Constants';
import { AppButton, AvatarPlaceholder } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';
import { ApiRepo } from '../shared/api/ApiRepo';
import { IMG_PREFIX } from '../shared/api/HttpClient';

@Entry
@Component
struct EditProfile {
  @State nickname: string = AppStore.user?.nickname || '';
  @State bio: string = '';
  @State campusIdx: number = 0;
  @State avatarUri: string = ''; // 本次新选的本地图片 URI（用于预览）

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('编辑资料').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          Row({ space: 12 }) {
            this.Avatar()
            Column({ space: 4 }) {
              Text('更换头像').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.brand_terracotta'))
              Text('点击从相册选择').fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
            }.alignItems(HorizontalAlign.Start)
          }
          .width('100%').padding(16)
          .alignItems(VerticalAlign.Center)
          .onClick(() => { this.pickAvatar(); })

          this.Field('昵称*', '2~12 字', this.nickname, (v) => this.nickname = v)
          this.Field('简介', '一句话介绍自己', this.bio, (v) => this.bio = v, true)

          Text('校区').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black')).alignSelf(ItemAlign.Start)
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(CAMPUSES, (c: string, i: number) => {
              Text(c).fontSize($r('app.float.font_body_small'))
                .fontColor(this.campusIdx === i ? $r('app.color.text_on_brand') : $r('app.color.text_charcoal'))
                .backgroundColor(this.campusIdx === i ? $r('app.color.brand_terracotta') : $r('app.color.bg_sand'))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 }).borderRadius($r('app.float.radius_rounded'))
                .margin({ right: 8, bottom: 8 })
                .onClick(() => this.campusIdx = i)
            })
          }
          AppButton({ text: '保存', full: true, onTap: () => this.save() })
        }.padding(16)
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }

  @Builder
  Field(label: string, placeholder: string, value: string, onChange: (v: string) => void, multi: boolean = false) {
    Column({ space: 6 }) {
      Text(label).fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black')).alignSelf(ItemAlign.Start)
      TextInput({ placeholder, text: value }).onChange(onChange)
        .height(multi ? 88 : 48).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_generous'))
    }.alignItems(HorizontalAlign.Start)
  }

  /** 头像显示：新选 URI > 已有头像 URL > 默认占位 */
  @Builder
  Avatar() {
    if (this.avatarUri !== '') {
      Image(this.avatarUri).width(64).height(64).borderRadius(32).objectFit(ImageFit.Cover)
        .border({ width: 1, color: $r('app.color.border_cream') })
    } else if (this.existingAvatar() !== '') {
      Image(IMG_PREFIX + this.existingAvatar()).width(64).height(64).borderRadius(32).objectFit(ImageFit.Cover)
        .border({ width: 1, color: $r('app.color.border_cream') })
    } else {
      AvatarPlaceholder({ iconSize: 64 })
    }
  }

  /** 当前用户已保存的头像相对路径（无则空串） */
  private existingAvatar(): string {
    const a: ResourceStr = AppStore.user?.avatar ?? '';
    return (typeof a === 'string') ? (a as string) : '';
  }

  /** 从系统相册选 1 张，先预览，保存时再上传 */
  private async pickAvatar(): Promise<void> {
    try {
      const picker = new photoAccessHelper.PhotoViewPicker();
      const result = await picker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 1
      });
      const uris: string[] = result.photoUris ?? [];
      if (uris.length > 0) {
        this.avatarUri = uris[0];
      }
    } catch (e) {
      Toast.show('选择图片失败');
    }
  }

  private async save(): Promise<void> {
    if (this.nickname.length < 2) {
      Toast.show('昵称至少 2 个字');
      return;
    }
    try {
      // 新选了头像才上传，未选则沿用原头像
      let avatarUrl: string = '';
      if (this.avatarUri !== '') {
        const b64 = await ApiRepo.readFileToBase64(this.avatarUri);
        if (b64.length > 0) {
          const up = await ApiRepo.uploadImages([b64]);
          avatarUrl = up.urls[0] ?? '';
        }
      }
      await ApiRepo.updateProfile(this.nickname, CAMPUSES[this.campusIdx], avatarUrl);
      if (AppStore.user) {
        AppStore.user.nickname = this.nickname;
        AppStore.user.campus = CAMPUSES[this.campusIdx];
        if (avatarUrl !== '') {
          AppStore.user.avatar = avatarUrl;
        }
        AppStore.save('user', JSON.stringify(AppStore.user));
      }
      Toast.show('已保存');
      this.getUIContext().getRouter().back();
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }
}
