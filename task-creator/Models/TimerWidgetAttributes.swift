//
//  TimerWidgetAttributes.swift
//  task-creator
//
//  Created by hungwei on 2026/1/30.
//  Shared Activity Attributes definition
//

import ActivityKit
import Foundation

// MARK: - Activity Attributes (極簡設計)

@available(iOS 16.1, *)
public struct TimerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 動態數據
        public var isPaused: Bool
        public var elapsedSeconds: Int  // 已經過秒數
        public var totalSeconds: Int     // 總秒數（用於進度計算）
        
        public init(isPaused: Bool, elapsedSeconds: Int = 0, totalSeconds: Int = 1500) {
            self.isPaused = isPaused
            self.elapsedSeconds = elapsedSeconds
            self.totalSeconds = totalSeconds
        }
        
        // 計算進度百分比
        public var progress: Double {
            guard totalSeconds > 0 else { return 0 }
            return min(Double(elapsedSeconds) / Double(totalSeconds), 1.0)
        }
        
        // 剩餘秒數
        public var remainingSeconds: Int {
            max(totalSeconds - elapsedSeconds, 0)
        }
    }
    
    // 靜態數據（創建時設定，之後不變）
    public var timerMode: String        // "番茄鐘", "倒計時", "正計時"
    public var categoryName: String     // "數學", "英文" 等
    public var targetEndTime: Date      // ⭐️ 系統會用這個自動倒數
    
    public init(timerMode: String, categoryName: String, targetEndTime: Date) {
        self.timerMode = timerMode
        self.categoryName = categoryName
        self.targetEndTime = targetEndTime
    }
}
