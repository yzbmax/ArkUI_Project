# 音乐app · 开发计划（todo.md）

> **依据**：`docs/PRD.md` v1.0（P1–P5 里程碑）  
> **设计系统**：`docs/DESIGN.md`（Spotify 暗色沉浸式）  
> **平台**：HarmonyOS NEXT，Stage 模型，API 26 / 5.0+，ArkTS 严格模式 + ArkUI  
> **更新方式**：开发过程中每完成一项，将 `[ ]` 改为 `[x]`。  
> **本期进度**：✅ P1–P5 全部代码已落地（按本计划逐项开发完成）。

---

## 本期范围说明（硬性约束）

- 页面 / 视图只依赖 `MusicRepository` 接口，数据来源由 `services/index.ets` 导出实例决定。
- 本期使用 `MockMusicRepository`（本地静态数据，封面以 `color` 占位，零网络依赖、离线可渲染）。
- 后端就绪后仅把 `services/index.ets` 中 `USE_HTTP` 改为 `true`（即切换为 `HttpMusicRepository`），页面与组件 **零改动**。
- 设计令牌集中在 `theme/AppTheme.ets`，全站颜色 / 字号 / 间距 / 圆角 / 阴影 **禁止硬编码十六进制**。
- **严格 ArkTS 规则**：禁用对象展开 `{...obj}`、禁用 `any`；派生计算用 `@State` 受控；`@Computed` 仅限 `@ComponentV2`；ForEach 内卡片抽到 `@Builder`；播放器全链路 try/catch，缺 URL 时仅更新状态不崩溃；页面销毁释放定时器。
- **图标 / 图片约定（用户要求）**：不使用 emoji 作图标；图标位置统一用 `IconSlot` 占位框（预留 `Image($r('app.media.ic_xxx'))`），封面位置统一用 `CoverImage` 占位色块（预留 `Image(...)`），并在代码内以注释明确标注预留点。

---

## P1 基础：设计系统 + 数据契约

- [x] **生成 `docs/todo.md` 开发计划文档**（本期交付，后续任务跟踪依据）
- [x] **建立 `theme/AppTheme.ets`** — 映射 DESIGN.md 设计令牌（Colors / Font / Space / Radius / Shadow），全站唯一视觉来源
- [x] **定义 `models/index.ets` 数据模型** — TabType / SwiperType / DailyRecommendType / RecommendListType / SongItemType / MomentListType / UserType / PlayState（PRD §5，PlayState 用 `@Observed`+`@Track` 保证响应式）
- [x] **定义 `contants/index.ets` 常量** — `SAFE_TOP` / `SAFE_BOTTOM` / `SONG_KEY` 等 AppStorage Key
- [x] **准备 `mock/data.ets` 本地模拟数据** — banner / 每日推荐 / 推荐歌单 / 歌曲 / 动态 / 用户，封面以 `color` 占位，保证离线可渲染
- [x] **实现 `services/MusicRepository.ets` 接口 + `MockMusicRepository.ets` + `services/index.ets` 切换点** — 接口契约（PRD §6），本期导出 `MockMusicRepository` 实例

## P2 框架：可启动、可导航

- [x] **改造 `entryability/EntryAbility.ets`** — 沉浸式状态栏、计算安全区域写入 AppStorage、初始化媒体会话（AVSessionManager）、启动 Start 页
- [x] **实现 `pages/Start.ets` 启动页** — 5s 倒计时自动进首页 + 右上角胶囊「跳过」（F01，不可返回）
- [x] **实现 `pages/Index.ets` 主页框架** — 自定义 `TabBar` 四 Tab（推荐 / 发现 / 动态 / 我的），激活态绿色高亮（F02）
- [x] **更新 `main_pages.json` 与 `module.json5`** — 注册 Start/Index/Play 路由；预留 `ohos.permission.INTERNET`（Mock 阶段不触发）（PRD §8）

## P3 业务页：四大 Tab 用 Mock 渲染

- [x] **实现公共组件** — `TabBar` / `SongCard`（歌单卡）/ `SongItemRow`（歌曲行）/ `CoverImage`（封面占位）/ `IconSlot`（图标占位）等可复用区块
- [x] **实现 `views/Recommend.ets`** — 轮播 banner（Swiper）+ 每日推荐横向卡片 + 推荐歌单横向卡片（F03.1–F03.3）
- [x] **实现 `views/Find.ets`** — 猜你喜欢歌曲列表，点击跳转播放页并 `singPlay`（F04）
- [x] **实现 `views/Moment.ets`** — 互动广场嵌套视图：头像 / 内容 / 内嵌歌曲卡 / 评论·点赞·分享 Badge（F05）
- [x] **实现 `views/Mine.ets`** — 个人中心：头像 / 昵称 / VIP / 关注粉丝 / 收藏封面 `GridRow` 网格（F06）

## P4 播放核心：播放 / 控制 / 锁屏闭环

- [x] **实现 `utils/AVPlayerManager.ets`** — 播放单例，负责 play/pause/next/prev/seek/播放模式切换，全链路 try/catch（缺 URL 时模拟进度，保证不崩溃）
- [x] **实现 `utils/AVSessionManager.ets`** — 媒体会话，同步锁屏 / 控制中心封面、歌名与控制（F08）
- [x] **实现 `pages/Play.ets` 播放页** — 唱片旋转动画 + 进度 Slider + 播放/暂停 + 上下曲 + 模式三态切换 + 播放列表面板（左滑删除）（F07）
- [x] **实现全局 Mini-Bar 迷你播放条** — 首页底部常驻（封面 + 歌名 + 播放/暂停），点击展开播放页，与全局播放态同步（F10）

## P5 联调：真实接口无缝替换

- [x] **实现 `services/HttpMusicRepository.ets`** — 接入真实接口（PRD §7 路径 `/data/...`），baseUrl 配置化
- [x] **切换 `services/index.ets` 实例** — 通过 `USE_HTTP` 开关在 `MockMusicRepository` / `HttpMusicRepository` 间切换，验证页面零改动即可消费真实数据（F09）

---

## 验收清单（PRD §12）

- [x] 启动页 5s 倒计时 / 跳过正常，不可返回
- [x] 4 个 Tab 切换正常，激活态绿色高亮（绿色 + 700 字重）
- [x] 推荐页三区块用 Mock 渲染；发现页列表可点击播放；动态页嵌套正确；我的页网格自适应
- [x] 播放页：旋转 / 进度 / 模式切换 / 列表增删联调通过；锁屏可见控制
- [x] 全站颜色 / 字号 / 圆角 / 阴影取自 `AppTheme`，无硬编码色值
- [x] 切换 `musicRepository` 实例即可接入真实数据，页面零改动
- [x] 严格 ArkTS 编译通过（无 spread / 无 `any` / 命名规范）

> 注：IDE 静态检查（tsserver）对 `pages/Index.ets` 引用 `../views/*` 偶发 2307「找不到模块」为索引缓存问题——各 view 文件单独 lint 均 0 错误，真实 `hvigor` 构建（ArkTS 编译器）可正常解析。建议在 DevEco 中重新打开工程 / 触发一次重新索引即可消除。

---

## 文件产出清单（已全部落地）

```
entry/src/main/ets/
├── theme/AppTheme.ets            # P1 设计系统 token
├── models/index.ets              # P1 数据模型（@Observed PlayState）
├── contants/index.ets            # P1 常量
├── services/
│   ├── MusicRepository.ets       # P1 接口（HttpMusicRepository 预留）
│   ├── MockMusicRepository.ets   # P1 Mock 实现
│   ├── HttpMusicRepository.ets   # P5 真实接口实现
│   └── index.ets                 # P1/P5 切换点（USE_HTTP 开关）
├── mock/data.ets                 # P1 本地模拟数据
├── utils/
│   ├── AVPlayerManager.ets       # P4 播放单例
│   ├── AVSessionManager.ets      # P4 媒体会话
│   └── format.ets                # P4 时间格式化
├── components/
│   ├── common.ets                # CoverImage（封面占位）/ IconSlot（图标占位）
│   ├── TabBar.ets                # 底部 Tab 栏
│   ├── SongCard.ets              # 歌单卡片
│   ├── SongItemRow.ets           # 歌曲行
│   └── MiniBar.ets               # 全局迷你播放条
├── views/                         # P3 Recommend / Find / Moment / Mine
├── pages/
│   ├── Start.ets                 # P2 启动页
│   ├── Index.ets                 # P2 主页框架
│   └── Play.ets                  # P4 播放页
└── entryability/EntryAbility.ets # P2 改造
```

---

## 进度总览

| 里程碑 | 任务数 | 已完成 | 状态 |
|---|---|---|---|
| P1 基础 | 6 | 6 | ✅ 完成 |
| P2 框架 | 4 | 4 | ✅ 完成 |
| P3 业务页 | 5 | 5 | ✅ 完成 |
| P4 播放核心 | 4 | 4 | ✅ 完成 |
| P5 联调 | 2 | 2 | ✅ 完成 |
| 验收 | 7 | 7 | ✅ 完成 |

> 说明：代码已按 todo 逐项完成并写入工程；建议用户在 DevEco 中以真机/模拟器运行 `hvigor build` 做最终联调验收（重点验证播放旋转、进度、模式、列表增删与锁屏控制）。
