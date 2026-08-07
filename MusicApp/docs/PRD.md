# 黑马云音乐 App · 产品需求文档（PRD）

> **文档版本**：v1.0  
> **编写日期**：2026-07-30  
> **状态**：评审稿（待开发落地）  
> **设计系统**：`docs/DESIGN.md`（Spotify 暗色沉浸式体系）  
> **目标平台**：HarmonyOS NEXT（Stage 模型，API 26 / 5.0+，ArkTS + ArkUI）

---

## 0. 文档目的与阅读对象

本文档对「黑马云音乐」App 进行**详细需求分析**并给出**可靠的建设方案**，作为后续编码、联调与验收的唯一依据。

- **产品 / 技术负责人**：确认范围、里程碑、验收标准。
- **鸿蒙开发工程师**：依据第 6~10 章的模型、接口、UI 规范与目录结构落地。
- **后端 / 接口提供方**：依据第 7 章「接口设计」提供真实数据。

**关键约束（贯穿全文）**：本期所有页面**使用本地 Mock 数据渲染**，数据访问统一走 `MusicRepository` 接口；真实后端就绪后只需替换实现类，页面与组件**零改动**。

---

## 1. 产品概述

### 1.1 项目背景

「黑马云音乐」是一个鸿蒙原生音乐播放应用，源自 HarmonyOS 教学项目。核心能力覆盖：启动引导、首页多 Tab 内容分发、歌曲播放与播放列表管理、媒体会话（锁屏 / 控制中心）、互动动态分享。本版在保留原有业务能力的前提下，整体 UI 改用 `DESIGN.md` 的 **Spotify 暗色沉浸式设计系统**，并重构数据层为「接口 + Mock 实现」双轨，支撑后续无缝接入真实后端。

### 1.2 产品定位

> 一个**内容优先、暗色沉浸**的轻量音乐播放器：以播放体验为核心，首页分发推荐内容，动态页承载社交互动。

### 1.3 目标用户

- 鸿蒙手机 / 平板用户，喜欢听音乐、关注歌单与音乐动态。
- 对深色模式、沉浸播放体验有偏好的用户。

### 1.4 设计系统落地原则（源自 DESIGN.md）

| 设计语言要素 | 取值 / 规则 | 落地要求 |
|---|---|---|
| 背景 | 近黑 `#121212` / 表面 `#181818` / 中暗 `#1f1f1f` | 页面背景统一用 `Colors.bg`；卡片用 `Colors.surface` |
| 品牌色 | Spotify Green `#1ed760` | 仅用于播放控制、激活态、主 CTA，**禁止**作背景装饰 |
| 文字 | 白色 `#ffffff` / 银色 `#b3b3b3` | 主文字 `Colors.textPrimary`，次要 `Colors.textSecondary` |
| 形状 | 胶囊 500–9999px，圆形 50% | 按钮全胶囊；播放键圆形；搜索框胶囊 |
| 按钮文案 | 大写 + 字距 1.4–2px | 英文标签大写；中文标签保持常规，靠字重区分层级 |
| 阴影 | 重阴影 `rgba(0,0,0,.5) 0 8 24`、卡片 `rgba(0,0,0,.3) 0 8 8` | 弹层/对话框用 `Shadow.heavy`，卡片用 `Shadow.card` |
| 字体 | 紧凑 10–24px，700/400 二元 | 标题 700，正文 400，禁止松弛行高 |
| 强调色（语义） | 负向红 `#f3727f`、警示橙 `#ffa42b`、提示蓝 `#539df5` | 仅用于错误/警示/信息态 |

> ⚠️ 所有颜色、字号、间距、圆角、阴影**不得硬编码 16 进制**，统一从 `entry/src/main/ets/theme/AppTheme.ets` 的 token 取用（详见第 9 章）。

---

## 2. 总体架构与建设方案

### 2.1 技术栈

| 层 | 选型 |
|---|---|
| 语言 / UI | ArkTS（严格模式 `useNormalizedOHMUrl` + `caseSensitiveCheck`）+ ArkUI 声明式 |
| 应用模型 | Stage 模型，`UIAbility` 入口 |
| 媒体 | `@kit.MediaKit`（AVPlayer）、`@kit.AVSessionKit`（媒体会话） |
| 网络 | `@kit.NetworkKit`（http），本期仅定义，由 Mock 实现兜底 |
| 路由 | `@kit.ArkUI` `router` |
| 状态 | `AppStorage`（全局播放状态）+ `@State`（页面/组件局部） |
| 设计系统 | `theme/AppTheme.ets` 集中 token |

### 2.2 分层架构

```
┌───────────────────────────────────────────────┐
│  Pages (Start / Index / Play)                  │  ← 页面入口，仅负责组装
├───────────────────────────────────────────────┤
│  Views (Recommend/Find/Moment/Mine) + Components│  ← 可复用 UI 区块
├───────────────────────────────────────────────┤
│  Services: MusicRepository (interface)         │  ← 数据契约（本期 = Mock 实现）
│           ├─ MockMusicRepository  (本地 mock)   │
│           └─ HttpMusicRepository  (预留·后续接)  │
├───────────────────────────────────────────────┤
│  Models (interface + class)                    │  ← 数据契约定义
├───────────────────────────────────────────────┤
│  Utils: AVPlayerManager / AVSessionManager      │  ← 播放与媒体会话单例
│  Theme: AppTheme (DESIGN.md token)             │
└───────────────────────────────────────────────┘
```

### 2.3 数据流（本期）

```
View.aboutToAppear()
   → musicRepository.getXxx()        // 接口调用，页面不感知数据来源
   → MockMusicRepository 返回本地 mock
   → @State 赋值 → UI 渲染
点击歌曲 → AVPlayerManager.singPlay(song)
   → 更新 AppStorage SONG_KEY(PlayState)
   → Play 页 @StorageLink 监听 → 旋转/进度/控制联动
   → AVSessionManager 同步锁屏
```

### 2.4 状态管理策略

| 状态 | 载体 | 说明 |
|---|---|---|
| 全局播放状态 | `AppStorage.setOrCreate(SONG_KEY, PlayState)` | 播放页/底部 mini-bar 共享 |
| 安全区域 | `AppStorage SAFE_TOP / SAFE_BOTTOM` | EntryAbility 计算后写入 |
| 局部 UI 态 | `@State` | Tab 激活、面板高度、加载中等 |
| 列表渲染 | `ForEach` + `@Builder` | 区块复用 |

### 2.5 为什么「Mock 先行 + 接口预留」

1. **解耦**：页面只依赖 `MusicRepository` 接口，数据来源可替换。
2. **可独立开发**：前端无需等后端，Mock 即可完整跑通 UI 与交互。
3. **平滑切换**：后端就绪后，仅将 `services/index.ets` 中导出的实例从 `MockMusicRepository` 换成 `HttpMusicRepository`，**页面零改动**。
4. **预览友好**：Mock 不依赖网络/系统 API，可在受限环境下调试布局。

---

## 3. 功能需求（详细）

> 编号规则：F = Function。每个功能含「描述 / 输入 / 行为 / 输出 / 验收要点」。

### F01 启动页（Start）
- **描述**：应用冷启动展示品牌页，5 秒倒计时自动进入首页，支持「跳过」。
- **行为**：`aboutToAppear` 启动 `setTimeout(5000)`；点击「跳过」`router.replaceUrl('pages/Index')`；`aboutToDisappear` 清除定时器。
- **UI**：暗色背景 + 居中 Logo（绿色）+ 右上角胶囊「跳过 5s」。
- **验收**：倒计时结束或点击跳过均进入首页；不可返回启动页。

### F02 首页框架与底部导航（Index）
- **描述**：底部 4 个 Tab：推荐 / 发现 / 动态 / 我的，点击切换视图，自定义 TabBar（图标+文字，激活态绿色）。
- **行为**：`@State isActive` 控制当前视图；自定义 `TabBar` 组件接收 `tabData` 与 `isActive`。
- **验收**：4 个 Tab 切换正常；激活态高亮（绿色 + 700 字重）。

### F03 推荐页（Recommend）— F03.1 轮播 / F03.2 每日推荐 / F03.3 推荐歌单
- **F03.1 轮播**：`Swiper` 自动轮播 banner（圆角卡片）。
- **F03.2 每日推荐**：横向滚动卡片行（封面 + 标题 + 类型标签）。
- **F03.3 推荐歌单**：横向滚动歌单卡片（封面 + 标题 + 播放量）。
- **验收**：三个区块独立加载；空数据有占位；点击歌单卡片进入（本期 toast/占位，预留歌单详情）。

### F04 发现页（Find）— 猜你喜欢歌曲列表
- **描述**：`List` 展示歌曲，每项含封面占位、标题、作者；点击 → 跳转播放页并开始播放。
- **行为**：点击 `router.pushUrl('pages/Play')` 并 `AVPlayerManager.singPlay(item)`。
- **验收**：列表渲染正确；点击触发播放并跳转。

### F05 动态页（Moment）— 互动广场
- **描述**：展示用户动态，每条含头像、内容、内嵌歌曲卡片、评论/点赞/分享数（`Badge`）。
- **验收**：嵌套布局正确；点赞数展示；内嵌歌曲卡片可点击播放。

### F06 我的页（Mine）— 个人中心
- **描述**：头像/昵称/VIP/年龄/星座/城市、关注/粉丝数据、收藏封面 `GridRow` 瀑布流。
- **验收**：网格自适应；数据展示完整。

### F07 播放页（Play）— 核心
- **描述**：唱片旋转动画、唱针摆动、进度 `Slider`、播放/暂停、上一首/下一首、播放模式切换（顺序/单曲循环/随机）、播放列表面板（左滑删除）。
- **行为**：`@StorageLink(SONG_KEY)` 监听播放状态；`Animator` 驱动旋转；`Slider.onChange` → `player.seek()`；模式按钮三态切换；面板高度 `0%↔100%` 动画；`ListItem.swipeAction` 删除。
- **验收**：播放/暂停联动；进度实时更新；模式切换生效；列表增删正确。

### F08 媒体会话（AVSessionManager）
- **描述**：锁屏 / 控制中心显示封面、歌名、播放控制（播放/暂停/上下曲/拖拽）。
- **验收**：锁屏可见歌曲信息与控制；与播放状态同步。

### F09 网络数据（预留）
- **描述**：本期由 `MockMusicRepository` 提供；真实接口定义见第 7 章，`HttpMusicRepository` 预留实现。
- **验收**：切换实现类后页面无需改动即可消费真实数据。

### F10 全局播放 Mini-Bar（增强，建议纳入）
- **描述**：首页底部常驻迷你播放条（封面 + 歌名 + 播放/暂停），点击展开播放页。
- **验收**：任意 Tab 下可见；与全局播放态同步。

---

## 4. 非功能性需求

| 类别 | 要求 |
|---|---|
| 性能 | 列表/网格使用 `LazyForEach`（数据量大时）；避免 `build` 内重计算；动画走 `Animator`/`animation` 而非轮询 |
| 内存 | AVPlayer 全局单例，复用不重复创建；页面销毁释放定时器 |
| 兼容 | 支持 phone；按 DESIGN.md 断点做响应式（移动优先，平板 2 列网格） |
| 国际化 | 文案集中 `resources/base/element/string.json`；本期中文 |
| 安全 | 仅声明 `ohos.permission.INTERNET`（联调真实接口时使用）；Mock 阶段不触发网络 |
| 可维护 | 严格 ArkTS：禁用对象展开 `{}`；禁用 `any`；token 不出 `AppTheme` |

---

## 5. 数据模型设计（`models/index.ets`）

```typescript
// Tab 定义
export interface TabType {
  text: string;
  name: string;
  icon: Resource;   // 本期用文字/内置图标替代资源图，避免缺图
}

// 轮播
export interface SwiperType { id: string; img: string; title: string; }

// 每日推荐
export interface DailyRecommendType {
  id: string; img: string; title: string; type: string; top: string; bottom: string;
}

// 推荐歌单
export interface RecommendListType {
  id: string; img: string; title: string; count: string;
}

// 歌曲
export interface SongItemType {
  id: string; img: string; title: string; artist: string; url: string;
  color?: string;   // Mock 视觉占位色（真实数据可忽略）
}

// 动态
export interface MomentListType {
  id: string; author: string; avatar: string; content: string;
  comment: number; like: number; song: SongItemType;
}

// 用户信息
export interface UserType {
  name: string; vip: boolean; age: number; star: string; city: string;
  follow: number; fans: number; avatar: string;
}

// 播放状态（核心全局类）
export class PlayState {
  img: string = '';
  title: string = '';
  artist: string = '';
  url: string = '';
  playIndex: number = 0;
  time: number = 0;
  duration: number = 0;
  isPlay: boolean = false;
  playMode: 'auto' | 'repeat' | 'random' = 'auto';
  playList: SongItemType[] = [];
}
```

---

## 6. 服务层与 Mock 方案

### 6.1 接口契约 `MusicRepository`

```typescript
export interface MusicRepository {
  getSwiper(): Promise<SwiperType[]>;
  getDailyRecommend(): Promise<DailyRecommendType[]>;
  getRecommendList(): Promise<RecommendListType[]>;
  getSongList(): Promise<SongItemType[]>;
  getMomentList(): Promise<MomentListType[]>;
  getUser(): Promise<UserType>;
}
```

### 6.2 实现切换（`services/index.ets`）

```typescript
// 本期：Mock 实现
export const musicRepository: MusicRepository = new MockMusicRepository();

// 后端就绪后改为：
// export const musicRepository: MusicRepository = new HttpMusicRepository();
```

### 6.3 Mock 数据（`mock/data.ets`）

本地静态数组，覆盖 banner / 每日推荐 / 推荐歌单 / 歌曲 / 动态 / 用户，封面以 `color` 占位（避免依赖网络图片），保证**离线可渲染**。

---

## 7. 接口设计（预留真实 API）

> 真实接口由 `HttpMusicRepository` 实现；路径沿用原项目约定，baseUrl 配置化。

| 方法（仓储） | HTTP | 路径 | 返回 | 使用页面 |
|---|---|---|---|---|
| getSwiper | GET | `/data/swiper` | `SwiperType[]` | Recommend |
| getDailyRecommend | GET | `/data/dailyRecommend` | `DailyRecommendType[]` | Recommend |
| getRecommendList | GET | `/data/recommendList` | `RecommendListType[]` | Recommend |
| getSongList | GET | `/data/songList` | `SongItemType[]` | Find / Mine |
| getMomentList | GET | `/data/momentList` | `MomentListType[]` | Moment |
| getUser | GET | `/data/user` | `UserType` | Mine |

**预留扩展（后续版本）**：`getSongUrl(id)`、`getLyric(id)`、`search(keyword)`、`getPlaylistDetail(id)`、`getComments(id)`、`login()`。

---

## 8. 页面路由与权限

| 路由 | 跳转方式 | 说明 |
|---|---|---|
| `pages/Start` → `pages/Index` | `replaceUrl` | 启动后不可返回 |
| `pages/Index` → `pages/Play` | `pushUrl` | 播放页可返回 |
| `pages/Find` → `pages/Play` | `pushUrl` + `singPlay` | 点击歌曲即播 |

**权限**（`module.json5`）：`ohos.permission.INTERNET`（真实接口联调时启用；Mock 阶段不触发）。

---

## 9. UI 设计系统落地（DESIGN.md → AppTheme token）

`theme/AppTheme.ets` 集中导出：

```typescript
export const Colors = {
  bg: '#121212', surface: '#181818', surfaceMid: '#1f1f1f',
  surfaceHi: '#252525', border: '#4d4d4d', borderLight: '#7c7c7c',
  textPrimary: '#ffffff', textSecondary: '#b3b3b3',
  accent: '#1ed760', accentBorder: '#1db954',
  negative: '#f3727f', warning: '#ffa42b', info: '#539df5',
};
export const Font = { family: 'HarmonyOS Sans', title: 24, head: 18, body: 16, caption: 14, small: 12, micro: 10 };
export const Space = { xs: 4, sm: 8, md: 12, lg: 16, xl: 20, xxl: 24 };
export const Radius = { card: 8, pill: 9999, circle: '50%' };
export const Shadow = { heavy: '0 8 24 rgba(0,0,0,0.5)', card: '0 8 8 rgba(0,0,0,0.3)' };
```

**关键禁止项**（来自 DESIGN.md Do/Don't）：
- 不用绿色作背景装饰；暗色背景不动摇。
- 按钮必须胶囊/圆形，禁止方形。
- 阴影必须重（0.3–0.5 透明度），禁止轻阴影。
- 字号紧凑（10–24），禁止松弛行高。

---

## 10. 目标目录结构

```
entry/src/main/ets/
├── theme/AppTheme.ets            # 设计系统 token（DESIGN.md）
├── models/index.ets              # 数据模型
├── contants/index.ets            # AppStorage Key 常量
├── services/
│   ├── MusicRepository.ets       # 接口 + HttpMusicRepository 预留
│   ├── MockMusicRepository.ets   # Mock 实现
│   └── index.ets                 # 导出当前实例（切换点）
├── mock/data.ets                 # 本地模拟数据
├── utils/
│   ├── AVPlayerManager.ets       # 播放单例
│   ├── AVSessionManager.ets      # 媒体会话
│   └── format.ets                # 时间格式化等
├── components/                   # TabBar / SongCard / SongItemRow 等
├── views/                        # Recommend / Find / Moment / Mine
├── pages/
│   ├── Start.ets
│   ├── Index.ets
│   └── Play.ets
└── entryability/EntryAbility.ets
```

---

## 11. 实施里程碑

| 阶段 | 内容 | 交付 |
|---|---|---|
| P1 基础 | AppTheme、models、contants、mock、services | 设计系统 + 数据契约就绪 |
| P2 框架 | EntryAbility、Start、Index(Tabs+TabBar)、路由/权限 | 可启动、可导航 |
| P3 业务页 | Recommend/Find/Moment/Mine + 公共组件 | 四大 Tab 用 Mock 渲染 |
| P4 播放核心 | AVPlayerManager、Play 页、AVSessionManager、Mini-Bar | 播放/控制/锁屏闭环 |
| P5 联调 | HttpMusicRepository 接入真实接口，切换实例 | 无缝替换数据源 |

---

## 12. 验收标准（Acceptance）

- [ ] 启动页 5s 倒计时 / 跳过正常，不可返回。
- [ ] 4 个 Tab 切换、激活态绿色高亮。
- [ ] 推荐页三个区块用 Mock 数据渲染；发现页列表可点击播放；动态页嵌套正确；我的页网格自适应。
- [ ] 播放页：旋转/进度/模式/列表增删联调通过；锁屏可见控制。
- [ ] 全站颜色/字号/圆角/阴影取自 `AppTheme`，无硬编码色值。
- [ ] 切换 `musicRepository` 实例即可接入真实数据，页面零改动。
- [ ] 严格 ArkTS 编译通过（无 spread / 无 `any` / 命名规范）。

---

## 13. 风险与对策

| 风险 | 对策 |
|---|---|
| 真实接口未就绪阻塞前端 | Mock 先行，接口解耦 |
| 缺图片资源导致渲染异常 | Mock 用 `color` 占位 + 文字封面，零网络依赖 |
| AVPlayer 在受限环境不可用 | `AVPlayerManager` 全链路 try/catch，缺 URL 时仅更新状态不崩溃 |
| 严格模式编译报错 | 禁用 spread/`any`；token 集中；相对路径规范 |

---

## 14. 附录：原项目功能清单对照

| 原功能 | 本期映射 | 状态 |
|---|---|---|
| 启动广告页 | F01 Start | ✅ |
| 底部 4 Tab | F02 Index | ✅ |
| 音乐播放器 | F07 Play + F08 | ✅ |
| 播放列表管理（左滑删） | F07 列表面板 | ✅ |
| 媒体会话锁屏 | F08 AVSession | ✅ |
| 网络数据加载 | F09 + 第 7 章接口 | ✅ Mock |
| 推荐/发现/动态/我的 | F03–F06 | ✅ Mock |

> 本文档与 `docs/项目全景分析-黑马云音乐.md`、`docs/黑马音乐项目学习文档.md` 互为补充：前者为功能与学习路线，本文为**需求与建设规格**。
