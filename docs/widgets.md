# Widget Extension 文檔

本項目包含一個 Widget Extension，提供桌面小工具與即時動態 (Live Activity) 功能，讓用戶無需打開 App 即可查看任務與專注狀態。

## 📱 DailyTaskWidget (桌面小工具)

`DailyTaskWidget` 是一個顯示今日任務概覽的桌面小工具，支持 Small 和 Medium 兩種尺寸。

### 核心組件

#### 1. DailyTaskWidgetProvider
負責管理 Widget 的時間線 (Timeline) 更新。
- **Placeholder**: 提供預覽用的假數據。
- **Snapshot**: 提供 Widget 庫預覽的快照。
- **Timeline**: 
  - 讀取共享的 `UserDefaults` (App Group: `group.task-creator.com.task-creator`)。
  - 獲取今日任務數據。
  - 設定每 15 分鐘刷新一次。

#### 2. DailyTaskWidgetEntryView
Widget 的主要視圖層。
- **背景**: 統一使用暖色調背景 (`#FFF3D9`)，營造溫馨感。
- **內容**:
  - **標題區**: 顯示 "準備好..." 與派對圖標。
  - **狀態區**: 顯示剩餘任務數量或逾期提醒。
  - **操作區**: "開始專注" 按鈕，點擊跳轉至 App 的番茄鐘頁面 (`taskflow://pomodoro/start`)。
    - 按鈕背景色: 亮橙色 (`#FF7A1A`)。

### 數據共享
Widget 與主 App 通過 **App Groups** 共享數據。
- **Key**: `tasks`
- **格式**: JSON 編碼的 `[Task]` 數組。

## ⚡ DailyTaskWidgetLiveActivity (即時動態)

提供鎖屏與動態島 (Dynamic Island) 的即時狀態顯示。

### 功能
- **動態島**: 適配靈動島的 Compact, Minimal, Expanded 等多種狀態。
- **鎖屏通知**: 在鎖屏畫面上顯示當前專注或任務狀態。

## 🛠️ 最近更新

### UI 優化 (2025-12-02)
- **背景統一**: 移除原有的漸層背景，改為統一的暖色背景 (`#FFF3D9`)，提升視覺一致性。
- **按鈕樣式**: "開始專注" 按鈕改為純色背景 (`#FF7A1A`)，增強對比度與可讀性。

## ⚠️ 注意事項
- 確保在 Target 設定中正確開啟 App Groups。
- Widget 的刷新受 iOS 系統限制，並非實時更新。
