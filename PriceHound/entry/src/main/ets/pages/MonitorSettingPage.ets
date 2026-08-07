import { DesignSpacing, DesignRadius, DesignTypography } from '../constants/DesignTokens';
import { getRepo } from '../repository/DataRepository';
import { ToastUtil } from '../components/Toast';
import { RouterUtil } from '../utils/RouterUtil';
import { SettingItem } from '../components/SettingItem';
import { DataSourceType } from '../constants/AppConstants';
import { ThemeManager } from '../utils/ThemeManager';

/**
 * MonitorSettingPage.ets
 * 监控设置页：刷新频率 / 数据源（Mock 或 CoinGecko 免费 API）/ 省电策略
 */
@Entry
@Component
export struct MonitorSettingPage {
  @StorageProp('theme.isDark') isDark: boolean = false;
  @State refreshIndex: number = 1; // 0=15min 1=30min 2=60min 3=每天
  @State wifiOnly: boolean = false;
  @State batteryPause: boolean = true;
  @State testing: boolean = false;
  @State testResult: string = '';

  private refreshOptions: string[] = ['每 15 分钟', '每 30 分钟', '每小时', '每天'];

  private switchDataSource(source: number): void {
    if (source === getRepo().dataSource) {
      return;
    }
    if (source === DataSourceType.COINGECKO) {
      ToastUtil.show('正在连接 CoinGecko 免费 API…');
      getRepo().switchDataSource(DataSourceType.COINGECKO).then((ok: boolean) => {
        if (ok) {
          ToastUtil.show('已切换至实时行情数据源');
        } else {
          ToastUtil.show('连接失败，已保持本地数据');
        }
      });
    } else {
      getRepo().switchDataSource(DataSourceType.MOCK).then(() => {
        ToastUtil.show('已切换至本地模拟数据');
      });
    }
  }

  build() {
    Column() {
      Row() {
        Text('‹')
          .fontSize(30)
          .fontColor(ThemeManager.textPrimary())
          .width(36)
          .onClick(() => RouterUtil.back())
        Text('监控设置')
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
          // ===== 刷新频率 =====
          Column({ space: DesignSpacing.MD }) {
            Text('刷新频率')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')
            Column({ space: DesignSpacing.SM }) {
              ForEach(this.refreshOptions, (opt: string, index: number) => {
                Row() {
                  Text(opt)
                    .fontSize(DesignTypography.SIZE_BODY)
                    .fontColor(this.refreshIndex === index ? ThemeManager.accent() : ThemeManager.textPrimary())
                  Blank()
                  if (this.refreshIndex === index) {
                    Text('●')
                      .fontSize(12)
                      .fontColor(ThemeManager.accent())
                  }
                }
                .width('100%')
                .padding({ left: DesignSpacing.LG, right: DesignSpacing.LG, top: 14, bottom: 14 })
                .backgroundColor(ThemeManager.card())
                .borderRadius(DesignRadius.MD)
                .onClick(() => {
                  this.refreshIndex = index;
                  ToastUtil.show(`已设置为${opt}`);
                })
              }, (opt: string) => opt)
            }
            .width('100%')
          }
          .width('100%')

          // ===== 数据源 =====
          Column({ space: DesignSpacing.MD }) {
            Text('数据源')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')
            SettingItem({
              icon: '🧪',
              title: '本地模拟数据',
              subtitle: '离线可用，用于演示',
              rightText: getRepo().dataSource === DataSourceType.MOCK ? '使用中' : '',
              onClickItem: () => this.switchDataSource(DataSourceType.MOCK),
            })
            SettingItem({
              icon: '🪙',
              title: 'CoinGecko 实时行情',
              subtitle: '免费公开 API，无密钥，需联网',
              rightText: getRepo().dataSource === DataSourceType.COINGECKO ? '使用中' : '',
              onClickItem: () => this.switchDataSource(DataSourceType.COINGECKO),
            })
            // API 连通性测试
            Row({ space: DesignSpacing.MD }) {
              Text('测试数据源连接')
                .fontSize(DesignTypography.SIZE_BODY_SM)
                .fontColor(ThemeManager.textPrimary())
                .layoutWeight(1)
              if (this.testing) {
                LoadingProgress()
                  .width(18)
                  .height(18)
                  .color(ThemeManager.accent())
              } else {
                Text(this.testResult.length > 0 ? this.testResult : '运行测试')
                  .fontSize(DesignTypography.SIZE_LABEL)
                  .fontColor(this.testResult === '连接正常' ? ThemeManager.ok() : ThemeManager.textTertiary())
                  .onClick(async () => {
                    this.testing = true;
                    const ok = await getRepo().switchDataSource(DataSourceType.COINGECKO);
                    this.testing = false;
                    if (ok) {
                      this.testResult = '连接正常';
                      ToastUtil.show('CoinGecko API 连接正常');
                    } else {
                      this.testResult = '连接失败';
                      ToastUtil.show('连接失败，请检查网络');
                    }
                  })
              }
            }
            .width('100%')
            .padding(DesignSpacing.MD)
            .backgroundColor(ThemeManager.card())
            .borderRadius(DesignRadius.MD)
          }
          .width('100%')

          // ===== 省电策略 =====
          Column({ space: DesignSpacing.MD }) {
            Text('省电策略')
              .fontSize(DesignTypography.SIZE_OVERLINE)
              .fontColor(ThemeManager.textTertiary())
              .width('100%')
            SettingItem({
              icon: '📶',
              title: '仅 Wi-Fi 下刷新',
              subtitle: '节省移动数据流量',
              showSwitch: true,
              switchValue: this.wifiOnly,
              onSwitchChange: (v: boolean) => {
                this.wifiOnly = v;
              },
            })
            SettingItem({
              icon: '🔋',
              title: '低电量时暂停监控',
              subtitle: '电量低于 20% 时自动暂停',
              showSwitch: true,
              switchValue: this.batteryPause,
              onSwitchChange: (v: boolean) => {
                this.batteryPause = v;
              },
            })
          }
          .width('100%')

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
