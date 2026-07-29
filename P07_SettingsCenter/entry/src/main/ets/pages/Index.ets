@Entry
@Component
struct Index {
  @State notificationEnabled:boolean = false
  @State autoSyncEnabled:boolean = false
  @State wifiOnlyEnabled:boolean = false
private allon(): boolean {
  return this.notificationEnabled && this.autoSyncEnabled && this.wifiOnlyEnabled
}
  build() {
    Column({space : 18}){
      Button("一键开启")
        .onClick(()=>{
          this.notificationEnabled = true
          this.autoSyncEnabled = true
          this.wifiOnlyEnabled = true
        })
      Row({space : 18}){
        Column(){
          Text('课程通知')
          Toggle({
            type: ToggleType.Switch,
            isOn: this.notificationEnabled
          })
            .onChange((value: boolean)=>{
              this.notificationEnabled = value
            })
        }
        Column(){
          Text('自动同步')
          Toggle({
            type: ToggleType.Switch,
            isOn: this.autoSyncEnabled
          })
            .onChange((value: boolean)=>{
              this.autoSyncEnabled = value
            })
        }
       Column(){
         Text('仅 Wi-Fi 同步')
         Toggle({
           type: ToggleType.Switch,
           isOn: this.wifiOnlyEnabled
         })
           .onChange((value: boolean)=>{
             this.wifiOnlyEnabled = value
           })
       }

      }
      .width('100%')
      .justifyContent(FlexAlign.Center)


      Text(this.allon() ? '全部开启' : '关闭')
      if (!this.notificationEnabled){
        Text('关闭课程通知将无法收到信息')
          .fontColor(Color.White)
          .width('100%')
          .backgroundColor('#FF2400')
          .padding(14)
          .borderRadius(10)
      } else {
        Text('课程通知已开启')
        .fontColor(Color.White)
          .width('100%')
          .backgroundColor('#008000')
          .padding(14)
          .borderRadius(10)
      }



    }
    .padding({left:24, right: 24})
    .width('100%')
    .height('100%')
    .backgroundColor('')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)

  }
}