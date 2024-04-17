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
    
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var total: Int? = nil
    @Published var checkIns: [Checkin]? = nil
    
    private var page = 1
    func fetch(type: RefreshNewAction) async {
        guard let eventId = eventVM.event?.id, !isLoading else { return }

        if type == .refresh {
            page = 1
        }
        
        isLoading = true
        do {
            let data = try await checkInDM.getCheckins(event: eventId, page: page)
            self.total = data.pagination.totalCount
            
            if page == 1 {
                checkIns = data.data
            } else if checkIns != nil {
                checkIns!.append(contentsOf: data.data)
            } else {
                checkIns = data.data
            }
            
            page += 1
        } catch {
            presentErrorToast(error)
        }
        isLoading = false
    }
}
