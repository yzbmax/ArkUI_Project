@Entry
@Component
struct Index {
  @State heightCm: number = 170
  @State weightKg: number = 60
  @State fcolor: string = ''
  //BMI 公式：体重 kg / 身高 m 的平方
  private BMI():number {
    if (this.heightCm === 0) {
      return 0
    }
    const heightM = this.heightCm / 100
    return this.weightKg / (heightM * heightM)
  }

  private texts():string {
    const value = this.BMI();
    if (isNaN(this.weightKg) || isNaN(this.heightCm) || this.weightKg <= 0 || this.heightCm <= 0) {
      return '请输入正确的身高体重';
    }
    if (value < 18.5) {
      this.fcolor = '#F37A22'
      return '偏轻';
    }
    if (value < 24) {
      this.fcolor = '#4D8C51'
      return '正常';
    }
    if (value < 28) {
      this.fcolor = '#F37A22'
      return '偏重';
    }
    this.fcolor = '#682704'
    return '肥胖';
  }

  build() {
    Column({space : 18}){
      Text('BMI计算器')
        .fontSize(32)
      Column(){
        Text('身高：')
          .fontSize(22)
        TextInput({placeholder: String(this.heightCm)})
          .onChange((v:string)=>{
            this.heightCm = Number(v)
          })
      }
      Column(){
        Text('体重：')
          .fontSize(22)
        TextInput({placeholder: String(this.weightKg)})
          .onChange((v:string)=>{
            this.weightKg = Number(v)
          })
      }
      Text(this.texts())
      Text(this.BMI().toFixed(1))
        .fontSize(30)
        .fontColor(this.fcolor)
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .height('100%')
    .padding({left: 24 , right : 24})
  }
}