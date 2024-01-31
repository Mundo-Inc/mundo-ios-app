//
//  OnboardingVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 1/31/24.
//

import Foundation

final class OnboardingVM: ObservableObject {
    static let currentOnboardingVersion = 1
    
    private let userSettings = UserSettings.shared
    
    init() {
        if userSettings.onboardingVersion < OnboardingVM.currentOnboardingVersion {
            isPresented = true
        } else {
            isPresented = false
        }
    }

    @Published var isPresented: Bool
    @Published var selection: Int = 0
    
    func done() {
        userSettings.onboardingVersion = OnboardingVM.currentOnboardingVersion
        isPresented = false
    }
}
