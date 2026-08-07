/**
 * 信用积分页（C604）—— 余额/等级/明细来自后端（ApiRepo.fetchCredit）。
 */
import { ApiRepo } from '../shared/api/ApiRepo';
import { CreditLog } from '../shared/mock/Models';
import { CreditBadge } from '../common/components/UI';
import { Icon } from '../common/components/Icon';
import { hexToTint, TINT } from '../common/components/tint';
import { CREDIT_TITLES } from '../shared/constants/Constants';
import { Toast } from '../common/utils/Toast';

@Entry
@Component
struct Credit {
  @State balance: number = 0;
  @State level: number = 1;
  @State logs: CreditLog[] = [];

  aboutToAppear(): void {
    this.load();
  }

  private async load(): Promise<void> {
    try {
      const d = await ApiRepo.fetchCredit();
      this.balance = d.balance;
      this.level = d.level;
      this.logs = d.logs;
    } catch (e) {
      Toast.show((e as Error).message);
    }
  }

  /** 当前等级到下一等级进度（0~100），满级返回 100 */
  private progress(): number {
    const floors: number[] = [0, 50, 150, 300, 500];
    if (this.level >= 5) {
      return 100;
    }
    const floor: number = floors[this.level - 1];
    const ceil: number = floors[this.level];
    return Math.max(0, Math.min(100, (this.balance - floor) / (ceil - floor) * 100));
  }

  build() {
    Column() {
      Row({ space: 8 }) {
        Icon({ name: 'arrow_left', iconSize: 24, tint: TINT.TEXT_NEAR_BLACK }).onClick(() => this.getUIContext().getRouter().back())
        Text('信用积分').fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
      }
      .width('100%').padding({ left: 16, right: 16, top: 12, bottom: 8 })
      .alignItems(VerticalAlign.Center)

      Scroll() {
        Column({ space: 16 }) {
          // 等级卡
          Column({ space: 8 }) {
            CreditBadge({ level: this.level })
            Text('当前等级：' + CREDIT_TITLES[this.level - 1]).fontSize($r('app.float.font_h2')).fontWeight(FontWeight.Bold)
            Text('积分余额：' + this.balance).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_olive'))
            // 进度（轨道 + 填充两层，避免填充色被覆盖）
            Stack({ alignContent: Alignment.Start }) {
              Row().width('100%').height(6).backgroundColor($r('app.color.bg_sand')).borderRadius(3)
              Row().width(this.progress() + '%').height(6).backgroundColor($r('app.color.brand_terracotta')).borderRadius(3)
            }.width('100%')
          }.width('100%').padding(24).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_hero')).alignItems(HorizontalAlign.Center)

          Text('积分明细').fontSize($r('app.float.font_subtitle')).fontColor($r('app.color.text_near_black'))
          if (this.logs.length === 0) {
            Text('暂无积分记录').fontSize($r('app.float.font_body_small')).fontColor($r('app.color.text_stone'))
          }
          ForEach(this.logs, (l: CreditLog) => {
            Row({ space: 12 }) {
              Column({ space: 4 }) {
                Text(l.event).fontSize($r('app.float.font_body')).fontColor($r('app.color.text_near_black'))
                Text(l.time).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone'))
              }.layoutWeight(1).alignItems(HorizontalAlign.Start)
              Text((l.delta >= 0 ? '+' : '') + l.delta)
                .fontSize($r('app.float.font_body')).fontColor(l.delta >= 0 ? $r('app.color.status_resolved') : $r('app.color.status_error'))
              Text('余 ' + l.balance).fontSize($r('app.float.font_caption')).fontColor($r('app.color.text_stone')).width(48).textAlign(TextAlign.End)
            }.width('100%').padding(12).backgroundColor($r('app.color.bg_ivory')).borderRadius($r('app.float.radius_feature'))
          }, (l: CreditLog) => l.id)
        }.padding(16)
      }.layoutWeight(1)
    }.width('100%').height('100%').backgroundColor($r('app.color.bg_parchment'))
  }
}
