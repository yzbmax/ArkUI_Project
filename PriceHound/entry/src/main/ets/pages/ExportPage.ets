import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { getRepo } from '../repository/DataRepository';
import { Product } from '../model/Product';
import { ToastUtil } from '../components/Toast';
import { RouterUtil } from '../utils/RouterUtil';
import { SettingItem } from '../components/SettingItem';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * ExportPage.ets
 * 导出页：CSV / JSON 导出 + 选择商品 + 模拟导出流程
 */
@Entry
@Component
export struct ExportPage {
  @StorageProp('theme.isDark') isDark: boolean = false;
  @State selectedAll: boolean = true;
  @State exporting: boolean = false;
  @State exportDone: boolean = false;

  private selectedProducts(): Array<Product> {
    if (this.selectedAll) {
      return getRepo().products;
    }
    return [];
  }

  private buildCsv(): string {
    let csv = '商品名称,平台,当前价格,划线价,历史最低,历史最高\n';
    for (let i = 0; i < this.selectedProducts().length; i++) {
      const p = this.selectedProducts()[i];
      csv += `${p.name},${p.platform},${p.currentPrice},${p.originalPrice},${p.lowestPrice},${p.highestPrice}\n`;
    }
    return csv;
  }

  private buildPriceCsv(): string {
    let csv = '商品名称,记录时间,价格\n';
    for (let i = 0; i < getRepo().products.length; i++) {
      const p = getRepo().products[i];
      const recs = getRepo().getRecords(p.id);
      for (let j = 0; j < recs.length; j++) {
        const r = recs[j];
        csv += `${p.name},${r.timestamp},${r.price}\n`;
      }
    }
    return csv;
  }

  private buildJson(): string {
    const data: Array<Product> = [];
    for (let i = 0; i < getRepo().products.length; i++) {
      data.push(getRepo().products[i]);
    }
    return JSON.stringify({ exportedAt: Date.now(), version: '1.0', products: data });
  }

  private simulateExport(format: string): void {
    this.exporting = true;
    setTimeout(() => {
      this.exporting = false;
      this.exportDone = true;
      let size = 0;
      if (format === 'CSV') {
        size = this.buildCsv().length;
      } else if (format === '价格历史 CSV') {
        size = this.buildPriceCsv().length;
      } else {
        size = this.buildJson().length;
      }
      ToastUtil.show(`${format} 导出完成（约 ${Math.max(1, Math.round(size / 1024))} KB）`);
    }, 1200);
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor(ThemeManager.textPrimary())
          .width(36)
          .onClick(() => RouterUtil.back())
        Text('导出数据')
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
          // ===== 导出说明 =====
          Column({ space: DesignSpacing.SM }) {
            Text('📤 导出监控数据')
              .fontFamily(DesignTypography.FONT_SERIF)
              .fontSize(DesignTypography.SIZE_H2)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeManager.textPrimary())
            Text('支持导出为 CSV 或 JSON 格式，方便你在其他工具中分析价格数据。')
              .fontSize(DesignTypography.SIZE_BODY_SM)
              .fontColor(ThemeManager.textSecondary())
              .lineHeight(22)
          }
          .width('100%')
          .padding(DesignSpacing.LG)
          .backgroundColor(ThemeManager.card())
          .borderRadius(DesignRadius.LG)

          // ===== 导出选项 =====
          Column({ space: DesignSpacing.MD }) {
            Text('导出内容')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')

            // 全部商品勾选
            Row({ space: DesignSpacing.MD }) {
              Text('全部商品')
                .fontSize(DesignTypography.SIZE_BODY)
                .fontColor(ThemeManager.textPrimary())
                .layoutWeight(1)
              Checkbox()
                .select(this.selectedAll)
                .selectedColor(ThemeManager.accent())
                .onChange((v: boolean) => {
                  this.selectedAll = v;
                })
            }
            .width('100%')
            .padding(DesignSpacing.MD)
            .backgroundColor(ThemeManager.card())
            .borderRadius(DesignRadius.MD)

            SettingItem({
              icon: '📊',
              title: '商品概览 CSV',
              subtitle: `当前价格 / 划线价 / 历史最低等 (${getRepo().products.length} 件)`,
              showArrow: true,
              onClickItem: () => this.simulateExport('CSV'),
            })
            SettingItem({
              icon: '📈',
              title: '价格历史 CSV',
              subtitle: '全部价格记录（约 1000+ 行）',
              showArrow: true,
              onClickItem: () => this.simulateExport('价格历史 CSV'),
            })
            SettingItem({
              icon: '🧾',
              title: '完整数据 JSON',
              subtitle: '包含商品与价格记录，可备份',
              showArrow: true,
              onClickItem: () => this.simulateExport('JSON'),
            })
          }
          .width('100%')

          // ===== 导出状态 =====
          if (this.exporting) {
            Row({ space: DesignSpacing.SM }) {
              LoadingProgress()
                .width(18)
                .height(18)
                .color(ThemeManager.accent())
              Text('正在生成导出文件…')
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textSecondary())
            }
            .width('100%')
            .padding(DesignSpacing.MD)
            .backgroundColor(ThemeManager.card())
            .borderRadius(DesignRadius.MD)
          }
          if (this.exportDone) {
            Row({ space: DesignSpacing.SM }) {
              Text('✅')
                .fontSize(18)
              Text('导出完成，文件已保存到 Download/PriceHound/')
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.ok())
            }
            .width('100%')
            .padding(DesignSpacing.MD)
            .backgroundColor(ThemeManager.card())
            .borderRadius(DesignRadius.MD)
          }

          Blank().height(40)
        }
        .width('100%')
        .padding({ top: DesignSpacing.MD, left: DesignSpacing.LG, right: DesignSpacing.LG })
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
