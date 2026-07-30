# P12_CampusServiceHub 开发计划（Todo）

> 依据：`docs/PRD.md`（v1.0）
> 范围：纯前端 ArkUI / ArkTS，Mock 数据，无后端
> 规则：每完成一项，将对应 `- [ ]` 改为 `- [x]` 并填写完成日期
> 约定：所有视觉取值来自 `AppTheme`，禁止页面内硬编码色值/尺寸

---

## 阶段 1 ｜ 设计基座（AppTheme + 复用组件）

- [x] 1.1 新建 `entry/src/main/ets/theme/AppTheme.ets`，定义色彩 token（黑 `#000000`、浅灰 `#F5F5F7`、近黑 `#1D1D1F`、Apple Blue `#0071E3`、链接蓝 `#0066CC`、亮蓝 `#2997FF`、深底卡 `#272729`、阴影 `0x38000000` 等）（2026-07-30）
- [x] 1.2 定义字体排版 token（字号/字重/行高/字距映射表，HarmonyOS Sans 替代 SF Pro）（2026-07-30）
- [x] 1.3 定义间距/圆角常量（8vp 基准刻度、卡片 8–12vp、胶囊 Capsule）（2026-07-30）
- [x] 1.4 新建 `components/AppCard.ets`：浅色/深色无边框卡片，可选柔和阴影（P02）（2026-07-30）
- [x] 1.5 新建 `components/PrimaryButton.ets`：Apple Blue 主 CTA（8vp 圆角，白字）（2026-07-30）
- [x] 1.6 新建 `components/PillLink.ets`：胶囊文字链（透明底 + 蓝边 + 蓝字，对应 DESIGN.md 980px 胶囊）（2026-07-30）
- [x] 1.7 新建 `components/GlassNavBar.ets`：半透明深色 + blur 玻璃标题栏（48vp，12vp 白字）（2026-07-30）
- [x] 1.8 新建 `model/Models.ets`：第 7 章数据接口（UserProfile / CourseInfo / ActivityInfo / ServiceItem / Post / HealthProfile / ToggleItem / FunctionEntry）（2026-07-30）
- [x] 1.9 新建 `mock/MockData.ets`：各模型 Mock 常量数组（保证 `id` 唯一，供详情页查找）（2026-07-30）
- [x] 1.10 建临时 `pages/DemoPage.ets` 验证设计基座可运行（入口指向 DemoPage，待阶段 2 切回 LoginPage）（2026-07-30）

**阶段 1 出口**：任意页面可引用 `AppTheme` 与复用组件渲染统一风格；阶段独立可运行。

---

## 阶段 2 ｜ 登录与首页（主流程跑通）

- [x] 2.1 新建 `pages/LoginPage.ets`：@Entry/@Component/build()（P01）（2026-07-30）
- [x] 2.2 登录页布局：深色沉浸式标题 + 表单卡（学号/密码/协议勾选）+ Apple Blue 登录按钮（P02 卡片留白）（2026-07-30）
- [x] 2.3 表单校验（P04）：学号非空且为数字、密码 ≥6 位、协议已勾选；失败拦截并提示（2026-07-30）
- [x] 2.4 登录状态事件（P03）：校验通过 → 写入 `AppStorage` 登录态 → `router.replaceUrl('pages/HomePage')`（2026-07-30）
- [x] 2.5 新建 `pages/HomePage.ets`：@Entry/@Component/build()（P01）（2026-07-30）
- [x] 2.6 首页用户摘要卡 + 今日主线卡（深色卡，P02）（2026-07-30）
- [x] 2.7 首页功能入口网格（课程/活动/服务/讨论/健康/我的，ForEach 渲染，`FunctionEntry[]`）（P06 / P11 模块聚合）（2026-07-30）
- [x] 2.8 功能入口 onClick 路由跳转（阶段 2 未建模块给 toast，后续阶段可真实跳转）（2026-07-30）

**阶段 2 出口**：启动 → 登录校验 → 首页入口跳转 主流程跑通；阶段独立可运行。

---

## 阶段 3 ｜ 列表型页面（课程 / 活动 / 讨论）

- [x] 3.1 新建 `pages/CoursePage.ets`：ForEach 渲染 `courses: CourseInfo[]`（P06）（2026-07-30）
- [x] 3.2 课程卡：名称/教师/时间/地点/学分；点击 `router.pushUrl` 传 `courseId`（P09）（2026-07-30）
- [x] 3.3 新建 `pages/CourseDetailPage.ets`：接收 params 查找课程，展示简介/大纲/教师；返回按钮（P09 分区）（2026-07-30）
- [x] 3.4 新建 `pages/ActivityPage.ets`：ForEach 渲染 `activities: ActivityInfo[]`（P06）（2026-07-30）
- [x] 3.5 活动卡：标题/时间/地点/海报占位/状态标签；点击进入详情（P09）（2026-07-30）
- [x] 3.6 新建 `pages/ActivityDetailPage.ets`：详情 + 报名按钮（2026-07-30）
- [x] 3.7 报名状态事件（P03）：`@State enrolled` 翻转，按钮文案/颜色随状态变化；返回列表（2026-07-30）
- [x] 3.8 新建 `pages/DiscussionPage.ets`：ForEach 渲染 `posts: Post[]`（P06）（2026-07-30）
- [x] 3.9 点赞状态事件（P03）：每条 👍 按钮 `@State liked` + 点赞数增减（2026-07-30）
- [x] 3.10 发布流程（P10）：底部输入框 `@State draft` + 发布按钮 → 构造 `Post` 并 `unshift` 到 `posts`，清空草稿，新帖置顶（2026-07-30）

**阶段 3 出口**：课程/活动列表↔详情、讨论列表+点赞+发布 均可用；阶段独立可运行。

---

## 阶段 4 ｜ 状态 / 派生型页面（服务 / 健康 / 设置 / 我的）

- [x] 4.1 新建 `pages/ServicePage.ets`：ForEach 渲染 `services: ServiceItem[]`（P06）（2026-07-30）
- [x] 4.2 数组更新（P08）：每项 −/+ 按钮修改 `qty`（整体替换响应式）（2026-07-30）
- [x] 4.3 派生计算（P05）：`@Computed total` = Σ(price×qty)，不单独保存；底部固定栏展示总价 + “去结算”（2026-07-30）
- [x] 4.4 新建 `pages/HealthPage.ets`：身高/体重输入 `@State`（2026-07-30）
- [x] 4.5 BMI 派生计算（P05）：`@Computed bmi` = weight/(height/100)²，映射等级文案（仅蓝/灰，不用额外彩色）（2026-07-30）
- [x] 4.6 新建 `pages/SettingsPage.ets`：ForEach 渲染 `settings: ToggleItem[]`（2026-07-30）
- [x] 4.7 多状态开关（P07）：每项独立 `Toggle({type: ToggleType.Switch})`，`@State enabled` 互不影响（2026-07-30）
- [x] 4.8 新建 `pages/ProfilePage.ets`：@Entry/@Component/build()（P01）（2026-07-30）
- [x] 4.9 我的页卡片+留白（P02）：个人信息卡（深色）+ 数据卡 + 入口列表卡；来源 `UserProfile`（2026-07-30）

**阶段 4 出口**：服务数量/总价、健康 BMI、设置多开关、我的页 全部可用；阶段独立可运行。

---

## 阶段 5 ｜ 联调与验收

- [x] 5.1 逐条核对 PRD 第 10 章主流程 8 项（登录拦截、首页入口、详情返回、报名翻转、总价实时、草稿发布、点赞、BMI 实时）（2026-07-30）
- [x] 5.2 通用验收：11 页均含 @Entry/@Component/build()（P01）（2026-07-30）
- [x] 5.3 视觉一致性核查：仅用 DESIGN.md 规定色彩/组件（单一蓝、无边框卡、柔和阴影、胶囊 CTA、玻璃导航）；修正 GlassNavBar 硬编码色为 Colors.navBarBg（2026-07-30）
- [x] 5.4 性能核查：ForEach 均带稳定 `key`（id）；派生计算使用 @Computed（2026-07-30）
- [x] 5.5 设备适配核查：360–480px 手机竖屏相对布局正常，可点区域 ≥44×44vp；服务页 ± 控件放大至 44vp（2026-07-30）

---

## 训练目标覆盖核对（P01–P11）

- [x] P01 @Entry/@Component/build()：全部 11 页（2026-07-30）
- [x] P02 卡片+留白：HomePage、ProfilePage（2026-07-30）
- [x] P03 状态事件：LoginPage、ActivityDetailPage、DiscussionPage（2026-07-30）
- [x] P04 表单校验：LoginPage（2026-07-30）
- [x] P05 派生计算：HealthPage(BMI)、ServicePage(总价)（2026-07-30）
- [x] P06 列表渲染：Course、Activity、Service、Discussion（2026-07-30）
- [x] P07 多状态开关：SettingsPage（2026-07-30）
- [x] P08 数组更新：ServicePage（2026-07-30）
- [x] P09 页面分区：Course、Activity（列表+详情）（2026-07-30）
- [x] P10 发布流程：DiscussionPage（2026-07-30）
- [x] P11 模块聚合：HomePage（2026-07-30）

---

> 进度记录：每完成一项在上方勾选 `- [x]`；本文件与 `PRD.md` 同步维护。
