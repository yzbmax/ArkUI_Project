
@Observed
class CartItem {
  id: number;
  name: string;
  price: number;
  count: number;
  selected: boolean;

  constructor(id: number, name: string, price: number, count: number, selected: boolean) {
    this.id = id;
    this.name = name;
    this.price = price;
    this.count = count;
    this.selected = selected;
  }
}

@Entry
@Component
struct Index {
  @State items: CartItem[] = [
    new CartItem(1, '商品1', 35, 0, true),
    new CartItem(2, '商品2', 59, 0, false),
    new CartItem(3, '商品3', 46, 0, false)
  ];

  private changeCount(id: number, delta: number): void {
    const target = this.items.find((item: CartItem) => item.id === id);
    if (target) {
      target.count = Math.max(0, target.count + delta);
    }
    this.items = [...this.items];
  }

  private setSelected(id: number, v: boolean): void {
    const target = this.items.find((item: CartItem) => item.id === id);
    if (target) {
      target.selected = v;
    }
    this.items = [...this.items];
  }

  private allSelected(): boolean {
    return this.items.length > 0 && this.items.every((x: CartItem) => x.selected);
  }

  private setAll(v: boolean): void {
    this.items.forEach((item: CartItem) => { item.selected = v; });
    this.items = [...this.items];
  }


  private total(): number {
    return this.items
      .filter((x: CartItem) => x.selected)
      .reduce((sum: number, x: CartItem) => sum + x.price * x.count, 0);
  }

  build() {
    Column() {
      List({ space: 12 }) {
        ForEach(this.items, (item: CartItem) => {
          ListItem() {
            CartRow({
              item: item,
              onSelect: (id: number, v: boolean) => this.setSelected(id, v),
              onCount: (id: number, d: number) => this.changeCount(id, d)
            })
          }
        }, (item: CartItem) => item.id.toString())
      }
      .width('100%')
      .height('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })

      Row({ space: 10 }) {
        Checkbox()
          .select(this.allSelected())
          .onChange((v: boolean) => this.setAll(v))
        Text('全选')

        Blank()
        Text(`合计 ¥${this.total()}`)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
      .padding(16)
      .backgroundColor(Color.White)
    }
    .width('100%')
    .height('100%')
    .padding(2)
    .backgroundColor('#eee')
  }
}


@Component
struct CartRow {
  @ObjectLink item: CartItem;
  onSelect: (id: number, v: boolean) => void = () => {};
  onCount: (id: number, d: number) => void = () => {};

  build() {
    Row({ space: 12 }) {
      Checkbox()
        .select(this.item.selected)
        .onChange((v: boolean) => this.onSelect(this.item.id, v))

      Column({ space: 8 }) {
        Text(this.item.name)
          .fontSize(17)
          .fontWeight(FontWeight.Medium)

        Text(`¥${this.item.price.toFixed(2)}`)
          .fontColor('#E5484D')

        Row({ space: 10 }) {
          Button('-')
            .onClick(() => this.onCount(this.item.id, -1))
          Text(this.item.count.toString())
            .width(28)
            .textAlign(TextAlign.Center)
          Button('+')
            .onClick(() => this.onCount(this.item.id, 1))
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .padding(16)
    .borderRadius(16)
    .backgroundColor(Color.White)
  }
}
