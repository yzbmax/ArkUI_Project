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
        Text(this.isOn ? '台灯亮度是'+ this.lampBrightness + '%' : '')
          .fontSize(16)
      }
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.isOn ? '#FEF08A' : '#D0D5D8')
      .width('80%')
      .height('300')
      .borderRadius(20)
      if (this.isOn) {
        Slider({
          min : 0,
          max : 100,
          value:  this.lampBrightness
        })
          .width('80%')
          .onChange((value: number) => {
            this.lampBrightness = value
          })
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