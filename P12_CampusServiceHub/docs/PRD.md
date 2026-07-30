# P12_CampusServiceHub 产品需求文档（PRD）

> 校园服务枢纽 · HarmonyOS（ArkUI / ArkTS）前端 Demo
> 版本：v1.0 ｜ 日期：2026-07-30 ｜ 状态：评审稿
> 设计系统来源：`docs/DESIGN.md`（Apple 设计语言）
> 范围：纯前端界面 + 模拟数据，不涉及后端

---

## 1. 文档信息

| 项 | 内容 |
|----|------|
| 项目名称 | P12_CampusServiceHub（校园服务枢纽） |
| 平台 | HarmonyOS NEXT，ArkUI（Stage 模型，ArkTS） |
| 目标设备 | 手机（竖屏，360–480px 宽度基线） |
| 文档版本 | v1.0 |
| 作者 | 项目组 |
| 评审状态 | 待评审 |

---

## 2. 项目概述

### 2.1 背景
本项目是一个**学习训练型**前端应用，目标是用一套贴近真实校园场景的界面，串联 HarmonyOS ArkUI 的核心开发知识点（声明式组件、状态管理、列表渲染、表单校验、路由分区、派生计算等）。所有数据均为本地模拟数据（Mock），不连接任何后端服务。

### 2.2 目标
- 交付一个可运行、视觉统一、交互完整的校园服务聚合 App 前端。
- 覆盖 11 个页面与 11 项训练目标（P01–P11，见第 8 章）。
- 视觉严格遵循 `DESIGN.md` 的 Apple 设计系统。

### 2.3 范围

**范围内（In Scope）**
- 11 个页面的 UI 与本地交互逻辑。
- 页面内状态管理、表单校验、列表渲染、派生计算、数组更新。
- 基于模拟数据的展示与本地状态变更（登录态、报名、点赞、购物车数量、草稿发布、开关）。
- 统一的风格化设计 token 与可复用组件。

**范围外（Out of Scope）**
- 任何网络请求、真实接口、登录鉴权后端。
- 数据持久化（Preferences / 数据库）。
- 支付、真实第三方登录、IM、推送。
- 国际化、多主题切换（仅跟随系统深浅色，不额外做主题系统）。
- 单元测试框架之外的自动化测试（仅保留既有测试骨架）。

### 2.4 关键约束
- 所有页面必须具备 `@Entry`、`@Component`、`build()`（P01）。
- 单一强调色：Apple Blue `#0071e3`，不得引入其它彩色（DESIGN.md 硬规则）。
- 卡片不使用边框；阴影仅用 `rgba(0,0,0,0.22) 3px 5px 30px` 这一种柔和阴影。
- 派生数据（BMI、服务总价）不单独保存，由源数据实时计算（P05）。

---

## 3. 用户角色

| 角色 | 描述 | 主要诉求 |
|------|------|----------|
| 在校大学生（唯一角色） | 使用学号 + 密码登录（模拟） | 一站式查看课程、活动、校园服务、讨论、健康与个人信息 |

> 备注：本 Demo 不区分权限角色，所有功能对登录用户开放。

---

## 4. 设计系统应用规范（DESIGN.md → ArkUI 映射）

DESIGN.md 面向 Web（CSS），需翻译为 ArkUI 可用的设计 token。所有 token 集中定义在 `entry/src/main/ets/theme/AppTheme.ets`，供各页面统一引用，**禁止**在各页面硬编码色值/尺寸。

### 4.1 色彩 Token

| DESIGN.md | 语义 | ArkUI 取值 | 用途 |
|-----------|------|-----------|------|
| Pure Black `#000000` | 沉浸深色背景 | `0x000000` | Hero / 深色分区 |
| Light Gray `#f5f5f7` | 页面/浅色卡背景 | `0xF5F5F7` | 默认页面背景、浅色卡片 |
| Near Black `#1d1d1f` | 浅底主文本 / 深按钮 | `0x1D1D1F` | 标题、正文、深色按钮填充 |
| Apple Blue `#0071e3` | 唯一强调色 | `0x0071E3` | 主 CTA、链接、焦点环、开关开启态 |
| Link Blue `#0066cc` | 浅底内联链接 | `0x0066CC` | “了解更多”类文字链 |
| Bright Blue `#2997ff` | 深底链接 | `0x2997FF` | 深色背景上的链接 |
| White `#ffffff` | 深底文本 | `0xFFFFFF` | 深色分区文字、按钮文字 |
| Black 80% `rgba(0,0,0,0.8)` | 次级文本 | `0xCC000000` | 副标题、导航项 |
| Black 48% `rgba(0,0,0,0.48)` | 三级/禁用 | `0x7A000000` | 占位、禁用态、轮播控制 |
| Dark Surface `#272729`–`#2a2a2d` | 深底卡片 | `0x272729` | 深色分区内的卡片 |
| Card Shadow | 柔和投影 | `.shadow({ radius: 30, color: 0x38000000, offsetX: 3, offsetY: 5 })` | 产品卡、浮层 |

> `0x38000000` = alpha 0.22 的黑色（0.22×255≈56=0x38）。

### 4.2 字体排版 Token

SF Pro 在鸿蒙设备上不存在，统一用 `HarmonyOS Sans`（默认字体）替代，保留 DESIGN.md 的**尺寸 / 字重 / 行高 / 负字距**四要素，仅字体族不同。

| 角色 | 字号(vp) | 字重 | 行高 | 字距(vp) | ArkUI 示例 |
|------|---------|------|------|---------|-----------|
| Display Hero | 56 | 600 | 1.07 | -0.28 | `.fontSize(56).fontWeight(600).lineHeight(60).letterSpacing(-0.28)` |
| Section Heading | 40 | 600 | 1.10 | 0 | 用于页面大标题 |
| Tile Heading | 28 | 400 | 1.14 | 0.196 | 卡片主标题 |
| Card Title | 21 | 700 | 1.19 | 0.231 | 加粗卡标题 |
| Sub-heading | 21 | 400 | 1.19 | 0.231 | 常规卡标题 |
| Body | 17 | 400 | 1.47 | -0.374 | 正文 |
| Body Emphasis | 17 | 600 | 1.24 | -0.374 | 强调正文 / 标签 |
| Link | 14 | 400 | 1.43 | -0.224 | 文字链 |
| Caption | 14 | 400 | 1.29 | -0.224 | 描述/次级 |
| Micro | 12 | 400 | 1.33 | -0.12 | 脚注 |
| Nano | 10 | 400 | 1.47 | -0.08 | 法律/最小字 |

**规则**：标题可居中；正文左对齐（DESIGN.md 硬性规则）。最大字重 700，禁用 800/900。

### 4.3 圆角与按钮

| 类型 | ArkUI 实现 | 说明 |
|------|-----------|------|
| 主 CTA（Apple Blue） | `Button('登录', { type: ButtonType.Normal })` + `.borderRadius(8)` + `.backgroundColor(0x0071E3)` + `.fontColor(0xFFFFFF)` | 标准按钮，8px 圆角 |
| 胶囊链接（“了解更多”） | `Button({ type: ButtonType.Capsule })` + 透明背景 + `1px solid 0x0066CC` + 文字 `0x0066CC` | 对应 DESIGN.md 980px 胶囊 |
| 深色按钮 | 同上，背景 `0x1D1D1F` | 次级 CTA |
| 卡片圆角 | `8–12vp` | 产品卡 8、生活图文 12 |
| 媒体控制 | 圆形 `50%` | 播放/箭头 |

DESIGN.md 的 `980px` 胶囊半径在 ArkUI 中等价于 `ButtonType.Capsule`（完全圆角胶囊）。

### 4.4 卡片与阴影
- 背景：`0xF5F5F7`（浅）或 `0x272729` 系（深）。
- **无边框**（DESIGN.md 硬规则）。
- 阴影：仅 `.shadow({ radius: 30, color: 0x38000000, offsetX: 3, offsetY: 5 })`，多数卡片无阴影，靠背景色差体现层次。

### 4.5 导航玻璃
DESIGN.md 的 `backdrop-filter: blur(20px)` + `rgba(0,0,0,0.8)` 在 ArkUI 中近似实现：
- 自定义标题栏 `Row` 使用 `.backgroundColor('rgba(0,0,0,0.8)')` + `.blur(20)`。
- 高度 `48vp`，文字 `12vp` 白色 `FontWeight.Regular`。
- 若设备不支持真实背景模糊，退化为半透明深色（视觉一致即可）。

### 4.6 间距系统
基准 8vp，可用刻度：`2,4,5,6,7,8,10,11,14,15,17,20,24`。常见页边距 `16–20vp`，分区间距 `24vp`，卡片内边距 `16vp`（呼应“留白”原则 P02）。

---

## 5. 信息架构与页面流程

### 5.1 页面结构树
```
P12_CampusServiceHub
├─ 登录
│  └─ LoginPage                （独立全屏，登录前）
├─ 主框架（Tabs 底部导航）
│  ├─ HomePage                 （首页 / 应用入口，聚合模块）
│  ├─ CoursePage
│  │  └─ CourseDetailPage      （router.pushUrl）
│  ├─ ActivityPage
│  │  └─ ActivityDetailPage    （router.pushUrl，P09 分区）
│  ├─ DiscussionPage           （草稿→评论数组，P10）
│  └─ ProfilePage              （我的）
│     └─ SettingsPage          （多开关，P07）
└─ 入口页（由首页功能入口进入）
   ├─ ServicePage              （服务数量/总价，P05/P08）
   └─ HealthPage               （BMI 派生，P05）
```

### 5.2 主流程（登录 → 首页 → 功能页）
```
LoginPage(学号+密码+协议)
   │ 校验通过 → 保存登录态(@State/@StorageLink)
   ↓
HomePage(用户摘要 / 今日主线 / 功能入口卡片)
   │ 点击功能入口
   ↓
CoursePage / ActivityPage / ServicePage / DiscussionPage / HealthPage / ProfilePage
   │ Course/Activity 点击列表项 → pushUrl 到 DetailPage
   ↓
（各页内部状态交互：报名/点赞/数量/草稿发布/开关）
```

### 5.3 导航决策（关键决策）
- **底部 Tab**：首页 / 课程 / 活动 / 讨论 / 我的（5 个高频模块）。
- **服务页、健康页**通过首页“功能入口”卡片进入（呼应 P11 模块聚合，避免 Tab 过多）。
- **设置页**从“我的”进入。
- **课程详情 / 活动详情**用 `router.pushUrl({ url: 'pages/CourseDetailPage', params })` 进入，返回用 `router.back()`。

---

## 6. 功能需求详述

> 每个页面标注：功能、关键 UI 元素、交互/状态、数据字段、训练目标。

### 6.1 LoginPage（登录页）— P01 / P03 / P04
- **功能**：输入学号、密码，勾选协议，点击登录进入首页。
- **UI 元素**（遵循 DESIGN.md 深色沉浸式）：
  - 顶部标题区：应用名（Display Hero 56vp，近黑或白），副标题（21vp）。
  - 表单卡片（浅色 `#f5f5f7`，圆角 8，无边框）：
    - 学号输入框（占位符“请输入学号”，Caption 12vp）。
    - 密码输入框（`type: InputType.Password`）。
    - 协议勾选行：`Checkbox` + 文字“我已阅读并同意《用户协议》”（链接蓝）。
  - 登录按钮：Apple Blue 主 CTA，胶囊或 8px 圆角。
- **交互 / 状态（P03）**：
  - `@State studentId: string`、`@State password: string`、`@State agree: boolean`、`@State loading: boolean`。
  - 登录按钮点击 → **表单校验（P04）**：学号非空且为数字、密码长度 ≥ 6、协议已勾选；校验失败用 `AlertDialog` 或行内提示（红色/次级文本），不进入首页。
  - 校验通过 → 模拟登录（短暂 loading）→ 写入登录态（AppStorage）→ `router.replaceUrl('pages/HomePage')`。
- **字段**：`studentId`, `password`, `agree`。
- **派生 / 校验**：无派生；纯表单校验。

### 6.2 HomePage（首页）— P01 / P02 / P11
- **功能**：展示用户摘要、今日主线、功能入口，作为应用入口聚合各模块（P11）。
- **UI 元素（卡片 + 留白，P02）**：
  - 顶部用户摘要卡（深色 `#272729` 卡）：头像占位 + 姓名/学号 + 一句欢迎语。
  - 今日主线卡（浅色）：当日待办/课程提醒（如“今日 2 门课 · 1 场活动”）。
  - 功能入口网格（2–3 列卡片，无边框，柔和阴影）：课程、活动、服务、讨论、健康、我的。
  - 区块标题用 Section Heading 40vp，卡片标题 Card Title 21vp。
- **交互 / 状态**：
  - 功能入口卡片 `onClick` → 对应路由跳转（课程/活动/讨论走 Tab；服务/健康走 pushUrl；我的走 Tab）。
  - 顶部摘要数据来自模拟用户对象（详见第 7 章 `UserProfile`）。
- **字段**：`user: UserProfile`、`entries: FunctionEntry[]`（图标/标题/路由）。

### 6.3 CoursePage + CourseDetailPage（课程）— P01 / P06 / P09
- **列表页 CoursePage**：
  - `ForEach` 渲染课程数组（P06）：`courses: CourseInfo[]`。
  - 课程卡片：课程名（Card Title）、教师、时间、地点、学分标签。
  - 点击卡片 → `router.pushUrl` 到 `CourseDetailPage`，传 `courseId`。
- **详情页 CourseDetailPage（P09 分区）**：
  - 接收 `params.courseId`，从 Mock 数组查找该课程。
  - 展示课程简介、大纲、教师介绍、上课时间地点。
  - 顶部返回按钮（`router.back()`）；标题区显示课程名。

### 6.4 ActivityPage + ActivityDetailPage（活动）— P01 / P03 / P06 / P09
- **列表页 ActivityPage**：
  - `ForEach` 渲染活动数组：`activities: ActivityInfo[]`（P06）。
  - 活动卡片：标题、时间、地点、海报占位、状态标签（报名中/已结束）。
- **详情页 ActivityDetailPage（P09）**：
  - 详情 + **报名按钮（P03 状态事件）**：`@State enrolled: boolean`。
  - 点击“报名” → 状态翻转（报名中 → 已报名），按钮文案/颜色随之变化（Apple Blue ↔ 次级灰）。
  - 返回列表 `router.back()`。

### 6.5 ServicePage（服务）— P01 / P05 / P06 / P08
- **功能**：校园服务（打印、洗衣、维修等）列表，可调整数量，实时计算总价。
- **UI / 数据（P06）**：`ForEach` 渲染 `services: ServiceItem[]`，每项含 `name`, `price`, `qty`。
- **数组更新（P08）**：每项有 − / + 按钮，`onClick` 修改该项的 `qty`（`@State` 数组，配合 `@Observed`/`@ObjectLink` 或整体替换实现响应式更新）。
- **派生计算（P05）**：总价 `@Computed get total()` = `services.reduce((s,i)=>s+i.price*i.qty, 0)`，**不单独保存**。底部固定栏展示总价 + “去结算”按钮（演示用，点击仅提示）。
- **字段**：`ServiceItem { id, name, desc, price, qty }`。

### 6.6 DiscussionPage（讨论）— P01 / P03 / P06 / P10
- **功能**：讨论列表 + 发布草稿。
- **列表（P06）**：`ForEach` 渲染 `posts: Post[]`，含作者、内容、点赞数、时间。
- **点赞（P03）**：每条有 👍 按钮，`@State liked` + 点赞数 +1/−1（状态修改）。
- **发布流程（P10）**：
  - 底部输入框 + “发布”按钮，绑定 `@State draft: string`。
  - 点击发布 → 将 `draft` 构造成 `Post` 并 `unshift` 到 `posts` 数组（草稿进入评论数组），清空 `draft`。
  - 新帖即时出现在列表顶部。
- **字段**：`Post { id, author, avatar, content, likes, liked, time }`。

### 6.7 HealthPage（健康）— P01 / P05
- **功能**：记录身高体重，实时计算 BMI。
- **输入**：身高（cm）、体重（kg）输入框，绑定 `@State height`, `@State weight`。
- **派生计算（P05）**：`@Computed get bmi()` = `weight / (height/100)^2`，并映射 BMI 等级（偏瘦/正常/偏胖）文案与颜色提示（仍只用蓝/灰，不用额外彩色）。
- **展示**：大号 BMI 数值（Display 风格），下方等级说明卡片。
- **字段**：`height: number`, `weight: number`（源自模拟健康档案，可编辑）。

### 6.8 ProfilePage（我的）— P01 / P02
- **功能**：个人信息与快捷入口。
- **UI（卡片 + 留白，P02）**：
  - 个人信息卡（深色卡）：头像、姓名、学号、学院。
  - 数据卡：我的课程数、活动参与数、服务订单数（来自 Mock 聚合）。
  - 入口列表卡：健康、设置、讨论等入口（点击跳转）。
- **字段**：`user: UserProfile`。

### 6.9 SettingsPage（设置）— P01 / P07
- **功能**：多个独立开关（P07 多状态）。
- **UI**：`ForEach` 渲染开关项 `settings: ToggleItem[]`，每项 `Toggle({ type: ToggleType.Switch })`.
- **多状态（P07）**：每项独立 `@State enabled: boolean`，互不影响；如“消息通知”“深色模式跟随系统”“WiFi 自动下载”“隐私保护”等。
- **字段**：`ToggleItem { id, title, desc, enabled }`。

---

## 7. 数据模型（Mock）

以下为 ArkTS 接口（模拟数据，定义在 `entry/src/main/ets/mock/`）：

```ts
// 用户
interface UserProfile {
  id: string;
  name: string;
  studentNo: string;
  college: string;
  avatar?: Resource; // 占位图
  courseCount: number;
  activityCount: number;
  orderCount: number;
}

// 课程
interface CourseInfo {
  id: string;
  name: string;
  teacher: string;
  time: string;
  location: string;
  credit: number;
  desc: string;
  outline: string[];
}

// 活动
interface ActivityInfo {
  id: string;
  title: string;
  time: string;
  location: string;
  poster?: Resource;
  status: 'open' | 'closed';
  desc: string;
}

// 服务项
interface ServiceItem {
  id: string;
  name: string;
  desc: string;
  price: number;
  qty: number;
}

// 讨论帖
interface Post {
  id: string;
  author: string;
  avatar?: Resource;
  content: string;
  likes: number;
  liked: boolean;
  time: string;
}

// 健康档案
interface HealthProfile {
  height: number; // cm
  weight: number; // kg
}

// 设置开关
interface ToggleItem {
  id: string;
  title: string;
  desc: string;
  enabled: boolean;
}
```

> 所有 Mock 数据以常量数组形式提供；详情页通过 `id` 在数组中查找。

---

## 8. 训练目标映射表（P01–P11）

| 编号 | 训练目标 | 落页面 / 实现方式 |
|------|----------|-------------------|
| P01 | `@Entry`/`@Component`/`build()` | 全部 11 个页面必备 |
| P02 | 卡片 + 留白 | HomePage、ProfilePage |
| P03 | 状态事件修改状态 | LoginPage（登录）、ActivityDetailPage（报名）、DiscussionPage（点赞） |
| P04 | 表单校验 | LoginPage（学号/密码/协议） |
| P05 | 派生计算不保存 | HealthPage（BMI）、ServicePage（总价） |
| P06 | 列表渲染（数组） | Course / Activity / Service / Discussion |
| P07 | 多状态独立开关 | SettingsPage |
| P08 | 数组更新（数量） | ServicePage（+/− 修改 qty） |
| P09 | 页面分区（列表+详情） | ActivityPage+Detail、CoursePage+Detail |
| P10 | 发布流程（草稿→数组） | DiscussionPage |
| P11 | 模块聚合入口 | HomePage 功能入口网格 |

---

## 9. 非功能性需求

| 类别 | 要求 |
|------|------|
| 性能 | 列表 `ForEach` 必须带 `key`（使用稳定 `id`），避免整体重渲染；派生计算用 `@Computed` 减少重复运算。 |
| 兼容性 | 适配 360–480px 手机宽度；相对布局（`Column`/`Row` + `LayoutWeight`）为主。 |
| 可访问性 | 交互元素最小可点区域 ≥ 44×44vp；焦点环使用 Apple Blue。 |
| 安全（前端） | 密码输入框 `type: Password`；Mock 数据不含真实隐私；协议勾选为登录前置条件。 |
| 一致性 | 所有视觉取值来自 `AppTheme`，禁止散落硬编码。 |

---

## 10. 验收标准

**主流程**
1. 启动进入 LoginPage；未填/未勾协议时登录被拦截并提示（P04）。
2. 校验通过进入 HomePage；功能入口可跳转至各模块（P11）。
3. 课程/活动列表点击进入详情并可返回（P09）。
4. 活动详情“报名”按钮状态可翻转（P03）。
5. 服务页 +/− 修改数量，底部总价实时变化（P05/P08）。
6. 讨论页输入草稿并发布，新帖出现在顶部（P10）；点赞数随点击增减（P03）。
7. 健康页输入身高体重，BMI 实时计算并显示等级（P05）。
8. 我的页以卡片留白呈现（P02）；设置页多开关独立生效（P07）。

**通用**
- 11 个页面均含 `@Entry/@Component/build()`（P01）。
- 全站仅使用 DESIGN.md 规定的色彩与组件样式（单一蓝强调、无边框卡、柔和阴影、胶囊 CTA、玻璃导航）。

---

## 11. 风险与假设

| 项 | 说明 |
|----|------|
| 假设 | 设备为手机竖屏；仅前端，无需后端联调。 |
| 假设 | 鸿蒙设备无 SF Pro，使用 `HarmonyOS Sans` 替代，仅保留尺寸/字重/行高/字距。 |
| 风险 | `backdrop-filter` 在 ArkUI 无完全等价 API，玻璃导航降级为半透明深色 + `blur` 近似，视觉接近即可。 |
| 风险 | 详情页数据查找依赖 `params` 传递 `id`，需保证 Mock 数组 `id` 唯一。 |

---

## 12. 建设方案与里程碑

按**每个阶段独立可运行**原则拆分（阶段间不互相阻塞）：

- **阶段 1｜设计基座**：`AppTheme`（色彩/字体/间距 token）、可复用组件（卡片、主按钮、胶囊链接、玻璃标题栏）。完成后任意页面即可套用统一风格。
- **阶段 2｜登录与首页**：`LoginPage`（P03/P04）+ `HomePage`（P02/P11）+ 路由/`AppStorage` 登录态。完成后可跑通“登录→首页”主流程。
- **阶段 3｜列表型页面**：`CoursePage`+`CourseDetailPage`、`ActivityPage`+`ActivityDetailPage`（P06/P09）、`DiscussionPage`（P06/P10/P03 点赞）。
- **阶段 4｜状态/派生型页面**：`ServicePage`（P05/P08）、`HealthPage`（P05）、`SettingsPage`（P07）、`ProfilePage`（P02）。
- **阶段 5｜联调与验收**：逐条核对第 10 章验收标准，修正视觉一致性。

> 每个阶段结束系统均处于可用状态；即使后续阶段未开始，已完成的页面仍可独立运行与演示。

---

## 13. 目录建议（落地参考，非强制）

```
entry/src/main/ets/
├─ pages/
│  ├─ LoginPage.ets
│  ├─ HomePage.ets
│  ├─ CoursePage.ets  CourseDetailPage.ets
│  ├─ ActivityPage.ets  ActivityDetailPage.ets
│  ├─ ServicePage.ets
│  ├─ DiscussionPage.ets
│  ├─ HealthPage.ets
│  ├─ ProfilePage.ets  SettingsPage.ets
├─ theme/AppTheme.ets        # 设计 token（第 4 章）
├─ components/               # 卡片、按钮、玻璃栏等复用组件
├─ mock/                     # 第 7 章 Mock 数据
└─ model/                    # 第 7 章接口定义
```

---
*本 PRD 基于 `docs/DESIGN.md` 设计系统与项目给定功能清单编写，作为前端 UI 实现的评审与验收依据。*
