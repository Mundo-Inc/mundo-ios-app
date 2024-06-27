//
//  HapticManager.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/16/24.
//

import Foundation
import SwiftUI

/// `HapticManager` is a singleton class designed to manage haptic feedback throughout an iOS application. It encapsulates the functionality for triggering different types of haptic feedback: impact, notification, and selection. This class ensures that haptic feedback can be easily and consistently implemented across the application.
///
/// To use `HapticManager`, simply call the desired public function on `HapticManager.shared` with the appropriate parameters.
final class HapticManager {
    static let shared = HapticManager()
    
    private lazy var notificationGenerator: UINotificationFeedbackGenerator = {
        return UINotificationFeedbackGenerator()
    }()
    
    private lazy var selectionGenerator: UISelectionFeedbackGenerator = {
        return UISelectionFeedbackGenerator()
    }()
    
    private var impactGenerators: [UIImpactFeedbackGenerator.FeedbackStyle: UIImpactFeedbackGenerator] = [:]
    
    private let impactGeneratorQueue = DispatchQueue(label: "\(K.ENV.BundleIdentifier).hapticManager.impactGeneratorQueue", attributes: .concurrent)
    
    private init() {}
    
    /// Triggers an impact feedback with the specified style.
    ///
    /// - Parameter style: The `UIImpactFeedbackGenerator.FeedbackStyle` to use for the impact feedback.
    public func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        impactGeneratorQueue.async(flags: .barrier) {
            if let generator = self.impactGenerators[style] {
                DispatchQueue.main.async {
                    generator.impactOccurred()
                }
            } else {
                let generator = UIImpactFeedbackGenerator(style: style)
                self.impactGenerators[style] = generator
                DispatchQueue.main.async {
                    generator.impactOccurred()
                }
            }
        }
    }
    
    /// Triggers a notification feedback with the specified type.
    ///
    /// - Parameter type: The `UINotificationFeedbackGenerator.FeedbackType` to use for the notification feedback.
    public func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        DispatchQueue.main.async {
            self.notificationGenerator.notificationOccurred(type)
        }
    }
    
    /// Triggers a selection feedback indicating a change in selection.
    public func selection() {
        DispatchQueue.main.async {
            self.selectionGenerator.selectionChanged()
        }
    }
}
