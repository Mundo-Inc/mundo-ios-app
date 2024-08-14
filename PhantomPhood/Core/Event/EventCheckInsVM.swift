//
//  EventCheckInsVM.swift
//  PhantomPhood
//
//  Created by Kia Abdi on 3/9/24.
//

import Foundation

final class EventCheckInsVM: ObservableObject, LoadingSections {
    private let checkInDM = CheckInDM()
    
    private let eventVM: EventVM
    
    init(eventVM: EventVM) {
        self.eventVM = eventVM
    }
    
    @Published var loadingSections = Set<LoadingSection>()
    @Published var checkIns: [CheckIn]? = nil
    
    private var checkInsPagination: Pagination? = nil
    
    func fetch(type: RefreshNewAction) async {
        guard let eventId = eventVM.event?.id, !loadingSections.contains(.fetchCheckIns) else { return }

        if type == .refresh {
            checkInsPagination = nil
        } else if let checkInsPagination, !checkInsPagination.hasMore {
            return
        }
        
        setLoadingState(.fetchCheckIns, to: true)
        
        defer {
            setLoadingState(.fetchCheckIns, to: false)
        }
        
        do {
            let page = if let checkInsPagination {
                checkInsPagination.page + 1
            } else {
                1
            }
            
            let data = try await checkInDM.getCheckins(event: eventId, page: page)
            
            await MainActor.run {
                if page == 1 {
                    checkIns = data.data
                } else if checkIns != nil {
                    checkIns!.append(contentsOf: data.data)
                } else {
                    checkIns = data.data
                }
            }
            
            self.checkInsPagination = data.pagination
        } catch {
            presentErrorToast(error)
        }
    }
    
    enum LoadingSection: Hashable {
        case fetchCheckIns
    }
}
