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
    
    @Published var isShowing = false
    @Published var backgroundShift: CGFloat = 0
    @Published var section: Sections = .journey
    
    func done() {
        userSettings.onboardingVersion = OnboardingVM.currentOnboardingVersion
        isPresented = false
    }
    
    // MARK: Enums
    
    enum Sections {
        case journey
        case share
        case connect
        case rewards
        
        var nextButtonTitle: String {
            switch self {
            case .journey:
                "Let's Go"
            case .share:
                "Next"
            case .connect:
                "Next"
            case .rewards:
                "Let the Fun Begin"
            }
        }
    }
}
