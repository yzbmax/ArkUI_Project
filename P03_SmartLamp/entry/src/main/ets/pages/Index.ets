@Entry
@Component
struct Index {
  @State isOn:boolean = true
  @State lampBrightness:number = 60

  build() {
    Column({space : 18}){

      Text('台灯状态样式')
        .fontSize(32)
        .fontWeight(900)
      Column({space : 18}){
        Text(this.isOn ? '💡' : '🌙')
          .fontSize(96)
        Text(this.isOn ? '台灯已开启' : '台灯已关闭')
          .fontSize(24)
        Row(){
          Text(this.isOn ? '台灯亮度是'+ this.lampBrightness + '%'  : '')
            .fontSize(16)
          if (this.lampBrightness <= 30 && this.isOn == true){
            Text('柔和模式')
              .fontSize(16)
              .fontWeight(900)
          }
          if (this.lampBrightness < 80 && this.lampBrightness >30 && this.isOn == true) {
            Text('标准模式')
              .fontSize(16)
              .fontWeight(900)
          }
          if (this.lampBrightness >= 80 && this.isOn == true) {
            Text('高亮模式')
              .fontSize(16)
              .fontWeight(900)
          }
        }


      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.isOn ? '#FEF08A' : '#D0D5D8')
      .width('80%')
      .height('300')
      .borderRadius(20)
      Row(){
        Text('电源')
          .fontSize(18)
          .fontWeight(900)
        Toggle({ type: ToggleType.Switch, isOn: this.isOn })
          .onChange((value: boolean) => {
            this.isOn = value;
          })
      }
      .width("75%")
      .justifyContent(FlexAlign.SpaceBetween)
      if (this.isOn) {
        Row(){
          Slider({
            min : 0,
            max : 100,
            value:  this.lampBrightness
          })
            .width('60%')
            .onChange((value: number) => {
              this.lampBrightness = value
            })
          Button('重置')
            .fontSize(14)
            .height(30)
            .onClick(() => {
              this.lampBrightness = 60
            })
        }

      }
      Button(this.isOn ? '关灯' : '开灯')
        .onClick(() => {
          this.isOn = !this.isOn
        })
        .width('80%')
        .padding({top : 15 , bottom : 15})
        .fontSize(18)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)

  }
}