//
//  Throttle.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 12/13/23.
//

import Foundation

final class Throttle {
    private let interval: TimeInterval
    private var workItem: DispatchWorkItem?
    private var lastCallTime: Date?
    
    init(interval: TimeInterval) {
        self.interval = interval
    }
    
    func call(_ action: @escaping () -> Void) {
        workItem?.cancel() // Cancel the previous task if it's still pending
        
        workItem = DispatchWorkItem { [weak self] in
            self?.lastCallTime = Date()
            action()
        }
        
        // Calculate the delay time considering the last call time
        let delayTime = lastCallTime.flatMap { lastCallTime -> TimeInterval in
            let timeSinceLastCall = Date().timeIntervalSince(lastCallTime)
            return max(0, interval - timeSinceLastCall)
        } ?? interval
        
        // Execute the task after the calculated delay
        if let task = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime, execute: task)
        }
    }
}
