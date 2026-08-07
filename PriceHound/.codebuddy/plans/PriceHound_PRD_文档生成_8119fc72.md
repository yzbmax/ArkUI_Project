---
name: PriceHound PRD 文档生成
overview: 基于项目介绍.md中的功能规划，进行详细的需求分析，结合DESIGN.md设计系统，生成一份完整的PRD（产品需求文档），放入docs文件夹。
todos:
  - id: think-requirements
    content: 使用 [skill:think] 对 8 大功能模块进行深度需求分析，确认功能边界、优先级矩阵与技术可行性
    status: completed
  - id: prd-structure
    content: 构建 PRD 文档骨架与章节结构（概述、用户角色、功能需求、非功能需求、UI规范、技术架构、数据模型、路线图、指标）
    status: completed
    dependencies:
      - think-requirements
  - id: functional-specs
    content: 编写 8 大模块的详细功能需求规格（商品管理、价格追踪、多平台比价、数据分析、降价提醒、数据看板、个人中心、特色功能）
    status: completed
    dependencies:
      - prd-structure
  - id: tech-architecture
    content: 编写技术架构、数据模型与接口定义章节（SQLite 表结构、多源 fallback 设计、分层架构说明）
    status: completed
    dependencies:
      - prd-structure
  - id: ui-design-integration
    content: 将 DESIGN.md 的 Claude 暖色调设计系统融入 PRD 的 UI/UX 规范章节（色彩、字体、组件、布局、深色模式适配）
    status: completed
    dependencies:
      - functional-specs
  - id: roadmap-metrics
    content: 编写三阶段实施路线图、风险评估、预算估算与成功指标
    status: completed
    dependencies:
      - tech-architecture
  - id: polish-finalize
    content: 使用 [skill:write] 润色 PRD 全稿并输出为 docs/PRD.md
    status: completed
    dependencies:
      - functional-specs
      - tech-architecture
      - ui-design-integration
      - roadmap-metrics
---

## 产品概述

基于 `docs/项目介绍.md` 中定义的 PriceHound 电商价格监控系统，生成一份完整的 PRD（Product Requirements Document）文档。PRD 将系统化地梳理 8 大功能模块的需求细节、交互逻辑、数据模型、技术选型与实施路线图，并将 `docs/DESIGN.md` 中的 Claude/Anthropic 暖色调设计系统完整融入 UI/UX 规范章节。

## 核心功能模块（PRD 需覆盖）

### 1. 商品管理

- 三种添加方式：商品链接解析（淘宝/京东/拼多多）、关键词搜索、扫码（条形码/二维码）
- 自动识别商品信息（名称、图片、当前价格、平台来源）
- 自定义分类与标签系统（"想买""观望""已降价"等）
- 批量管理：CSV 导入/导出、批量删除/暂停监控

### 2. 价格追踪与监控

- 后台智能定时监控，自定义频率（每小时/每天/每周）
- 手动刷新获取实时价格
- 完整价格变动记录（时间、价格、变动幅度、涨跌趋势）
- 时间范围筛选与历史查询

### 3. 多平台比价

- 同商品跨平台价格抓取（淘宝/京东/拼多多）
- 当前最低价与历史最低价对比
- 价格优势排名与最优渠道推荐

### 4. 数据分析与可视化

- Canvas 折线图：日/周/月/季/年维度，含历史最高/最低点标注
- 图表缩放与拖动交互
- 历史低价识别与统计（平均价、中位数）
- "先涨后降"假促销自动检测
- 价格预测（移动平均法）与购买建议

### 5. 降价提醒与通知

- 目标价格提醒与降幅百分比提醒
- 鸿蒙本地推送通知（锁屏/通知栏）
- 每日/每周价格汇总报告
- 通知管理：单商品开关、免打扰时段、通知历史

### 6. 数据看板与统计

- 总览：监控商品总数、今日变动数量、累计节省金额
- 近 7 天价格波动 Top 榜
- 省钱报告（月度/季度/年度）
- 市场行情与平台价格水平对比

### 7. 个人中心与设置

- 全本地存储（SQLite），无需注册登录
- 数据导出（CSV/Excel）、备份与恢复
- 全局监控频率与数据源优先级配置
- 主题切换（深色/浅色）、应用锁

### 8. 特色功能

- 鸿蒙原生多设备自适应（手机/折叠屏/平板）
- 比价卡片一键分享
- 基于历史数据的智能推荐

## 技术方案

### PRD 文档生成方案

采用结构化 Markdown 格式编写 PRD 文档，遵循标准 PRD 框架（概述 → 用户角色 → 功能需求 → 非功能需求 → UI 规范 → 技术架构 → 数据模型 → 路线图 → 指标），确保文档的完整性、可读性与可执行性。

### PriceHound 应用技术架构（PRD 技术章节需定义）

**分层架构**：

- **展示层（ArkUI）**：基于 ArkTS 声明式 UI，遵循 DESIGN.md 暖色调设计系统
- **业务逻辑层**：ViewModel 模式，@Observed/@State 状态管理
- **数据访问层**：SQLite RDB 封装，数据标准化适配器
- **网络服务层**：@ohos.request HTTP 模块，多源 fallback 策略（官方 API → 第三方 API）
- **后台任务层**：@ohos.resourceschedule.backgroundTaskManager 低功耗定时监控

**数据流设计**：

```
用户操作 → ArkUI 组件(@State) → ViewModel(@Observed) → DataRepository
    ↕
SQLite RDB ← 数据标准化层 ← 网络服务层(多源 fallback) ← 外部 API
```

**关键数据模型**（PRD 需定义）：

- `Product` 表：id, name, imageUrl, platform, categoryId, tags, status, createdTime
- `PriceRecord` 表：id, productId, platform, price, originalPrice, discount, timestamp
- `AlertRule` 表：id, productId, type(target/percent), threshold, enabled
- `NotificationLog` 表：id, productId, type, price, message, timestamp

**技术约束**：

- 纯本地架构，零服务端依赖
- 仅使用官方 API 和授权第三方服务，禁止爬虫
- 后台任务需遵循鸿蒙低功耗规范
- 数据完全本地存储，用户隐私优先

### 实施路线图（三阶段）

- **MVP（1-2月）**：项目框架、1-2个数据源接入、商品搜索添加、SQLite 存储、基础价格展示
- **核心功能（2-3月）**：定时监控、走势图 Canvas 绘制、历史低价识别、降价提醒推送、更多平台接入
- **增强优化（1-2月）**：跨平台比价、假促销识别、数据导出、多设备适配、性能优化

## 使用的 Agent 扩展

### Skill: think

- **用途**：在 PRD 编写前对 8 大功能模块进行结构化分析，确认需求边界、优先级排序、技术可行性判定，产出决策完整的 PRD 大纲
- **预期成果**：明确的功能边界定义、优先级矩阵、技术风险评估、PRD 章节结构确认

### Skill: write

- **用途**：对 PRD 文档全稿进行专业化润色，去除 AI 痕迹，确保表达精准、逻辑紧凑、符合产品文档的专业语调
- **预期成果**：语言精炼、专业规范的 PRD 终稿，可直接用于团队评审与开发执行