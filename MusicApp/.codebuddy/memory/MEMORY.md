# 项目长期记忆（MusicApp / HarmonyOS NEXT）

## 图标染色规范（稳定约定）
- **统一用 `Image` 的 `.colorFilter` 染色**，不要用 `Image.fillColor`（会把 outline 闭合路径的中间填实）也不要用 inline `Path`+`stroke`（SDK 26 下 `Shape.viewBox`/`LineJoinStyle` 类型缺失且 `build()` 内不可声明局部变量）。
- 染色矩阵助手：`components/common.ets` 导出的 `tintMatrix(color: string): number[]`（4x5 矩阵，20 元素，偏移量范围 **0..255**）。`Image(xxx).colorFilter(tintMatrix(fg))`。
- 矩阵原理：RGB 乘子置 0、第 5 列常数偏移设目标色、alpha 行 `0,0,0,1,0` 保留透明度 → 描边染色、中间透明不填实。
- `Image.colorFilter()` 直接接受 `number[]`，无需 `new ColorFilter`。
- 图标 SVG 均为 Tabler outline（`fill="none" stroke="currentColor"`），所以中间不会被填。

## 工程注意事项
- 本工程文件（尤其 `common.ets` 及多处以图标相关的调用方）易被还原回原始态；若构建报 "iconName 不存在 / icon 不存在 / Only UI component syntax" 等，优先怀疑某文件被还原，按需重新同步。
- SDK 26.0.0：`Shape.viewBox`、`LineJoinStyle`、`LineCapStyle` 类型缺失；`build()` 内不可写 `const`/`let`。
- 颜色集中取自 `theme/AppTheme.ets` 的 `Colors`（均为十六进制；`overlay`/`transparent` 为 `rgba`，不作为图标 fg 使用）。
- **SDK 26 的 WaterFlow / IDataSource 差异（重要，2026-08-03 实测）**：
  - `WaterFlow` 列数必须用**链式属性** `.columnsTemplate('1fr 1fr')`（不是构造参数 `WaterFlow({columns:2})`，也不是 `WaterFlowOptions.columns`/`columnsTemplate` 字段——该 SDK 的 `WaterFlowOptions` 类型不认这些字段，报 2769；`.columns(2)` 链式也报不存在）。gap 用 `.columnsGap()/.rowsGap()`。
  - `IDataSource` / `DataChangeListener` **在 SDK 26 的 `@kit.ArkUI` 未导出**（报 2305），`@ohos.arkui.adapter` / `@ohos.arkui.data` 也找不到模块（2307）。**绕过办法**：自定义数据源类不 `implements IDataSource`、不 import 该类型，仅实现 `totalCount/getData/registerDataChangeListener/unregisterDataChangeListener` 四个方法（用本地 `interface IDataChangeListener` 声明 listener 类型），靠 ArkTS 结构匹配被 `LazyForEach` 接受（`LazyForEach` 第一参数类型 `IDataSource` 做结构匹配即可，无需显式 import）。
  - `ImageFit` 枚举也**不在 `@kit.ArkUI` 导出**（报 2305）——直接作为**全局枚举**引用（`ImageFit.Cover`/`ImageFit.Contain`），不要 `import`。同理遇 ArkUI 基础枚举/类型报 2305 时优先试全局引用。
  - 瀑布流卡片放 `FlowItem` 内，卡片根 `width('100%')` 填满列宽；封面用 `aspectRatio` 撑高（FlowItem 本身不设固定高/aspectRatio，否则显示异常）。

## 真实数据源（已接入，2026-07-31）
- **真实接口 = Apple iTunes Search API**（免鉴权 / HTTPS）：`https://itunes.apple.com/search?term={关键词}&entity=song&limit=30`。返回 `previewUrl`（.m4a/AAC 音频直链，AVPlayer 可播）与 `artworkUrl100`（封面，已把 100x100 升级为 300x300）。
- 接入点：`services/index.ets` 内联的 `ItunesMusicRepository`（之前独立成文件会触发本沙箱 LS 对跨文件导入的陈旧"找不到模块"报错，故内联）。实现已 `implements MusicRepository`，并补了 Mock 的 `searchSongs`。
- 覆盖范围：**全部信息流均已切真实数据**（轮播/每日推荐/推荐歌单/动态/我的/发现）。各方法并行/单独调 iTunes Search，真实封面 + 真实预览音频；无免费真实源的部分（动态文案、个人资料）用真实歌曲封面 + 模板文案兜底；任一请求失败/空结果回退 Mock（`USE_HTTP=true` 时仍调 `mock.getX()` 作兜底）。
- 开关：`services/index.ets` 中 `USE_HTTP = true` 即真实源；`false` 回 Mock。
- 切换 `USE_HTTP` 后需要设备/模拟器有网络；`module.json5` 已含 `ohos.permission.INTERNET`。

## 歌单详情页（2026-07-31）
- 新增 `pages/Playlist.ets`（`@Entry`，已在 `main_pages.json` 注册）：由推荐页歌单/每日推荐卡片点击进入，传参 `title`，用 `musicRepository.searchSongs(title)` 拉真实歌曲列表；点歌或「播放全部」经 `AVPlayerManager.singPlay` + `router.pushUrl('pages/Play')` 播放。
- 修复：推荐页 `Recommend.ets` 的歌单卡片原本无点击跳转（注释写"预留"），现已 `router.pushUrl` 到 `Playlist`。
- 路由 API（`router.back/pushUrl/getParams`）在 SDK 26 标 `@deprecated`，仅 HINT 不报错，全项目沿用即可。

## 推荐页轮播主色提取 + 径向渐变（2026-07-31）
- `views/Recommend.ets` 轮播卡片：图片四周 `padding(16)` 留白（不撑满/不贴边）；卡片背景用 `.radialGradient({ center: ['50%','50%'], radius: '75%', colors: [[item.color,0],['rgba(0,0,0,0)',1]] })` 做从中心向外扩散的淡淡渐变；`item.color` 即渐变主色。
- 主色从图片**真实提取**：`aboutToAppear` 拿到 banner 后，逐张 `extractDominantColor(url)` 异步解码采样像素，写回 `swiper[idx].color` 并 `this.swipers = [...this.swipers]` 触发刷新。失败/无网络回退 `fallback` 色。
- **轮播图随机化**：`services/index.ets` 的 `getSwiper()` 每次从 `terms` 列表随机选关键词 + 对返回曲目 Fisher-Yates 洗牌取前 3 张，因此每次进入推荐页轮播图都不同（Index 用 if/else 切换 Tab，切回会重建 Recommend 组件 → `aboutToAppear` 重跑 → 重新随机）。
- 取色实现：`http` 下载 `ARRAY_BUFFER` → `image.createImageSource(buf)` → `await createPixelMap({ desiredSize: {width:16,height:16} })`（专辑封面为正方形）→ `readPixelsToBuffer` → 平均 RGB → `rgba(r,g,b,0.45)`。整段包 try/catch。
- **SDK 怪点（重要）**：本 SDK 的 `ImageInfo` 类型**没有 `width`/`height` 字段**（LS 会报 2339，但实际是类型定义缺失）。不要调用 `getImageInfo().width/height`，改用 `desiredSize` 固定解码尺寸绕开。`createPixelMap()` 返回 `Promise<PixelMap>`，需 `await`。
- 注意：本工程 LS 对 `Recommend.ets` 的报错常为陈旧缓存（报已删除代码行），以磁盘实际内容为准；`radialGradient` 参数形态经 LS 校验通过。
- **ArkTS 规则**：`arkts-no-spread` 禁止对象展开（如 `{ ...obj, x }`）；数组展开 `[...arr]` 合法。更新数组项字段请用显式拷贝：`const old = arr[i]; arr[i] = { id: old.id, ... };`。

## 全局设计系统标准化（2026-07-31，Spotify 风）
- **令牌**（`theme/AppTheme.ets`）：`Colors.bg=#000000`（纯黑）、`surface=#121212`（卡片深灰分层）、`accent=#1DB954`（品牌绿：强调/选中/进度/主操作）；`Radius.card=12`（普通容器统一）、新增 `Radius.cover=8`（歌曲列表封面）；`Font` 层级 `title=28`(一级 Bold)/`head=20`(二级 Medium)/`body=16`(正文 Medium)/`caption=14`(辅助 Regular)。
- **间距**：页面左右统一 `Space.xxl=24vp`、区块间距 `Space.xl=20vp`（Recommend/Find/Play/Moment/Mine 均已改）。
- **组件**：`TabBar` 选中品牌绿+未选浅灰、毛玻璃 `backdropBlur(30)`、图标24居中均衡（去掉了灰底 pill）；`SongCard` 卡片#121212+`Shadow.card`柔光、文字左对齐+省略号、封面正方形；`SongItemRow` 整行 `.onClick` 播放、封面 `Radius.cover`、`VerticalAlign.Center`、白色小播放键(32)+`.padding`放大热区、底部 0.5 深灰分割线。
- **页面**：`Recommend` 轮播 `Indicator.dot()` 品牌绿放大（选中12/未选8）、开始收听一级28Bold、每日推荐/推荐歌单二级20Medium、各区块独立 Column（外space20/内space12）；`Find` 搜索框#121212+12vp圆角+透明TextInput左对齐；`Play` 移除旋转定时器与`modeText`、封面宽70%正方形居中+`Shadow.heavy`、进度条 `trackColor`深灰/`selected+block`绿/时间14、控制栏 `SpaceEvenly` 五键+主键68绿圆白图标+模式键选中绿、播放列表抽屉顶部上滑提示条（44x4圆角条）、顶栏透明图标28。
- **局限**：选中态"填充图标"因仅有一套线性(Tabler outline)图标资源，用品牌绿近似表达，无填充变体。
- **既有提示**：Find/Moment/Play 的 `router.pushUrl/back` 报 28040(可能抛异常)WARNING 与弃用 HINT，均为既有用法；`Playlist.ets` 已加 try/catch，可按需统一。

## 底部浮层布局（2026-07-31）
- `pages/Index.ets` 用 `Stack({ alignContent: Alignment.Bottom })`：内容区铺满全屏，`MiniBar`+`TabBar` 作为底部浮层叠在内容之上（之前是 Column 纵向布局，内容在条上方结束，透明也看不到内容）。
- `MiniBar`/`TabBar` 背景改为 `rgba(18,18,18,0.55)` + `.backdropBlur(20)`（暗色主题磨砂半透明，后方内容可透出，白字仍清晰）。
- 4 个视图（Recommend/Find/Moment/Mine）根级 `Scroll` 的内层 `Column` 统一加 `.padding({ bottom: 150 })`，避免最后一项被浮层条永久遮挡。
- `MiniBar` 条件渲染：仅当 `playState.title.length > 0`（后台有歌曲载入）时才显示整条；无音乐时整条隐藏、内容铺满。播放按钮 `IconSlot` 加 `.opacity(0.85)` 轻微透明。
- 改动后 LS 可能报 `Space.taptop` 不存在（2339）——属陈旧误报，`ISpace` 已定义 `taptop`，实际构建通过。

## ArkTS 网络/日志导入（易错点）
- `@ohos.net.http` 与 `@ohos.hilog` 是**默认导出**，必须 `import http from '@ohos.net.http'` / `import hilog from '@ohos.hilog'`（不能用具名 `import { http }`，否则报 2614）。
- 本沙箱 LS 对"新创建的跨文件导入"容易残留陈旧索引（报 2307 找不到模块），整体重写导入方文件或把类内联进已索引文件可消除。
