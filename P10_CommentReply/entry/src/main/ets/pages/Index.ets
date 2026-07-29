
interface CommentItem {
  id: number;
  author: string;
  content: string;
  liked: boolean;
  publishTime: number;
}
@Entry
@Component
struct Index {
  @State comments: CommentItem[] = [
    { id: 1, author: '小林', content: '状态驱动界面的思路很清晰。', liked: false ,publishTime: Date.now() - 3600000 * 2},
    { id: 2, author: '小周', content: '组件拆分后代码更容易阅读。', liked: true ,publishTime: Date.now() - 86400000},
    { id: 3, author: '小李', content: '测试用例', liked: true ,publishTime: Date.now() - 86400000}
  ];
  @State inputText: string = '';
  nextId: number = this.comments.length + 1;

  formatTime(timestamp: number): string {
    const date = new Date(timestamp);
    const pad = (n: number) => String(n).padStart(2, '0');
    return `${pad(date.getHours())}:${pad(date.getMinutes())}`;
  }
  sendComment() {
    const text = this.inputText.trim();
    if (text === '') {
      return;
    }
    this.comments.push({
      id: this.nextId,
      author: '我',
      content: text,
      liked: false,
      publishTime: Date.now()
    });
    this.nextId++;
    this.inputText = '';
  }
  build() {
    Column() {
      Scroll() {
        Column() {
          ForEach(this.comments, (item: CommentItem) => {
            Column() {
              Text(this.formatTime(item.publishTime))
                .fontSize(12)
                .fontColor('#999')
              Row({ space: 12 }) {
                Text(item.liked ? '❤️' : '🤍')
                  .margin(0)
                  .height(30)
                  .padding(0)
                  .onClick(() => {
                    item.liked = !item.liked;
                  })
                Text(item.content)
                  .fontSize(15)
                  .margin({ top: 6, bottom: 8 })
                  .backgroundColor('#94EC69')
                  .borderRadius(5)
                  .padding({ left: 8, right: 8, top: 11, bottom: 11 })
                Text(item.author)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#fff')
                  .width('120px')
                  .height('120px')
                  .borderRadius(5)
                  .backgroundColor('#3f5d95')
                  .textAlign(TextAlign.Center)
              }
              .justifyContent(FlexAlign.End)
              .width('100%')
              .margin({ top: 15 })
            }
            .margin({ bottom: 10 })
            .borderRadius(8)
          }, (item: CommentItem) => item.id.toString())
        }
        .padding(24)
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.End)
      }
      .layoutWeight(1)
      .width('100%')

      Row() {
        TextInput({ placeholder: '发送评论...', text: this.inputText })
          .onChange((value: string) => {
            this.inputText = value;
          })
          .layoutWeight(1)
          .height(36)
          .backgroundColor('#fff')
          .borderRadius(5)
          .padding({ left: 14, right: 14 })
        Button('发送')
          .onClick(() => this.sendComment())
          .enabled(this.inputText.trim() !== '')
          .height(36)
          .borderRadius(5)
          .backgroundColor('#07C160')
          .fontColor('#fff')
          .margin({ left: 10 })
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor('#f7f7f7')
      .borderWidth({ top: 1 })
      .borderColor('#e6e6e6')
    }
    .width('100%')
    .height('100%')
  }
}