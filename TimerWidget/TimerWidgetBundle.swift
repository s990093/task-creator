//
//  TimerWidgetBundle.swift
//  TimerWidget
//
//  Created by hungwei on 2026/1/30.
//

import WidgetKit
import SwiftUI

@main
struct TimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        TimerWidget()
        TimerWidgetControl()
        TimerWidgetLiveActivity()
    }
}
