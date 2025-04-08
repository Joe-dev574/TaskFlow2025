//
//  HapticsManager.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/25/25.
//

import Foundation
import SwiftUI


class HapticsManager {
    
    static private let hapticFeedbackGenerator = UINotificationFeedbackGenerator()
    
    static func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        hapticFeedbackGenerator.notificationOccurred(type)
    
    }
}

