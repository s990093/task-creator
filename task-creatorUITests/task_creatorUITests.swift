////
////  task_creatorUITests.swift
////  task-creatorUITests
////
////  Created by hungwei on 2025/12/1.
////
//
//import XCTest
//
//final class task_creatorUITests: XCTestCase {
//    
//    override func setUpWithError() throws {
//        continueAfterFailure = false
//    }
//    
//    @MainActor
//        func testTabNavigation() throws {
//        let app = XCUIApplication()
//        app.launch()
//        
//        // Wait for Home tab to appear (handles onboarding delay)
//        let homeTab = app.buttons["Tab_Home"]
//        XCTAssertTrue(homeTab.waitForExistence(timeout: 10), "Home tab should exist")
//        
//        // Verify all tabs exist
//        XCTAssertTrue(app.buttons["Tab_Tasks"].exists)
//        XCTAssertTrue(app.buttons["Tab_Pomodoro"].exists)
//        XCTAssertTrue(app.buttons["Tab_AI"].exists)
//        XCTAssertTrue(app.buttons["Tab_Me"].exists)
//        
//        // Navigate through tabs
//        app.buttons["Tab_Tasks"].tap()
//        XCTAssertTrue(app.staticTexts["任務列表"].waitForExistence(timeout: 2) || app.staticTexts["待辦事項"].exists)
//        
//        app.buttons["Tab_Pomodoro"].tap()
//        XCTAssertTrue(app.staticTexts["專注計時"].waitForExistence(timeout: 2) || app.buttons["開始專注"].exists)
//        
//        app.buttons["Tab_AI"].tap()
//        XCTAssertTrue(app.staticTexts["TaskFlow AI"].waitForExistence(timeout: 2))
//        
//        app.buttons["Tab_Me"].tap()
//        XCTAssertTrue(app.staticTexts["個人檔案"].waitForExistence(timeout: 2) || app.staticTexts["設定"].exists)
//        
//        homeTab.tap()
//    }
//    
//    @MainActor
//    func testTaskCreation() throws {
//        let app = XCUIApplication()
//        app.launch()
//        
//        // Wait for launch
//        XCTAssertTrue(app.buttons["Tab_Tasks"].waitForExistence(timeout: 10))
//        
//        // Go to Tasks tab
//        app.buttons["Tab_Tasks"].tap()
//        
//        // Find input field
//        let newTaskField = app.textFields["AddTaskField"]
//        XCTAssertTrue(newTaskField.waitForExistence(timeout: 5), "Task input field should exist")
//        
//        newTaskField.tap()
//        newTaskField.typeText("UI Test Task")
//        
//        // Tap Quick Add button
//        let quickAddButton = app.buttons["QuickAddButton"]
//        XCTAssertTrue(quickAddButton.exists)
//        quickAddButton.tap()
//        
//        // Verify task is added
//        XCTAssertTrue(app.staticTexts["UI Test Task"].waitForExistence(timeout: 2))
//    }
//    
//    @MainActor
//    func testAIAssistantInteraction() throws {
//        let app = XCUIApplication()
//        app.launch()
//        
//        // Go to AI Assistant tab
//        let aiTab = app.buttons["Tab_AI"]
//        XCTAssertTrue(aiTab.waitForExistence(timeout: 10))
//        aiTab.tap()
//        
//        // Check for welcome message
//        XCTAssertTrue(app.staticTexts["嗨！我是您的 AI 學習教練"].waitForExistence(timeout: 5))
//        
//        // Type a message
//        let inputField = app.textFields["AIInput"]
//        XCTAssertTrue(inputField.waitForExistence(timeout: 5))
//        
//        inputField.tap()
//        inputField.typeText("Help me plan a study schedule")
//        
//        // Send button should be enabled after typing
//        let sendButton = app.buttons["AISendButton"]
//        XCTAssertTrue(sendButton.isEnabled)
//    }
//    
//    @MainActor
//    func testAIAssistantSimulation() throws {
//        let app = XCUIApplication()
//        app.launchArguments.append("-mockAI")
//        app.launch()
//        
//        // Go to AI Assistant tab
//        let aiTab = app.buttons["Tab_AI"]
//        XCTAssertTrue(aiTab.waitForExistence(timeout: 10))
//        aiTab.tap()
//        
//        // Type a message
//        let inputField = app.textFields["AIInput"]
//        XCTAssertTrue(inputField.waitForExistence(timeout: 5))
//        
//        inputField.tap()
//        inputField.typeText("Mock Test")
//        
//        // Send
//        let sendButton = app.buttons["AISendButton"]
//        XCTAssertTrue(sendButton.waitForExistence(timeout: 2))
//        sendButton.tap()
//        
//        // Verify mock response appears (simulated delay is 1s)
//        let mockResponse = app.staticTexts["這是一個模擬的 AI 回應。我為您規劃了一些學習任務。"]
//        XCTAssertTrue(mockResponse.waitForExistence(timeout: 5))
//        
//        // Verify mock tasks appear
//        XCTAssertTrue(app.staticTexts["閱讀 Swift 文件"].exists)
//        XCTAssertTrue(app.staticTexts["練習 UI 測試"].exists)
//        
//        // Test adding tasks
//        let addButton = app.buttons["AddSelectedTasksButton"]
//        if addButton.exists {
//            addButton.tap()
//            
//            // Go to Tasks tab to verify
//            app.buttons["Tab_Tasks"].tap()
//            XCTAssertTrue(app.staticTexts["閱讀 Swift 文件"].waitForExistence(timeout: 2))
//        }
//    }
//}
