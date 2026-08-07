/**
 * 公共 UI 组件库（A004）
 * 按钮、状态标签、信用徽章、空状态、Toast、骨架屏 —— 复用 DESIGN.md 5.x 规范。
 */
import { CREDIT_TITLES } from '../../shared/constants/Constants';
import { Icon } from './Icon';
import { hexToTint, TINT } from './tint';

export enum BtnVariant {
  PRIMARY = 'primary',
  SECONDARY = 'secondary',
  DANGER = 'danger',
  TEXT = 'text'
}

@Component
export struct AppButton {
  @Prop text: string = '按钮';
  @Prop variant: BtnVariant = BtnVariant.PRIMARY;
  @Prop full: boolean = false;
  @Prop loading: boolean = false;
  onTap: () => void = () => {};

  build() {
    Button(this.loading ? '...' : this.text)
      .width(this.full ? '100%' : 'auto')
      .height(44)
      .backgroundColor(this.variant === BtnVariant.PRIMARY ? $r('app.color.brand_terracotta')
        : this.variant === BtnVariant.DANGER ? $r('app.color.status_error')
          : this.variant === BtnVariant.SECONDARY ? $r('app.color.bg_sand') : Color.Transparent)
      .fontColor(this.variant === BtnVariant.TEXT ? $r('app.color.brand_terracotta')
        : this.variant === BtnVariant.SECONDARY ? $r('app.color.text_charcoal') : $r('app.color.text_on_brand'))
      .fontSize($r('app.float.font_subtitle'))
      .borderRadius($r('app.float.radius_generous'))
      .enabled(!this.loading)
      .onClick(() => {
        if (!this.loading) {
          this.onTap();
        }
      })
  }
}

@Component
export struct StatusTag {
  @Prop label: string = '';
  @Prop color: Resource = $r('app.color.status_pending');
  @Prop filled: boolean = false;

  build() {
    // 保持简单 Text 结构（避免影响卡片布局）。
    // 非 filled：沙色背景 + 状态色文字（文字全不透明，保证对比度）
    // filled：实心状态色背景 + 浅色文字
    Text(this.label)
      .fontSize($r('app.float.font_label'))
      .fontWeight(FontWeight.Medium)
      .fontColor(this.filled ? $r('app.color.text_on_brand') : this.color)
      .backgroundColor(this.filled ? this.color : $r('app.color.bg_sand'))
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius($r('app.float.radius_sharp'))
  }
}

/** 称号等级 1~5 的柔和底色与文字色（低饱和，不喧宾夺主） */
const BADGE_BG: Resource[] = [
  $r('app.color.badge_l1_bg'), $r('app.color.badge_l2_bg'), $r('app.color.badge_l3_bg'),
  $r('app.color.badge_l4_bg'), $r('app.color.badge_l5_bg')
];
const BADGE_TEXT: Resource[] = [
  $r('app.color.badge_l1_text'), $r('app.color.badge_l2_text'), $r('app.color.badge_l3_text'),
  $r('app.color.badge_l4_text'), $r('app.color.badge_l5_text')
];

@Component
export struct CreditBadge {
  @Prop level: number = 1;

  build() {
    Row({ space: 4 }) {
      Text('★')
        .fontSize(11)
        .fontColor(BADGE_TEXT[Math.min(this.level, 5) - 1])
      Text(CREDIT_TITLES[Math.min(this.level, 5) - 1])
        .fontSize($r('app.float.font_label'))
        .fontColor(BADGE_TEXT[Math.min(this.level, 5) - 1])
    }
    .padding({ left: 8, right: 8, top: 3, bottom: 3 })
    .backgroundColor(BADGE_BG[Math.min(this.level, 5) - 1])
    .borderRadius($r('app.float.radius_rounded'))
  }
}

@Component
export struct EmptyState {
  @Prop icon: string = 'search_bag';
  @Prop title: string = '空空如也';
  @Prop desc: string = '';
  @Prop action: string = '';
  onAction: () => void = () => {};

  build() {
    Column({ space: 12 }) {
      Icon({ name: this.icon, iconSize: 64, tint: TINT.TEXT_STONE })
        .opacity(0.5)
      Text(this.title)
        .fontSize($r('app.float.font_display'))
        .fontFamily('Noto Serif SC')
        .fontColor($r('app.color.text_near_black'))
      if (this.desc) {
        Text(this.desc)
          .fontSize($r('app.float.font_body_small'))
          .fontColor($r('app.color.text_stone'))
      }
      if (this.action) {
        AppButton({ text: this.action, onTap: this.onAction })
      }
    }
    .width('100%')
    .padding({ top: 80, bottom: 80 })
    .alignItems(HorizontalAlign.Center)
  }
}

/** 头像占位组件 —— 圆形背景 + 人物轮廓线 */
@Component
export struct AvatarPlaceholder {
  @Prop iconSize: number = 32;
  @Prop bgColor: ResourceColor = $r('app.color.text_stone');

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Circle({ width: this.iconSize, height: this.iconSize }).fill(this.bgColor)
      Icon({ name: 'user', iconSize: this.iconSize * 0.5, tint: TINT.BG_IVORY })
    }
  }
}

@Component
export struct Skeleton {
  build() {
    Column() {
      ForEach(Array.from({ length: 4 }), (_v: void, index: number) => {
        Row({ space: 12 }) {
          Column()
            .width(80)
            .height(80)
            .backgroundColor($r('app.color.border_warm'))
            .borderRadius($r('app.float.radius_feature'))
          Column({ space: 8 }) {
            Row().width('60%').height(16).backgroundColor($r('app.color.border_warm')).borderRadius(4)
            Row().width('90%').height(12).backgroundColor($r('app.color.border_cream')).borderRadius(4)
            Row().width('40%').height(12).backgroundColor($r('app.color.border_cream')).borderRadius(4)
          }.layoutWeight(1)
        }
        .padding(16)
        .backgroundColor($r('app.color.bg_ivory'))
        .borderRadius($r('app.float.radius_feature'))
        .margin({ bottom: 12 })
      })
    }
  }
}
