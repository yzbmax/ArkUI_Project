/**
 * 粒子引擎（性能优化版）
 * - 预计算颜色分量，避免每帧 per-particle parseInt
 * - 移除 per-particle shadow（极耗性能）
 * - 降低帧率至 30fps
 * - 简化渲染路径
 */
import { Particle, ParticleType } from '../model/CardData';

interface TouchPoint {
  x: number;
  y: number;
}

export interface ParticleEngineParams {
  particleCount?: number;
  baseSpeed?: number;
  gravityDirection?: number;
  baseOpacity?: number;
  particleType?: ParticleType;
  particleColor?: string;
  primaryColor?: string;
  activityLevel?: number;
}

export class ParticleEngine {
  particles: Particle[] = [];
  private canvasWidth: number = 360;
  private canvasHeight: number = 780;
  private animIntervalId: number = -1;
  private currentTime: number = 0;
  private lastTime: number = 0;
  private frameCount: number = 0;

  particleCount: number = 120; // 降低默认数量
  baseSpeed: number = 0.8;
  gravityDirection: number = 0;
  baseOpacity: number = 0.6;
  particleType: ParticleType = ParticleType.CIRCLE;
  particleColor: string = '#ffffff';
  primaryColor: string = '#4a90d9';
  activityLevel: number = 1.0;

  // 预计算的颜色分量
  private colorR: number = 255;
  private colorG: number = 255;
  private colorB: number = 255;
  private glowR: number = 178;
  private glowG: number = 178;
  private glowB: number = 178;

  // 触摸交互
  private touchPoint: TouchPoint | null = null;
  private touchRecoveryTimer: number = 0;

  initParticles(width: number, height: number, count: number): void {
    this.canvasWidth = width;
    this.canvasHeight = height;
    this.particleCount = Math.min(count, 120); // 上限 120
    this.particles = [];
    for (let i = 0; i < this.particleCount; i++) {
      this.particles.push(this.createParticle());
    }
  }

  private createParticle(): Particle {
    const x: number = Math.random() * this.canvasWidth;
    const y: number = Math.random() * this.canvasHeight;
    const life: number = 0.3 + Math.random() * 1.2;
    return {
      x: x,
      y: y,
      baseX: x,
      baseY: y,
      vx: (Math.random() - 0.5) * this.baseSpeed * 2,
      vy: (Math.random() - 0.5) * this.baseSpeed * 2,
      radius: 1 + Math.random() * 3,
      opacity: 0.3 + Math.random() * 0.7,
      life: life,
      phase: Math.random() * Math.PI * 2,
      type: this.particleType,
      color: this.particleColor
    };
  }

  updateParams(params: ParticleEngineParams): void {
    if (params.particleCount !== undefined) {
      this.particleCount = Math.min(params.particleCount, 120);
    }
    if (params.baseSpeed !== undefined) this.baseSpeed = params.baseSpeed;
    if (params.gravityDirection !== undefined) this.gravityDirection = params.gravityDirection;
    if (params.baseOpacity !== undefined) this.baseOpacity = params.baseOpacity;
    if (params.particleType !== undefined) this.particleType = params.particleType;
    if (params.particleColor !== undefined) {
      this.particleColor = params.particleColor;
      this.precomputeColor();
    }
    if (params.primaryColor !== undefined) this.primaryColor = params.primaryColor;
    if (params.activityLevel !== undefined) this.activityLevel = params.activityLevel;

    const targetCount: number = Math.round(this.particleCount * (0.6 + 0.4 * this.activityLevel));
    while (this.particles.length < targetCount) {
      this.particles.push(this.createParticle());
    }
    while (this.particles.length > targetCount) {
      this.particles.pop();
    }
  }

  setTouchPoint(x: number, y: number): void {
    const tp: TouchPoint = { x: x, y: y };
    this.touchPoint = tp;
    this.touchRecoveryTimer = 0;
  }

  private precomputeColor(): void {
    const hx: string = this.particleColor.replace('#', '');
    this.colorR = parseInt(hx.substring(0, 2), 16);
    this.colorG = parseInt(hx.substring(2, 4), 16);
    this.colorB = parseInt(hx.substring(4, 6), 16);
    this.glowR = Math.round(this.colorR * 0.7);
    this.glowG = Math.round(this.colorG * 0.7);
    this.glowB = Math.round(this.colorB * 0.7);
  }

  // -- 动画循环 --

  startAnimation(context: CanvasRenderingContext2D): void {
    this.precomputeColor();
    this.lastTime = Date.now();
    // 使用 33ms ≈ 30fps，足够流畅且节省一半计算
    this.animIntervalId = setInterval(() => {
      const now: number = Date.now();
      const rawDt: number = now - this.lastTime;
      // 防止跳帧：dt 最大 50ms
      const dt: number = Math.min(rawDt, 50) / 16.667;
      this.lastTime = now;
      this.currentTime = now;
      this.frameCount++;

      this.update(dt);
      this.render(context);
    }, 33);
  }

  stopAnimation(): void {
    if (this.animIntervalId !== -1) {
      clearInterval(this.animIntervalId);
      this.animIntervalId = -1;
    }
  }

  // -- 物理更新 --

  private update(dt: number): void {
    const gx: number = Math.cos(this.gravityDirection * Math.PI / 180) * 0.02 * dt;
    const gy: number = Math.sin(this.gravityDirection * Math.PI / 180) * 0.02 * dt;
    const speed: number = this.baseSpeed * this.activityLevel;

    for (let i: number = 0; i < this.particles.length; i++) {
      const p: Particle = this.particles[i];
      p.life -= 0.0003 * dt;
      if (p.life <= 0) {
        this.resetParticle(p);
        continue;
      }

      p.vx += (Math.random() - 0.5) * 0.15 * dt + gx;
      p.vy += (Math.random() - 0.5) * 0.15 * dt + gy;

      const maxV: number = speed * 1.5;
      const vLen: number = Math.sqrt(p.vx * p.vx + p.vy * p.vy);
      if (vLen > maxV) {
        p.vx = (p.vx / vLen) * maxV;
        p.vy = (p.vy / vLen) * maxV;
      }

      if (this.touchPoint) {
        const dx: number = p.x - this.touchPoint.x;
        const dy: number = p.y - this.touchPoint.y;
        const dist: number = Math.sqrt(dx * dx + dy * dy);
        if (dist < 120) {
          const force: number = (1 - dist / 120) * 2.5 * dt;
          p.vx += (dx / dist) * force;
          p.vy += (dy / dist) * force;
        }
      }

      p.x += p.vx;
      p.y += p.vy;

      // 循环边界
      if (p.x < -20) p.x = this.canvasWidth + 20;
      if (p.x > this.canvasWidth + 20) p.x = -20;
      if (p.y < -20) p.y = this.canvasHeight + 20;
      if (p.y > this.canvasHeight + 20) p.y = -20;

      if (!this.touchPoint && this.touchRecoveryTimer <= 0) {
        p.baseX = p.x;
        p.baseY = p.y;
      }
    }

    if (this.touchPoint) {
      this.touchRecoveryTimer += dt;
      if (this.touchRecoveryTimer > 60) {
        this.touchPoint = null;
      }
    }
  }

  private resetParticle(p: Particle): void {
    p.x = Math.random() * this.canvasWidth;
    p.y = Math.random() * this.canvasHeight;
    p.vx = (Math.random() - 0.5) * this.baseSpeed * 2;
    p.vy = (Math.random() - 0.5) * this.baseSpeed * 2;
    p.life = 0.5 + Math.random() * 1.0;
    p.phase = Math.random() * Math.PI * 2;
    p.baseX = p.x;
    p.baseY = p.y;
  }

  // -- 渲染（性能关键路径） --

  private render(context: CanvasRenderingContext2D): void {
    // 使用半透明清除实现拖尾效果，减少 fillRect 调用
    context.clearRect(0, 0, this.canvasWidth, this.canvasHeight);

    const count: number = this.particles.length;
    // 小批量先画，避免过多 save/restore
    context.save();

    for (let i: number = 0; i < count; i++) {
      const p: Particle = this.particles[i];

      // 跳过屏幕外或几乎透明的粒子
      if (p.x < -20 || p.x > this.canvasWidth + 20 ||
          p.y < -20 || p.y > this.canvasHeight + 20) {
        continue;
      }

      let lifeOpacity: number = 1;
      if (p.life < 0.15) {
        lifeOpacity = p.life / 0.15;
      } else if (p.life > 1.2) {
        lifeOpacity = (1.5 - p.life) / 0.3;
      }

      const alpha: number = Math.max(0.03, p.opacity * lifeOpacity * this.baseOpacity);
      if (alpha < 0.03) continue;

      context.globalAlpha = alpha;
      // 无 per-particle shadow — 这是最大的性能提升
      context.shadowBlur = 0;

      switch (p.type) {
        case ParticleType.CIRCLE:
          // 用 fillRect 替代 arc 加速（小圆点视觉差别极小）
          const size: number = p.radius * 2;
          context.fillStyle = p.color;
          context.fillRect(p.x - p.radius, p.y - p.radius, size, size);
          break;

        case ParticleType.LINE:
          context.strokeStyle = p.color;
          context.lineWidth = Math.max(0.5, p.radius * 0.6);
          context.beginPath();
          context.moveTo(p.x, p.y);
          context.lineTo(p.x + p.vx * 3, p.y + p.vy * 3);
          context.stroke();
          break;

        case ParticleType.DROP:
          context.fillStyle = p.color;
          context.fillRect(p.x - 1, p.y - p.radius * 2, 2, p.radius * 3);
          break;

        case ParticleType.HEXAGON:
          this.drawHexagon(context, p.x, p.y, p.radius, p.color);
          break;

        default:
          context.fillStyle = p.color;
          context.fillRect(p.x - p.radius, p.y - p.radius, p.radius * 2, p.radius * 2);
      }
    }

    context.restore();
  }

  private drawHexagon(context: CanvasRenderingContext2D, cx: number, cy: number, r: number, color: string): void {
    context.fillStyle = color;
    context.beginPath();
    for (let i: number = 0; i < 6; i++) {
      const angle: number = (Math.PI / 3) * i - Math.PI / 6;
      const x: number = cx + r * Math.cos(angle);
      const y: number = cy + r * Math.sin(angle);
      if (i === 0) {
        context.moveTo(x, y);
      } else {
        context.lineTo(x, y);
      }
    }
    context.closePath();
    context.fill();
  }
}
