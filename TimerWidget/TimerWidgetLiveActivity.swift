//
//  TimerWidgetLiveActivity.swift
//  TimerWidget
//
//  Created by hungwei on 2026/1/30.
//  Enhanced with modern UI, progress bars, and interactive buttons
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

// TimerWidgetAttributes 定義在共享文件中: task-creator/Models/TimerWidgetAttributes.swift

// MARK: - Live Activity Widget

struct TimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerWidgetAttributes.self) { context in
            // 🔒 鎖定螢幕 UI (現代美觀設計)
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // ⬆️ Expanded 展開狀態
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 8) {
                        Text(getModeIcon(context.attributes.timerMode))
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(context.attributes.timerMode)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(context.attributes.categoryName)
                                .font(.caption2)
                                .foregroundColor(.secondary.opacity(0.7))
                                .lineLimit(1)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 8) {
                        // 時間顯示
                        Text(context.attributes.targetEndTime, style: .timer)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(
                                context.state.isPaused ?
                                    .orange : .green
                            )
                        
                        // 線性進度條
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // 背景
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.secondary.opacity(0.2))
                                    .frame(height: 8)
                                
                                // 進度
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: context.state.isPaused ?
                                                [.orange, .yellow] : [.green, .mint],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(
                                        width: geometry.size.width * context.state.progress,
                                        height: 8
                                    )
                            }
                        }
                        .frame(height: 8)
                        
                        // 進度百分比
                        Text("\(Int(context.state.progress * 100))%")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Label {
                            Text(formatTime(context.state.elapsedSeconds))
                                .font(.caption2)
                        } icon: {
                            Image(systemName: "clock")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                        
                        Label {
                            Text(formatTime(context.state.remainingSeconds))
                                .font(.caption2)
                        } icon: {
                            Image(systemName: "hourglass")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        // 暫停/繼續按鈕
                        Button(intent: ToggleTimerIntent()) {
                            Label(
                                context.state.isPaused ? "繼續" : "暫停",
                                systemImage: context.state.isPaused ? "play.fill" : "pause.fill"
                            )
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(
                                context.state.isPaused ?
                                    Color.green.opacity(0.2) : Color.orange.opacity(0.2)
                            )
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                        
                        // 停止按鈕
                        Button(intent: StopTimerIntent()) {
                            Label("停止", systemImage: "stop.fill")
                                .font(.caption)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                // ⬅️ Compact 左側：模式圖標
                Text(getModeIcon(context.attributes.timerMode))
            } compactTrailing: {
                // ➡️ Compact 右側：時間 + 進度環
                ZStack {
                    // 背景圓環
                    Circle()
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
                    
                    // 進度圓環
                    Circle()
                        .trim(from: 0, to: context.state.progress)
                        .stroke(
                            context.state.isPaused ? Color.orange : Color.green,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    // 時間文字
                    Text(context.attributes.targetEndTime, style: .timer)
                        .monospacedDigit()
                        .font(.system(size: 10, weight: .semibold))
                }
                .frame(width: 32, height: 32)
            } minimal: {
                // 🔴 Minimal：圖標 + 進度指示
                ZStack {
                    Text(getModeIcon(context.attributes.timerMode))
                        .font(.caption2)
                    
                    Circle()
                        .trim(from: 0, to: context.state.progress)
                        .stroke(
                            context.state.isPaused ? Color.orange : Color.green,
                            lineWidth: 2
                        )
                        .rotationEffect(.degrees(-90))
                }
            }
        }
    }
    
    // 根據模式返回符號
    private func getModeIcon(_ mode: String) -> String {
        switch mode {
        case "番茄鐘": return "🍅"
        case "倒計時": return "⏱"
        case "正計時": return "⏰"
        default: return "⏱"
        }
    }
    
    // 格式化時間顯示
    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
}

// MARK: - 鎖定螢幕視圖

struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<TimerWidgetAttributes>
    
    var body: some View {
        HStack(spacing: 12) {
            // 左側：互動按鈕（垂直排列）
            VStack(spacing: 8) {
                // 暫停/繼續按鈕
                Button(intent: ToggleTimerIntent()) {
                    Image(systemName: context.state.isPaused ? "play.fill" : "pause.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                // 停止按鈕
                Button(intent: StopTimerIntent()) {
                    Image(systemName: "stop.fill")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.blue.opacity(0.3))
                        .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            
            // 中間：圓形進度環 + 百分比
            ZStack {
                // 背景圓環
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 6)
                    .frame(width: 70, height: 70)
                
                // 進度圓環
                Circle()
                    .trim(from: 0, to: context.state.progress)
                    .stroke(
                        Color.green,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 70, height: 70)
                
                // 中心：百分比
                Text("\(Int(context.state.progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            // 右側：詳細信息
            VStack(alignment: .leading, spacing: 4) {
                // 標題行：emoji + 模式名稱
                HStack(spacing: 4) {
                    Text(getModeIcon(context.attributes.timerMode))
                        .font(.subheadline)
                    Text(context.attributes.timerMode)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                
                // 類別名稱
                Text(context.attributes.categoryName)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                // 主要時間顯示
                Text(formatRemainingTime(context.state.remainingSeconds))
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
                
                // 時間詳情
                HStack(spacing: 8) {
                    Label(formatTime(context.state.elapsedSeconds), systemImage: "clock")
                        .font(.caption2)
                    Label(formatTime(context.state.remainingSeconds), systemImage: "hourglass")
                        .font(.caption2)
                }
                .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding()
    }
    
    // 格式化剩餘時間為 MM:SS
    private func formatRemainingTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    // 格式化時間為 HH:MM:SS 或 MM:SS
    private func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let mins = (seconds % 3600) / 60
        let secs = seconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, mins, secs)
        } else {
            return String(format: "%02d:%02d", mins, secs)
        }
    }
    
    private func getModeIcon(_ mode: String) -> String {
        switch mode {
        case "番茄鐘": return "🍅"
        case "倒計時": return "⏱"
        case "正計時": return "⏰"
        default: return "⏱"
        }
    }
}

// MARK: - App Intents for Interactive Buttons


struct ToggleTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Timer"
    
    func perform() async throws -> some IntentResult {
        // 使用 App Group 共享數據
        let appGroupID = "group.com.taskcreator.timer"
        if let sharedDefaults = UserDefaults(suiteName: appGroupID) {
            // 發送暫停/繼續命令
            let currentCommand = sharedDefaults.string(forKey: "timerCommand") ?? ""
            sharedDefaults.set("toggle", forKey: "timerCommand")
            sharedDefaults.set(Date().timeIntervalSince1970, forKey: "commandTimestamp")
            print("✅ Toggle command sent at \(Date())")
        }
        return .result()
    }
}

struct StopTimerIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Timer"
    
    func perform() async throws -> some IntentResult {
        // 使用 App Group 共享數據
        let appGroupID = "group.com.taskcreator.timer"
        if let sharedDefaults = UserDefaults(suiteName: appGroupID) {
            // 發送停止命令
            sharedDefaults.set("stop", forKey: "timerCommand")
            sharedDefaults.set(Date().timeIntervalSince1970, forKey: "commandTimestamp")
            print("✅ Stop command sent at \(Date())")
        }
        return .result()
    }
}


// MARK: - Previews

extension TimerWidgetAttributes {
    fileprivate static var preview: TimerWidgetAttributes {
        TimerWidgetAttributes(
            timerMode: "番茄鐘",
            categoryName: "數學作業",
            targetEndTime: Date().addingTimeInterval(25 * 60)
        )
    }
}

extension TimerWidgetAttributes.ContentState {
    fileprivate static var running: TimerWidgetAttributes.ContentState {
        TimerWidgetAttributes.ContentState(
            isPaused: false,
            elapsedSeconds: 300,
            totalSeconds: 1500
        )   
    }
     
    fileprivate static var paused: TimerWidgetAttributes.ContentState {
        TimerWidgetAttributes.ContentState(
            isPaused: true,
            elapsedSeconds: 750,
            totalSeconds: 1500
        )
    }
}

#Preview("Notification", as: .content, using: TimerWidgetAttributes.preview) {
   TimerWidgetLiveActivity()
} contentStates: {
    TimerWidgetAttributes.ContentState.running
    TimerWidgetAttributes.ContentState.paused
}

