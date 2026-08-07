/**
 * 寻物发布（C401）—— 字段表单，含感谢方式、紧急程度、匿名。
 */
import { CATEGORIES, CategoryItem } from '../shared/constants/Constants';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { ApiRepo } from '../shared/api/ApiRepo';
import { Post } from '../shared/mock/Models';
import { AppButton } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { Toast } from '../common/utils/Toast';
import { PostType } from '../shared/constants/Constants';

@Entry
@Component
struct PublishFound {
  @State title: string = '';
  @State desc: string = '';
  @State location: string = '';
  @State time: string = '';
  @State reward: string = '';
  @State urgent: boolean = false;
  @State anonymous: boolean = false;
  @State catIdx: number = 0;
  @State submitting: boolean = false;
  @State images: string[] = [];

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('发布寻物').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          this.Field('丢失物品*', '如：蓝牙耳机', this.title, (v) => this.title = v)
          Text('分类*').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black'))
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(CATEGORIES, (c: CategoryItem, i: number) => {
              Text(c.name).fontSize($r('app.float.font_body_small'))
                .fontColor(this.catIdx === i ? $r('app.color.text_on_brand') : $r('app.color.text_charcoal'))
                .backgroundColor(this.catIdx === i ? $r('app.color.brand_terracotta') : $r('app.color.bg_sand'))
                .padding({ left: 12, right: 12, top: 6, bottom: 6 }).borderRadius($r('app.float.radius_rounded'))
                .margin({ right: 8, bottom: 8 })
                .onClick(() => this.catIdx = i)
            })
          }
          this.Field('丢失描述*', '描述丢失经过', this.desc, (v) => this.desc = v, true)
          this.Field('丢失地点*', '如：食堂', this.location, (v) => this.location = v)
          this.Field('丢失时间', '如：昨天傍晚', this.time, (v) => this.time = v)
          this.Field('感谢方式', '如：奶茶一杯', this.reward, (v) => this.reward = v)
          // 照片 9 宫格 —— 从系统相册选择，最多 9 张
          Text('照片（可选）').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black'))
          Grid() {
            ForEach(this.images, (uri: string, idx: number) => {
              GridItem() {
                Stack({ alignContent: Alignment.TopEnd }) {
                  Image(uri).width('100%').height('100%').objectFit(ImageFit.Cover)
                    .borderRadius($r('app.float.radius_generous')).border({ width: 1, color: $r('app.color.border_warm') })
                  Icon({ name: 'x', iconSize: 12, tint: TINT.WHITE })
                    .padding(3).backgroundColor('#66000000').borderRadius(10).margin(4)
                    .onClick(() => { this.removeImage(idx); })
                }
              }
            }, (uri: string) => uri)
            if (this.images.length < 9) {
              GridItem() {
                Column() {
                  Icon({ name: 'plus', iconSize: 24, tint: TINT.TEXT_STONE })
                }
                .width('100%').height('100%')
                .justifyContent(FlexAlign.Center).alignItems(HorizontalAlign.Center)
                .backgroundColor($r('app.color.bg_sand'))
                .borderRadius($r('app.float.radius_generous')).border({ width: 1, color: $r('app.color.border_warm') })
                .onClick(() => { this.pickImages(); })
              }
            }
          }
          .columnsTemplate('1fr 1fr 1fr')
          .rowsTemplate('1fr 1fr 1fr')
          .columnsGap(8)
          .rowsGap(8)
          .width('100%')
          .height(328)
          Row({ space: 24 }) {
            Row({ space: 6 }) {
              Icon({ name: 'bolt', iconSize: 18, tint: this.urgent ? TINT.STATUS_URGENT : TINT.TEXT_STONE })
                .onClick(() => this.urgent = !this.urgent)
              Text('加急（置顶 3 天）').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_olive'))
            }
            .alignItems(VerticalAlign.Center)
            Row({ space: 6 }) {
              Icon({ name: 'bookmark', iconSize: 18, tint: this.anonymous ? TINT.BRAND_TERRACOTTA : TINT.TEXT_STONE })
                .onClick(() => this.anonymous = !this.anonymous)
              Text('匿名').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_olive'))
            }
            .alignItems(VerticalAlign.Center)
          }
          .alignItems(VerticalAlign.Center)
          AppButton({ text: '提交（进入审核）', full: true, loading: this.submitting, onTap: () => this.submit() })
        }
        .padding(16)
      }
      .layoutWeight(1)
    }
    .width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }

  @Builder
  Field(label: string, placeholder: string, value: string, onChange: (v: string) => void, multi: boolean = false) {
    Column({ space: 6 }) {
      Text(label).fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black')).alignSelf(ItemAlign.Start)
      TextInput({ placeholder, text: value })
        .onChange(onChange)
        .height(multi ? 88 : 48)
        .backgroundColor($r('app.color.bg_ivory'))
        .borderRadius($r('app.float.radius_generous'))
    }.alignItems(HorizontalAlign.Start)
  }

  /** 打开系统相册，多选图片（最多 9 张） */
  private async pickImages(): Promise<void> {
    try {
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result = await photoPicker.select({
        MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE,
        maxSelectNumber: 9 - this.images.length
      });
      const uris: string[] = result.photoUris ?? [];
      if (uris.length > 0) {
        this.images = this.images.concat(uris);
      }
    } catch (e) {
      Toast.show('选择图片失败');
    }
  }

  private removeImage(idx: number): void {
    this.images = this.images.filter((_v: string, i: number) => i !== idx);
  }

  private async submit(): Promise<void> {
    if (!this.title || !this.desc || !this.location) {
      Toast.show('请填写必填项');
      return;
    }
    this.submitting = true;
    try {
      // 1) 上传图片 → 拿到 URL
      let urls: string[] = [];
      if (this.images.length > 0) {
        const bases: string[] = [];
        for (const uri of this.images) {
          const b64 = await ApiRepo.readFileToBase64(uri);
          if (b64.length > 0) {
            bases.push(b64);
          }
        }
        if (bases.length > 0) {
          const up = await ApiRepo.uploadImages(bases);
          urls = up.urls;
        }
      }
      // 2) 创建动态（进审核）
      const p = new Post();
      p.type = PostType.FOUND;
      p.title = this.title;
      p.desc = this.desc;
      p.category = CATEGORIES[this.catIdx].key;
      p.categoryName = CATEGORIES[this.catIdx].name;
      p.location = this.location;
      p.reward = this.reward;
      p.urgent = this.urgent;
      p.anonymous = this.anonymous;
      await ApiRepo.addPost(p, urls);
      Toast.show('已提交，等待审核');
      this.getUIContext().getRouter().back();
    } catch (e) {
      Toast.show((e as Error).message);
    } finally {
      this.submitting = false;
    }
  }
}
