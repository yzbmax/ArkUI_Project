@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  @State liked: boolean = false;

  build() {
    Column({space:18}){
      Column({space:18}){
        Row({space: 18}){
          Stack({ alignContent: Alignment.BottomEnd }){
            Text('罗')
              .fontSize(48)
              .padding(18)
              .borderRadius('26')
              .width(90)
              .height(90)
              .textAlign(TextAlign.Center)
              .backgroundColor('#083344')
              .fontColor('#fff')
              .fontWeight(900)
            Text('ArkUI')
              .fontColor('#fff')
              .backgroundColor('#0891B2')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .borderRadius(10)
              .fontSize(12)
              .fontWeight(900)
          }
          Column({space: 10}){
            Text('罗欣童')
              .fontSize(26)
              .fontFamily('HarmonyOS Sans')
              .fontWeight(900)
            Text('正在学习用声明式UI构建清晰')
              .fontSize(13.5)
              .fontColor('#667085')
              .lineHeight(24)
              .fontWeight(FontWeight.Bold)
          }
          .alignItems(HorizontalAlign.Start)
        }
        Text('大数据技术专业· ArkUI 初学者')
          .fontSize(13.5)
          .fontColor('#667085')
          .lineHeight(24)
          .fontWeight(FontWeight.Bold)
        Row({space : 25}){
          Tag({text: 'UI设计'})
          Tag({text: 'UI布局'})
          Tag({text: 'UI制作'})

        }
        Button(this.liked ? '为我点赞' : '感谢点赞')
          .borderRadius(8)
          .width('100%')
          .padding({top:15 ,bottom: 15})
          .backgroundColor(this.liked ? '#0891B2' : '#B22222')
          .fontWeight(900)
          .fontSize(25)
          .onClick(()=>{
            this.liked = !this.liked
          })
      }
      .alignItems(HorizontalAlign.Start)
      .backgroundColor('#FaFaFa')
      .borderRadius(20)
      .border({ width: 2, color: '#F5F5F5' })
      .padding({top : 30 , bottom : 30, left : 15 , right : 15})
    }
    .width('100%')
    .height('100%')
    .backgroundColor('')
    .justifyContent(FlexAlign.Center) // 垂直方向整体居中
    .alignItems(HorizontalAlign.Center) // 水平方向整体居中
  }


}



@Component
  struct Tag{
    text:string = ''
    build() {
      Text(this.text)
        .fontSize(16)
        .fontColor('#fff')
        .backgroundColor('#155E75')
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .borderRadius(6)
        .fontWeight(900)

    }
}