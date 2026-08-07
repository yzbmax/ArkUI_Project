import { ThemeManager } from '../utils/ThemeManager';

/**
 * PriceSparkline.ets
 * 迷你价格走势图（Canvas 折线，暖色调，纯曲线无网格）
 */
@Component
export struct PriceSparkline {
  @Prop points: Array<number> = [];
  @Prop chartWidth: number = 120;
  @Prop chartHeight: number = 40;
  @Prop strokeColor: string = ThemeManager.accent();
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private ctx: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);

  private draw(): void {
    if (this.points.length < 2) {
      return;
    }
    const ctx = this.ctx;
    ctx.clearRect(0, 0, this.chartWidth, this.chartHeight);

    let min = this.points[0];
    let max = this.points[0];
    for (let i = 1; i < this.points.length; i++) {
      if (this.points[i] < min) {
        min = this.points[i];
      }
      if (this.points[i] > max) {
        max = this.points[i];
      }
    }
    const range = max - min;
    const padding = 3;
    const stepX = (this.chartWidth - padding * 2) / (this.points.length - 1);

    const toY = (v: number): number => {
      if (range === 0) {
        return this.chartHeight / 2;
      }
      return padding + (1 - (v - min) / range) * (this.chartHeight - padding * 2);
    };

    const first = this.points[0];
    const last = this.points[this.points.length - 1];
    const trendDown = last <= first;
    const color = trendDown ? this.strokeColor : ThemeManager.rise();

    const grad = ctx.createLinearGradient(0, 0, 0, this.chartHeight);
    grad.addColorStop(0, trendDown ? 'rgba(201,100,66,0.25)' : 'rgba(181,51,51,0.20)');
    grad.addColorStop(1, 'rgba(201,100,66,0.0)');

    ctx.beginPath();
    ctx.moveTo(padding, toY(this.points[0]));
    for (let i = 1; i < this.points.length; i++) {
      ctx.lineTo(padding + i * stepX, toY(this.points[i]));
    }
    ctx.lineTo(padding + (this.points.length - 1) * stepX, this.chartHeight);
    ctx.lineTo(padding, this.chartHeight);
    ctx.closePath();
    ctx.fillStyle = grad;
    ctx.fill();

    ctx.beginPath();
    ctx.moveTo(padding, toY(this.points[0]));
    for (let i = 1; i < this.points.length; i++) {
      ctx.lineTo(padding + i * stepX, toY(this.points[i]));
    }
    ctx.strokeStyle = color;
    ctx.lineWidth = 1.8;
    ctx.lineJoin = 'round';
    ctx.lineCap = 'round';
    ctx.stroke();

    ctx.beginPath();
    ctx.arc(padding + (this.points.length - 1) * stepX, toY(last), 2.6, 0, Math.PI * 2);
    ctx.fillStyle = color;
    ctx.fill();
  }

  build() {
    Canvas(this.ctx)
      .width(this.chartWidth)
      .height(this.chartHeight)
      .onReady(() => this.draw())
  }
}
