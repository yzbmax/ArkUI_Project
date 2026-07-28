interface Course {
  id: number
  title: string
  teacher: string
  progress: number
  status: string
}

@Entry
@Component
struct Index {
  private courses: Course[] = [
    {
      id: 1,
      title: 'ArkUI 基础',
      teacher: '李老师',
      progress: 35,
      status: '学习中'
    },
    {
      id: 2,
      title: '状态与事件',
      teacher: '王老师',
      progress: 10,
      status: '待学习'
    },
    {
      id: 3,
      title: '列表渲染',
      teacher: '陈老师',
      progress: 0,
      status: '未开始'
    }
  ]

  build() {
    Column() {
      ForEach(this.courses, (course: Course) => {
        Row() {
          Column() {
            Text(course.title)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
            Text(course.teacher)
              .fontSize(14)
              .fontColor('#999999')
          }
          .alignItems(HorizontalAlign.Start)

          Blank()

          Column() {
            Text(course.status)
              .fontSize(14)
              .fontColor('#666666')
            Text(`${course.progress}%`)
              .fontSize(14)
              .fontColor('#3399FF')
          }
          .alignItems(HorizontalAlign.End)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .padding(16)
        .borderRadius(12)
        .backgroundColor('#FFFFFF')
        .margin({ bottom: 12 })
        .shadow({
          radius: 12,
          color: "#1A000000", // 半透明黑色
          offsetX: 0,
          offsetY: 4
        })
      }, (course: Course) => course.id.toString())
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#F5F5F5')
  }
}