@Entry
@Component
struct Index {
  @State current: number = 0;

  build() {
    Tabs({ barPosition: BarPosition.End, index: this.current }) {
      TabContent() {
        HomePanel()
      }
      .tabBar('首页');

      TabContent() {
        CoursePanel()
      }
      .tabBar('课程');

      TabContent() {
        MinePanel()
      }
      .tabBar('我的')
    }
    .onChange((index: number) => {
      this.current = index;
    })
    .width('100%')
    .height('100%')
  }
}

@Component
struct HomePanel {
  build() {
    Scroll() {
      Column({ space: 16 }) {
        Text('学习成长日志')
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .width('100%')
        Column({ space: 10 }) {
          Text('今日计划')
            .fontSize(16)
            .fontColor('#D6FFF0')
          Text('ArkUI P08 09 10 11项目')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .width('100%')
        .padding(22)
        .borderRadius(20)
        .backgroundColor('#16B981')


      }
      .padding(20)
    }
  }
}

@Component
struct QuickCard {
  icon: string = '';
  title: string = '';

  build() {
    Column({ space: 8 }) {
      Text(this.icon)
        .fontSize(32)

      Text(this.title)
        .fontSize(14)
    }
    .layoutWeight(1)
    .padding(14)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}

@Component
struct CoursePanel {
  build() {
    Column({ space: 14 }) {
      Text('我的课程')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      ForEach(['移动应用开发', 'HarmonyOS 基础', '前端工程实践'], (x: string, index: number) => {
        Row() {
          Text(`${index + 1}`)
            .width(40)
            .height(40)
            .textAlign(TextAlign.Center)
            .borderRadius(12)
            .backgroundColor('#D6FBEE')

          Text(x)
            .fontSize(17)
            .margin({ left: 12 })
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor(Color.White)
      }, (x: string) => x)
    }
    .padding(20)
    .backgroundColor('#F2FBF7')
  }
}


@Component
struct MinePanel {
  @State notice: boolean = true;

  build() {
    Column({ space: 16 }) {
      Text('个人中心')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      Text('罗欣童')
        .fontSize(18)
        .width('100%')

      Divider()

      Row() {
        Text('学习提醒')
        Blank()
        Toggle({ type: ToggleType.Switch, isOn: this.notice })
          .onChange((v: boolean) => {
            this.notice = v;
          })
      }
      .width('100%')
      .padding(16)
      .borderRadius(16)
      .backgroundColor(Color.White)

      Text('综合项目继续扩展：页面导航、活动详情、购物车和评论模块。')
        .fontSize(15)
        .lineHeight(24)
        .fontColor('#667085')
    }
    .padding(20)
    .backgroundColor('#F2FBF7')
    .height('100%')
  }
}
