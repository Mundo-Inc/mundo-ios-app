//
//  EventCheckInsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/9/24.
//

import Foundation

@MainActor
final class EventCheckInsVM: ObservableObject {
    private let checkInDM = CheckInDM()
    
    private let eventVM: EventVM
    
    init(eventVM: EventVM) {
        self.eventVM = eventVM
    }
    
    @Published var isLoading: Bool = false
    @Published var checkIns: [Checkin]? = nil
    
    var page = 1
    func fetch(type: RefreshNewAction) async {
        guard let eventId = eventVM.event?.id, !isLoading else { return }

        if type == .refresh {
            page = 1
        }
        
        isLoading = true
        do {
            let data = try await checkInDM.getCheckins(event: eventId)
            if page == 1 {
                checkIns = data
            } else if checkIns != nil {
                checkIns!.append(contentsOf: data)
            } else {
                checkIns = data
            }
            page += 1
        } catch {
            print(error)
        }
        isLoading = false
    }
}
