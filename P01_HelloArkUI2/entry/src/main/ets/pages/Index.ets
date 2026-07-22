@Entry
@Component
struct Index {
  @State const:number = 0

  private getText(): string{
    if (this.const === 0){
      return '准备好开始了吗'
    }
    if (this.const > 2) {
      return '你已经迈出了第一步'
    }
    return '正在稳步前行中'
  }
  private BgColor(): string{
    if (this.const === 0){
      return '#94A3B8'
    }
    if (this.const == 1) {
      return '#64748B'
    }
    if (this.const == 2) {
      return '#475569'
    }
    if (this.const == 3) {
      return '#1E293B'
    }
    return '#0F172A'
  }

  build() {
    Column({ space: 18 }) {
      Text('ArkUI 项目化学习')
        .fontSize(38)
        .fontWeight(FontWeight.Bold)

      Column({space: 10}){
        Text(this.getText())
          .fontColor("#fff")
        Text(`已经点击了${this.const}次`)
          .fontSize(26)
          .fontColor("#fff")
      }
      .backgroundColor(this.BgColor())
      .padding(22)
      .borderRadius(30)


      Button('学习一次')
        .width('70%')
        .height(68)
        .onClick(()=>{
          this.const += 1
        })
    }
    .width("100%")
    .height('100%')
    .justifyContent(FlexAlign.Center)




  }
}