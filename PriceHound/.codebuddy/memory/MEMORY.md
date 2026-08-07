# PriceHound Project Memory

## Project Overview
- Name: PriceHound
- Platform: HarmonyOS NEXT (ArkTS + ArkUI)
- Type: E-commerce price monitoring tool
- Architecture: Stage model, SQLite local storage, no cloud backend

## Key Conventions
- UI follows Claude (Anthropic) warm-tone design system (DESIGN.md)
- Parchment `#f5f4ed` background, Terracotta `#c96442` primary CTA
- Serif for headings (weight 500 max), Sans for UI, Mono for prices
- No cold grays, no bold serif, no sharp corners, no `#ffffff` backgrounds
- Ring shadows (0px 0px 0px 1px) instead of drop shadows

## Current State
- 全量开发完成（2026-08-03）：16 页面 + 15 组件 + 4 ViewModel + Mock 数据层 + CoinGecko 演示 API
- 深色模式完成：ThemeManager 单例 + AppStorage('theme.isDark') 广播，全部页面/组件使用语义色方法，页面内加 `@StorageProp('theme.isDark') isDark` 订阅
- todo.md 进度 94/111（85%），未完成均为阶段 5 增强项（图表手势/转场动画/多栏响应式/分页/键盘/返回手势）
- PRD document completed: docs/PRD.md (2026-08-03)

## 关键约定（开发后新增）
- 数据源：Mock 为主，CoinGecko 免费 API（DataSourceType.MOCK=0 / COINGECKO=1）
- ViewModel 为静态类，通过 getRepo() 单例仓库访问数据，注意避免循环依赖（AlertViewModel 不依赖 PriceMonitorViewModel）
- Refresh 组件正确用法：`Refresh({refreshing: this.refreshing}).onRefreshing(() => {...}) { ... }`，外层包 Column 承载 layoutWeight
- AppStorage 是全局对象不可 import；ArkTS 无 Array.from（用自定义方法）
- ThemeManager 语义色全部返回 string（可直用于 Canvas）

## Documentation
- docs/项目介绍.md: Feature planning (8 modules)
- docs/DESIGN.md: UI design system (Claude warm-tone)
- docs/PRD.md: Product Requirements Document
- docs/todo.md: 84 项任务清单（已更新勾选状态）
