//
//  ReportVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 2/9/24.
//

import Foundation
import SwiftUI

@MainActor
final class ReportVM: ObservableObject {
    private let reportDM = ReportDM()
    private let toastVM = ToastVM.shared
    
    let item: ReportDM.ReportType
    
    init(item: ReportDM.ReportType) {
        self.item = item
    }
    
    @Published var flagType: ReportDM.FlagType? = nil
    @Published var note = ""
    @Published var step = 0
    
    func submit() async {
        do {
            guard let flagType else { return }
            
            try await reportDM.report(item: item, flagType: flagType, note: note)
            
            toastVM.toast(.init(type: .success, title: "Success", message: "We got your report. It can take up to 24 hours to respond."))
            
            self.flagType = nil
            self.note = ""
        } catch {
            presentErrorToast(error, title: "Unable to submit your report")
        }
    }
}
