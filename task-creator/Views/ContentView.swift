//
//  ContentView.swift
//  task-creator
//
//  Created by hungwei on 2025/12/1.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var selectedTab = 0
    @State private var showOnboarding = true
    @Binding var deepLinkAction: DeepLinkAction?
    
    // Remove custom init to avoid Binding initialization issues
    // Tab Bar appearance will be configured in onAppear
    
    var body: some View {
        ZStack {
            if showOnboarding {
                OnboardingView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showOnboarding = false
                            }
                        }
                    }
                    .zIndex(10)
            } else {
                VStack(spacing: 0) {
                    // Content Area
                    ZStack {
                        switch selectedTab {
                        case 0:
                            HomeView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case 1:
                            TaskListView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case 2:
                            PomodoroView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case 3:
                            AIAssistantView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        case 4:
                            MeView()
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        default:
                            HomeView()
                        }
                    }
                    .animation(.easeInOut(duration: 0.25), value: selectedTab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Custom Tab Bar
                    CustomTabBar(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(.keyboard) // Prevent tab bar from moving up with keyboard
                .onChange(of: deepLinkAction) { oldValue, newValue in
                    handleDeepLinkAction(newValue)
                }
            }
        }
        .onAppear {
            // Customize Tab Bar Appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.slate900)
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    // MARK: - Deep Link Action Handler
    private func handleDeepLinkAction(_ action: DeepLinkAction?) {
        guard let action = action else { return }
        
        switch action {
        case .startPomodoro:
            // Switch to Pomodoro tab
            selectedTab = 2
            
            // Wait a bit for tab to switch, then start timer
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                viewModel.setTimerMode(0) // Pomodoro mode (25 min)
                viewModel.startTimer()
            }
            
            // Reset action
            deepLinkAction = nil
        }
    }
}

#Preview {
    ContentView(deepLinkAction: .constant(nil))
        .environmentObject(TaskViewModel())
}
