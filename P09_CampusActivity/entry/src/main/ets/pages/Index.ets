@Entry
@Component
struct Index {
  private banners: string[] = ['轮播图1','轮播图2','轮播图3']
  private imageNames: string[] = [
    'img1.jpg',
    'img2.jpg',
    'img3.jpg'
  ];
  @State joined: boolean = false
  textTimerController: TextTimerController = new TextTimerController()
  onPageShow() {
    this.textTimerController.start()
  }
  build() {
    Column(){
      Swiper() {
        ForEach(this.imageNames, (name: string) => {
            Image($rawfile(name))
              .width('100%')
              .height('100%')
              .objectFit(ImageFit.Cover)
          },
          (name: string) => name)
      }
        .autoPlay(true)
        .loop(true)
        .indicator(true)
        .width('100%')
        .height(220)
        .backgroundColor('#efefef')
      Column({space: 18}){
        Text('标题')
          .width('100%')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
        Text('距离报名结束还有')
          .fontSize(16)
          .lineHeight(26)
          .fontColor('#475467')
        TextTimer({
          isCountDown: true,
          count: 360000,
          controller: this.textTimerController
        })
          .format('HH:mm:ss')
          .fontSize(32)
          .fontColor(Color.Red)
        Button(this.joined ? "取消报名":'立即报名')
          .backgroundColor(this.joined ? '#ff0000' : '#5588ff')
          .onClick(()=>{
          this.joined = !this.joined
        })

      }
      .width('100%')
      .padding(24)


    }
  }
}