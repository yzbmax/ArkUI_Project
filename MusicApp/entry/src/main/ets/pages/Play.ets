/**
 * 播放页（F07 核心）
 * 唱片旋转动画 + 唱针摆动 + 进度 Slider + 播放/暂停 + 上下曲 + 模式三态切换
 * + 播放列表面板（左滑删除）。状态来自 AppStorage(SONG_KEY)，与 Mini-Bar / 锁屏共享。
 */
import { router } from '@kit.ArkUI';
import { Colors, Font, Radius, Space, Shadow } from '../theme/AppTheme';
import { PlayState, SongItemType, LyricLine } from '../models/index';
import { SONG_KEY } from '../contants/index';
import { AVPlayerManager } from '../utils/AVPlayerManager';
import { AVSessionManager } from '../utils/AVSessionManager';
import { formatTime } from '../utils/format';
import { CoverImage, IconSlot } from '../components/common';

@Entry
@Component
struct Play {
  // 全局播放状态（与 Mini-Bar / 锁屏共享）
  @Watch('onStateChange') @StorageLink(SONG_KEY) playState: PlayState = new PlayState();
  @State panelShow: boolean = false; // 播放列表面板是否展开
  @State showLyric: boolean = false; // 中部是否显示歌词（false=封面，true=歌词）
  @State lyricIndex: number = -1;    // 当前高亮歌词行
  private player: AVPlayerManager = AVPlayerManager.getInstance();
  private lyricScroller: Scroller = new Scroller(); // 歌词滚动控制器

  // 播放状态变化：同步锁屏
  onStateChange(): void {
    AVSessionManager.getInstance().update(this.playState);
    this.syncLyric();
  }

  // 根据当前播放进度，计算并高亮当前歌词行；切行时滚动到居中
  syncLyric(): void {
    const lines: LyricLine[] = this.playState.lyricLines;
    if (!lines || lines.length === 0) {
      this.lyricIndex = -1;
      return;
    }
    const t = this.playState.time;
    let idx = 0;
    for (let i = 0; i < lines.length; i++) {
      if (t >= lines[i].time) {
        idx = i;
      } else {
        break;
      }
    }
    if (idx !== this.lyricIndex) {
      this.lyricIndex = idx;
      // 滚动使当前行居中（行高约为 32vp）
      this.lyricScroller.scrollTo({ xOffset: 0, yOffset: Math.max(0, idx * 32 - 60), animation: true });
    }
  }

  aboutToAppear(): void {
    AVSessionManager.getInstance().update(this.playState);
  }

  // 播放模式图标：随机用 shuffle，单曲用 repeat-one，顺序用 repeat
  private modeIcon(): Resource {
    if (this.playState.playMode === 'random') {
      return $r('app.media.arrows_shuffle_2');
    } else if (this.playState.playMode === 'repeat') {
      return $r('app.media.repeat_one');
    }
    return $r('app.media.repeat');
  }

  // 左滑删除按钮
  @Builder deleteBuilder(index: number) {
    Button('删除')
      .backgroundColor(Colors.negative)
      .fontColor(Colors.textPrimary)
      .height('100%')
      .onClick(() => {
        this.player.removeFromList(index);
      })
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      // 主内容（固定布局，不滚动）
      Column() {
        // 顶部栏：返回 + 标题 + 菜单（对齐规范，透明图标）
        Row() {
          IconSlot({ iconSize: 28, icon: $r('app.media.arrow_left'), label: '', bg: Colors.transparent })
            .onClick(() => {
              router.back();
            })
          Text('正在播放')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(Font.head)
            .fontColor(Colors.textPrimary)
            .fontWeight(FontWeight.Medium)
          IconSlot({ iconSize: 28, icon: $r('app.media.list'), label: '', bg: Colors.transparent })
            .onClick(() => {
              this.panelShow = !this.panelShow;
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .padding({ top: Space.lg, bottom: Space.xl })

        // 歌曲信息：歌名大号白粗、歌手浅灰中号（层级拉开）
        Text(this.playState.title)
          .fontSize(Font.title)
          .fontWeight(FontWeight.Bold)
          .fontColor(Colors.textPrimary)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.playState.artist)
          .margin({ top: Space.sm })
          .fontSize(Font.body)
          .fontColor(Colors.textSecondary)

        // 中部弹性区：封面与歌词二选一（点击封面切换为歌词，点击歌词切回封面）
        Column() {
          if (this.showLyric) {
            // 歌词视图：当前行高亮（品牌绿 + 加粗）
            if (this.playState.lyricLines.length > 0) {
              Column() {
                // 顶部切换提示：点击返回封面
                Text('▾ 封面')
                  .fontSize(Font.caption)
                  .fontColor(Colors.textSecondary)
                  .width('100%')
                  .textAlign(TextAlign.Center)
                  .padding({ bottom: Space.sm })
                  .onClick(() => {
                    this.showLyric = false;
                  })
                Scroll(this.lyricScroller) {
                  Column({ space: 8 }) {
                    ForEach(
                      this.playState.lyricLines,
                      (line: LyricLine, index: number) => {
                        Text(line.text)
                          .width('100%')
                          .textAlign(TextAlign.Center)
                          .fontSize(index === this.lyricIndex ? Font.body : Font.caption)
                          .fontWeight(index === this.lyricIndex ? FontWeight.Bold : FontWeight.Regular)
                          .fontColor(index === this.lyricIndex ? Colors.accent : Colors.textSecondary)
                          .opacity(index === this.lyricIndex ? 1 : 0.6)
                          .onClick(() => {
                            this.player.seek(line.time);
                          })
                      },
                      (_line: LyricLine, index: number) => 'lyric_' + index
                    )
                  }
                  .width('100%')
                  .padding({ top: 20, bottom: 20 })
                }
                .width('100%')
                .layoutWeight(1)
                .scrollBar(BarState.Off)
              }
              .width('100%')
              .height('100%')
            } else {
              // 无歌词：提示点击返回封面
              Column() {
                Text('暂无歌词')
                  .fontSize(Font.caption)
                  .fontColor(Colors.textSecondary)
                  .width('100%')
                  .textAlign(TextAlign.Center)
                Text('▾ 封面')
                  .fontSize(Font.caption)
                  .fontColor(Colors.textSecondary)
                  .margin({ top: Space.md })
                  .onClick(() => {
                    this.showLyric = false;
                  })
              }
              .width('100%')
              .height('100%')
              .justifyContent(FlexAlign.Center)
            }
          } else {
            // 封面视图：点击切换到歌词
            CoverImage({
              color: this.playState.color,
              radius: Radius.card,
              img: this.playState.img,
              text: this.playState.title.length > 0 ? this.playState.title.charAt(0) : '',
            })
              .width('70%')
              .aspectRatio(1)
              .borderRadius(Radius.card)
              .shadow(Shadow.heavy)
              .onClick(() => {
                if (this.playState.lyricLines.length > 0) {
                  this.showLyric = true;
                }
              })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({ left: Space.xxl, right: Space.xxl, bottom: 160 })
      .backgroundColor(Colors.bg)

      // 播放列表抽屉（从底部弹出，高度降低，位于控件之下，不遮挡控件）
      Column() {
        Row() {
          Row()
            .width(44)
            .height(4)
            .backgroundColor(Colors.surfaceHi)
            .borderRadius(Radius.pill)
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .padding({ top: Space.sm, bottom: Space.xs })
        Text('播放列表')
          .fontSize(Font.head)
          .fontWeight(FontWeight.Medium)
          .fontColor(Colors.textPrimary)
          .alignSelf(ItemAlign.Start)
          .padding({ left: Space.xxl, top: Space.xs, bottom: Space.md })
        List() {
          ForEach(
            this.playState.playList,
            (item: SongItemType, index: number) => {
              ListItem() {
                Row() {
                  CoverImage({ color: item.color, radius: Radius.cover, img: item.img })
                    .width(44)
                    .height(44)
                  Column() {
                    Text(item.title)
                      .fontSize(Font.body)
                      .fontColor(this.playState.playIndex === index ? Colors.accent : Colors.textPrimary)
                      .fontWeight(FontWeight.Medium)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                    Text(item.artist)
                      .margin({ top: 2 })
                      .fontSize(Font.caption)
                      .fontColor(Colors.textSecondary)
                      .maxLines(1)
                      .textOverflow({ overflow: TextOverflow.Ellipsis })
                  }
                  .layoutWeight(1)
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: Space.sm })
                }
                .width('100%')
                .alignItems(VerticalAlign.Center)
                .padding({ top: Space.sm, bottom: Space.sm })
                .onClick(() => {
                  this.player.select(index);
                })
              }
              .swipeAction({
                end: () => {
                  this.deleteBuilder(index);
                },
              })
            },
            (item: SongItemType) => item.id
          )
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: Space.xxl, right: Space.xxl })
      }
      .width('100%')
      .height('45%')
      .backgroundColor(Colors.surface)
      .borderRadius({ topLeft: Radius.card, topRight: Radius.card })
      .translate({ y: this.panelShow ? '55%' : '100%' })
      .zIndex(2)
      .animation({ duration: 300, curve: Curve.Ease })

      // 控件浮层（最上层，进度条 + 控制栏，始终不被播放列表遮挡）
      Column() {
        // 进度条：底深灰、已播品牌绿；时间文字放大
        Row() {
          Text(formatTime(this.playState.time))
            .fontSize(Font.caption)
            .fontColor(Colors.textSecondary)
          Slider({
            value: this.playState.time,
            min: 0,
            max: this.playState.duration > 0 ? this.playState.duration : 1,
            step: 1,
            style: SliderStyle.OutSet,
          })
            .layoutWeight(1)
            .margin({ left: Space.sm, right: Space.sm })
            .blockColor(Colors.accent)
            .selectedColor(Colors.accent)
            .trackColor(Colors.surfaceHi)
            .onChange((value: number) => {
              this.player.seek(value);
            })
          Text(formatTime(this.playState.duration))
            .fontSize(Font.caption)
            .fontColor(Colors.textSecondary)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .margin({ bottom: Space.sm })

        // 控制栏：五键均匀分布；主播放键大号绿圆白图标；模式键选中变绿
        Row() {
          IconSlot({ iconSize: 30, icon: $r('app.media.list'), label: '', bg: Colors.transparent, fg: Colors.textPrimary })
            .onClick(() => {
              this.panelShow = !this.panelShow;
            })
          IconSlot({ iconSize: 30, icon: $r('app.media.player_skip_back'), label: '', bg: Colors.transparent, fg: Colors.textPrimary })
            .onClick(() => {
              this.player.prev();
            })
          IconSlot({
            iconSize: 68,
            icon: this.playState.isPlay ? $r('app.media.player_pause') : $r('app.media.player_play'),
            label: '',
            bg: Colors.accent,
            fg: Colors.textPrimary,
          })
            .onClick(() => {
              this.player.toggle();
            })
          IconSlot({ iconSize: 30, icon: $r('app.media.player_skip_forward'), label: '', bg: Colors.transparent, fg: Colors.textPrimary })
            .onClick(() => {
              this.player.next();
            })
          IconSlot({
            iconSize: 30,
            icon: this.modeIcon(),
            label: '',
            bg: Colors.transparent,
            fg: this.playState.playMode === 'auto' ? Colors.textPrimary : Colors.accent,
          })
            .onClick(() => {
              this.player.switchMode();
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.SpaceEvenly)
        .margin({ bottom: Space.lg })
      }
      .width('100%')
      .padding({ left: Space.xxl, right: Space.xxl, top: Space.lg })
      .backgroundColor(Colors.bg)
      .zIndex(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Colors.bg)
    .padding({ top: 30 })
  }
}
