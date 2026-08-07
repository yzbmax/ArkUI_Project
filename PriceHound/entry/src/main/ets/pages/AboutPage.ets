import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { RouterUtil } from '../utils/RouterUtil';
import { AppConfig } from '../constants/AppConstants';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * AboutPage.ets
 * 关于页：应用介绍 / 版本 / 数据源说明 / 免责声明
 */
@Entry
@Component
export struct AboutPage {
  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor(ThemeManager.textPrimary())
          .width(36)
          .onClick(() => RouterUtil.back())
        Text('关于 PriceHound')
          .fontFamily(DesignTypography.FONT_SERIF)
          .fontSize(DesignTypography.SIZE_TITLE)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeManager.textPrimary())
        Blank()
        Blank().width(36)
      }
      .width('100%')
      .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: DesignSpacing.MD, bottom: DesignSpacing.MD })

      Scroll() {
        Column({ space: DesignSpacing.XL }) {
          // ===== Logo =====
          Column({ space: DesignSpacing.MD }) {
            Text('🐾')
              .fontSize(72)
              .width(120)
              .height(120)
              .textAlign(TextAlign.Center)
              .backgroundColor(ThemeManager.surface())
              .borderRadius(DesignRadius.XL)
            Text('PriceHound')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H1)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
            Text(`版本 ${AppConfig.VERSION}`)
              .fontSize(DesignTypography.SIZE_CAPTION)
              .fontColor(ThemeManager.textTertiary())
            Text('价格侦探 · 盯住每一次降价')
              .fontSize(DesignTypography.SIZE_BODY_SM)
              .fontColor(ThemeManager.textSecondary())
          }
          .width('100%')
          .padding({ top: DesignSpacing.XL, bottom: DesignSpacing.XL })

          // ===== 介绍 =====
          Column({ space: DesignSpacing.SM }) {
            Text('关于应用')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H3)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
              .width('100%')
            Text('PriceHound 是一款商品价格监控工具，帮助你记录心仪商品的价格走势、设置降价提醒，'
              + '在合适的时机以合适的价格入手。')
              .fontSize(DesignTypography.SIZE_BODY_SM)
              .fontColor(ThemeManager.textSecondary())
              .lineHeight(24)
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 数据源 =====
          Column({ space: DesignSpacing.SM }) {
            Text('数据源说明')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H3)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
              .width('100%')
            Text('· 本地模拟数据：离线可用，用于功能演示\n'
              + '· CoinGecko 免费公开 API：无需密钥，提供加密货币实时行情数据\n'
              + '· 可在「监控设置」中切换数据源')
              .fontSize(DesignTypography.SIZE_BODY_SM)
              .fontColor(ThemeManager.textSecondary())
              .lineHeight(24)
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 免责声明 =====
          Column({ space: DesignSpacing.SM }) {
            Text('免责声明')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H3)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
              .width('100%')
            Text('价格数据仅供参考，不构成任何购买建议。实际成交价格以各平台页面为准。')
              .fontSize(DesignTypography.SIZE_BODY_SM)
              .fontColor(ThemeManager.textSecondary())
              .lineHeight(24)
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          Blank().height(40)
        }
        .width('100%')
        .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG })
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .align(Alignment.Top)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(ThemeManager.bg())
  }
}
