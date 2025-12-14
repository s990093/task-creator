//
//  task_creatorApp.swift
//  task-creator
//
//  Created by hungwei on 2025/12/1.
//

import SwiftUI


@main
struct task_creatorApp: App {
    @StateObject private var viewModel = TaskViewModel()
    @State private var deepLinkAction: DeepLinkAction?

    var body: some Scene {
        WindowGroup {
            ContentView(deepLinkAction: $deepLinkAction)
                .environmentObject(viewModel)
                .preferredColorScheme(.dark)  // base dark mode
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    // MARK: - Deep Link Handler
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "taskflow" else { return }
        
        switch url.host {
        case "pomodoro":
            if url.path == "/start" {
                deepLinkAction = .startPomodoro
            }
        default:
            break
        }
    }
}

// MARK: - Deep Link Actions
enum DeepLinkAction {
    case startPomodoro
}
