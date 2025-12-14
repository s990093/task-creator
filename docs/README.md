# TaskFlow - 番茄鐘任務管理 App

> 一個結合番茄鐘計時、任務管理、AI 分析的現代化學習助手應用

## 📋 項目概述

TaskFlow 是一個為學生設計的全功能生產力應用，整合了以下核心功能：

- ⏱️ **專注計時器** - 多種視覺風格的番茄鐘計時器
- 📋 **任務看板** - 現代化 Kanban 風格的任務管理
- 🏠 **首頁儀表板** - 動態進度追蹤與可愛機器人吉祥物
- 🤖 **AI 教練** - 基於 GPT 的學習數據分析與建議
- 📊 **數據分析** - 詳細的專注時間統計與回顧

## 🎨 設計風格

- **深色主題** - 舒適的深藍灰色調
- **流暢動畫** - Spring 動畫與過渡效果
- **現代 UI** - 漸層、陰影、毛玻璃效果
- **視覺化** - 進度環、彩色標籤、狀態徽章

## 🏗️ 項目結構

```
task-creator/
├── Models/                 # 數據模型
│   └── TaskModel.swift
├── ViewModels/            # 視圖模型
│   └── TaskViewModel.swift
├── Services/              # 服務層
│   └── AIAnalysisService.swift
├── Views/                 # 視圖層
│   ├── Main/             # 主要視圖 (Tab Bar, Onboarding)
│   ├── Home/             # 首頁 (Progress Card, Dashboard)
│   ├── Tasks/            # 任務管理 (Kanban, Cards)
│   ├── Focus/            # 專注計時 (Pomodoro, Flip Clock)
│   └── Me/               # 個人中心 (AI Coach, Profile)
├── Utilities/            # 工具類
│   └── DesignSystem.swift
└── docs/                 # 項目文檔
```

## 📚 文檔導航

### 核心文檔
- [架構說明](architecture.md) - 項目架構與設計模式
- [數據模型](models.md) - Task, Category, FocusSession 等
- [視圖模型](viewmodels.md) - TaskViewModel 狀態管理
- [服務層](services.md) - AI 分析服務

### 視圖文檔
- [主要視圖](views-main.md) - ContentView, TabBar, Onboarding
- [首頁視圖](views-home.md) - HomeView, ProgressCard, RobotMascot
- [任務視圖](views-tasks.md) - Kanban Board, Task Cards, Edit Forms
- [專注視圖](views-focus.md) - Pomodoro Timer, Flip Clock, Analytics
- [個人視圖](views-me.md) - AI Coach, Profile, Reflections
- [小工具](widgets.md) - DailyTaskWidget, Live Activity

## 🚀 快速開始

### 環境要求
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### 安裝步驟

1. **克隆項目**
```bash
git clone <repository-url>
cd task-creator
```

2. **打開項目**
```bash
open task-creator.xcodeproj
```

3. **配置 API Key**
在 `AIAnalysisService.swift` 中設置你的 OpenAI API Key：
```swift
private let apiKey = "YOUR_API_KEY_HERE"
```

4. **運行應用**
- 選擇目標設備（iPhone 模擬器或真機）
- 點擊 Run (⌘R)

## ✨ 主要功能

### 1. 專注計時器 (Focus)
- **3 種視覺風格**:
  - 🎴 **Flip Clock** - 3D 翻轉數字動畫
  - 🔢 **Digital** - 數字時鐘 + 進度環
  - 💧 **Fluid Digital** - 流動重疊數字效果
- **計時模式**: Pomodoro (25分鐘), Countdown, Stopwatch
- **背景通知**: App 進入後台仍持續計時
- **專注記錄**: 自動記錄每次專注會話

### 2. 任務管理 (Tasks)
- **Kanban 看板**: 按類別（國文、數學、英文）分欄顯示
- **彩色標籤**: 類別色彩條 + 狀態膠囊徽章
- **FAB 按鈕**: 浮動操作按鈕快速建立任務
- **智能狀態**: 自動判斷已完成/進行中/逾期

### 3. 首頁儀表板 (Home)
- **機器人吉祥物**: 根據進度變化顏色與表情
- **進度可視化**: 圓環進度 + 線性進度條
- **任務預覽**: 顯示今日前 3 個任務

### 4. AI 教練 (Me)
- **週報生成**: 分析本週學習數據
- **策略建議**: AI 提供下週改進建議
- **歷史記錄**: 保存所有過往週報

## 🎯 核心技術

### SwiftUI
- **聲明式 UI**: 使用 SwiftUI 構建所有界面
- **狀態管理**: @State, @Binding, @EnvironmentObject
- **動畫系統**: Spring, Linear, Timing Curve

### Combine
- **響應式編程**: Timer.publish 用於計時器
- **數據流**: Published 屬性自動更新 UI

### UserDefaults
- **本地持久化**: 保存任務、專注記錄、AI 報告
- **編碼解碼**: Codable 協議實現自動序列化

### OpenAI API
- **GPT 集成**: 使用 GPT-4 分析學習數據
- **自然語言**: 生成中文週報與建議

## 🔧 開發指南

### 添加新任務類別

1. 在 `TaskModel.swift` 中擴展 `Category` enum
2. 在 `TaskCardView.swift` 更新 `categoryColor` 和 `categoryIcon` 函數
3. 在 `ModernKanbanColumn` 中同步更新

### 自定義計時器樣式

1. 在 `FlipClockView.swift` 的 `ClockStyle` enum 添加新 case
2. 創建對應的 View (如 `MyCustomClockView`)
3. 在 `body` 的 `switch` 中添加新分支
4. 更新 `cycleStyle()` 函數以支持循環切換

### 修改 AI 提示詞

編輯 `AIAnalysisService.swift` 中的 `analyzePerformance` 方法：
```swift
let prompt = """
你是一位專業的學習教練...
(自定義提示詞)
"""
```

## 🐛 已知問題

1. **Widget Extension**: `DailyTaskWidget.swift` 需要手動設置 Widget Extension Target
2. **App Groups**: Widget 需要配置 App Group 才能共享數據
3. **API Key**: 生產環境應使用 Keychain 存儲 API Key

## 📝 更新日誌

### v1.0.0 (2025-12-02)
- ✅ 完成核心功能開發
- ✅ 實現 3 種計時器樣式
- ✅ 重新設計 Kanban 看板
- ✅ 集成 AI 週報功能
- ✅ 添加機器人吉祥物

## 📄 授權

MIT License

## 👥 貢獻

歡迎提交 Issue 和 Pull Request！

---

**Made with ❤️ using SwiftUI**
