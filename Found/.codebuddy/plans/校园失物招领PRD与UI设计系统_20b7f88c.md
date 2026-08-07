---
name: 校园失物招领PRD与UI设计系统
overview: 基于现有需求文档，为校园失物招领 App 编写全量覆盖+MVP优先级的详尽 PRD（含功能范围、业务流程、验收标准），并按现有 DESIGN.md 的 Claude 温暖色调风格适配校园场景，输出项目专属 UI 设计系统。
design:
  styleKeywords:
    - 温暖
    - 人文
    - 可信
    - 互助
    - 圆润
    - 柔和
    - 纸张质感
  fontSystem:
    fontFamily: Noto-Serif-SC
    heading:
      size: 26sp
      weight: 600
    subheading:
      size: 20sp
      weight: 500
    body:
      size: 16sp
      weight: 400
  colorSystem:
    primary:
      - "#C96442"
      - "#D97757"
      - "#141413"
    background:
      - "#F5F4ED"
      - "#FAF9F5"
      - "#30302E"
    text:
      - "#141413"
      - "#4D4C48"
      - "#5E5D59"
      - "#87867F"
      - "#B0AEA5"
    functional:
      - "#B53333"
      - "#3898EC"
      - "#6E8B5E"
      - "#C9923E"
todos:
  - id: write-prd
    content: 编写 docs/PRD.md：全量细化 7 大模块，标注 MVP 优先级并给出核心业务流程与分模块验收标准
    status: completed
  - id: rewrite-design
    content: 重构 docs/DESIGN.md：保留 Claude 暖色体系，适配校园失物招领场景并补充 ArkUI 资源命名映射
    status: completed
  - id: polish-consistency
    content: 用 [skill:write] 润色两份文档，交叉校验页面清单、组件规范与状态语义色一致性
    status: completed
    dependencies:
      - write-prd
      - rewrite-design
---

## 产品概述

校园失物招领 App（HarmonyOS 端）——面向高校师生的失物招领平台，以"发布-匹配-互动"为核心闭环，解决校园物品丢失后信息不对称、找回率低的问题。

## 核心交付物

1. `docs/PRD.md`（新建）：详尽的产品需求文档，作为本项目唯一事实依据，明确功能范围、业务流程与验收标准
2. `docs/DESIGN.md`（重构）：为本项目选定并初始化 UI 设计系统，统一视觉与交互规范

## 核心特征

- PRD 全量覆盖 7 大模块（用户管理、首页与信息查找、失物动态、寻物动态、消息中心、我的主页、系统管理），逐模块细化并标注 MVP 首版/迭代优先级（P0/P1/P2），作为开发排期依据
- 明确核心业务流程：发布-审核-匹配-认领/线索-归还确认闭环、认领审核流程、线索流程、举报处理流程
- 每模块与核心流程均给出可验收的验收标准
- 设计系统沿用现有 DESIGN.md 的 Claude 暖色人文风格（Parchment 暖底、Terracotta 主色、暖灰中性色、衬线标题+无衬线 UI、ring shadow 深度体系），在此基础上适配校园失物招领 App 场景与 ArkUI 资源规范，而非推倒重来
- 纯文档交付，不涉及任何代码修改

## 技术选型

- 交付载体：Markdown 文档，业务流程使用 mermaid 图（代码块包裹），表格承载字段与验收标准
- 目标工程：HarmonyOS 5.0（targetSdk 26）+ ArkTS/ArkUI 空壳工程（bundleName com.example.found），本次不修改任何代码与资源文件
- 设计 token 映射：DESIGN.md 中色板、字号、间距、圆角将给出 ArkUI 资源文件（color.json / float.json / string.json）的命名建议，供后续 UI 实现直接引用，保证设计规范可落地

## 实施要点

- PRD 结构：文档版本与唯一事实依据声明 → 产品概述（定位/用户/价值）→ 功能范围总览与 MVP 优先级 → 权限矩阵 → 核心业务流程（mermaid）→ 7 大模块详细需求（字段、规则、边界条件）→ 页面清单（28 页）→ 数据模型（9 表）→ 非功能性需求 → 分模块与核心流程验收标准 → 版本迭代规划（V1.0 MVP / V1.x / V2.0）
- DESIGN.md 结构：设计理念 → 色板（保留原 token，补充校园状态语义色与场景色）→ 中文字体体系（标题宋体/正文黑体，HarmonyOS 回退 HarmonyOS Sans）→ 排版层级 → 间距/圆角/深度体系 → 组件规范（按钮、动态卡片、状态标签、表单、底部导航、弹窗、空状态、Toast）→ 动效与交互反馈 → 深色模式与无障碍 → ArkUI 资源命名映射 → Do's and Don'ts

## 设计风格

温暖人文 + 校园互助：保留 Claude 系暖色画布（Parchment #f5f4ed 页面底、Ivory #faf9f5 卡片面），以 Terracotta #c96442 为品牌主色，暖灰中性色（#4d4c48/#5e5d59/#87867f）构建可信、互助的社区氛围；衬线标题赋予人文感，无衬线 UI 保证信息效率。

## 场景适配要点

- 新增校园语义色：待认领（暖琥珀）、认领中（暖蓝）、已归还（暖绿）、已关闭（暖灰）、加急（深红 #b53333），均保持暖色调性
- 组件面向 App 场景：失物/寻物动态卡片、状态标签、信用等级徽章、发布表单、认领/线索操作、消息列表、底部导航
- 中文字体：标题用思源宋体（Noto Serif SC），正文用思源黑体（Noto Sans SC），HarmonyOS 设备回退 HarmonyOS Sans
- 深色模式沿用 Dark Surface #30302e / Near Black #141413 体系
- 页面规划（6 屏核心）：首页信息流（搜索+Banner+快捷入口+Tab 卡片流）、动态详情（互动+认领/线索）、发布表单（失物/寻物）、消息中心、我的主页（积分/发布/设置）、管理端审核列表；登录注册页单独设计

## Skill

- **write**
- Purpose: 对 PRD.md 与 DESIGN.md 两份交付文档进行中文表达润色，去除 AI 腔与冗余表述，保证语言专业、准确、可读
- Expected outcome: 两份文档语言自然专业、结构清晰一致，符合产品文档与设计规范文档的文体要求