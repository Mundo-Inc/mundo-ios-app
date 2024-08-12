//
//  EnvironmentValues.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/23/24.
//

import Foundation
import SwiftUI

private struct MainWindowSizeKey: EnvironmentKey {
    static let defaultValue: CGSize = UIScreen.main.bounds.size
}

private struct MainWindowSafeAreaInsets: EnvironmentKey {
    static let defaultValue: EdgeInsets = .init()
}

extension EnvironmentValues {
    var mainWindowSize: CGSize {
        get { self[MainWindowSizeKey.self] }
        set { self[MainWindowSizeKey.self] = newValue }
    }
    
    var mainWindowSafeAreaInsets: EdgeInsets {
        get { self[MainWindowSafeAreaInsets.self] }
        set { self[MainWindowSafeAreaInsets.self] = newValue }
    }
}
