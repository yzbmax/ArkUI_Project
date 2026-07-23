@Entry
@Component
struct Index {

  @State user:string = ''
  @State pass:string = ''
  @State accepted:boolean = false
  @State role: string = ''
  @State message:string = '请检查账号、密码长度和用户协议'

  private canSubmit():boolean {
		return this.user.length >= 4 && this.pass.length >= 6 && this.accepted;
	}
  private submit(): void {
    if (!this.canSubmit()) {
      this.message = '请检查账号、密码长度和用户协议'
      return;
    }
    this.message = `账号${this.user}密码${this.pass}`
  }
  build() {
    Column({space : 18}) {
      Text('登录页面')
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
      TextInput({text: this.user,placeholder : '用户名不少于4位'})
        .height(48)
        .shadow({
          radius: 30,
          offsetY: 30,
          offsetX: 20,
          color: "#cacaca"
        })
        .onChange((value: string)=>{
          this.user = value
        })
      TextInput({text: this.pass,placeholder: '密码不少于6位'})
        .type(InputType.Password)
        .height(48)
        .shadow({
          radius: 20,
          offsetY: 20,
          offsetX: 20,
          color: "#cacaca"
        })
        .onChange((value: string)=> {
          this.pass = value
        })
      Row({space: 18}){
        Text('身份')
          .fontSize(16)
        Select([{value:'学生'},{value:'老师'}])
          .value('学生')
          .shadow({
            radius: 30,
            offsetY: 30,
            offsetX: 20,
            color: "#dadada"
          })
      }
      .width('100%')
      Row({space : 10}){
        Checkbox()
          .width(18)
          .select(this.accepted)
          .onChange((value: boolean)=> {
            this.accepted = value
        })
        Text('已阅读并同意霸王条款')
          .fontSize(14)
          .fontColor('#999')
      }
      .width('100%')


      Button('登录')
        .width('100%')
        .height(48)
        .fontWeight(900)
        .fontSize(20)
        .shadow({
          radius: 30,
          offsetY: 30,
          offsetX: 20,
          color: "#cacaca"
        })
        .enabled(this.canSubmit())
        .onClick(()=>{

          this.submit()
        })
      Text(this.message)
        .fontSize(14)
        .fontColor(this.canSubmit() ?"#34D339":'#FF0000') // 报错用红色
        .margin({ top: 10 }) // 和上方按钮留出距离
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .padding({left: 24 , right : 24})
  }
}